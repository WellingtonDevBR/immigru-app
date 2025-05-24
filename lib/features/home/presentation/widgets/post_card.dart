import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:immigru/features/home/domain/entities/post.dart';
import 'package:immigru/shared/widgets/grove_like_button.dart';
import 'package:immigru/shared/widgets/seed_comment_button.dart';
import 'package:immigru/shared/widgets/in_app_browser.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:any_link_preview/any_link_preview.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Modern card for displaying a post in the feed
class PostCard extends StatefulWidget {
  final Post post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback? onShare;
  final VoidCallback? onDelete;
  final Function(String)? onEdit;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
    this.onShare,
    this.onDelete,
    this.onEdit,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  // Local state to track liked and commented status for immediate UI feedback
  late bool _isLiked;
  bool _isCommented = false; // Track comment state locally
  String? _firstLink;
  final _logger = Logger();
  
  // Track if the current user is the post author
  bool _isCurrentUserAuthor = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.isLiked;
    // Initialize comment state based on whether the user has commented on this post
    _isCommented = widget.post.hasUserComment;
    _extractLinks();
    
    // Check if the current user is the author of this post
    final supabase = Supabase.instance.client;
    _currentUserId = supabase.auth.currentUser?.id;
    _isCurrentUserAuthor = _currentUserId != null && _currentUserId == widget.post.userId;
  }
  
  /// Extracts the first valid URL from the post content
  void _extractLinks() {
    try {
      // Skip extraction if content is empty
      if (widget.post.content.isEmpty) {
        return;
      }
      
      // More comprehensive regex for better matching
      // This will match both URLs with and without http/https prefix
      final urlRegExp = RegExp(
        r'(https?://)?([\w-]+\.)+[\w-]+(/[\w- ./?%&=]*)?',
        caseSensitive: false,
      );
      
      final matches = urlRegExp.allMatches(widget.post.content);
      if (matches.isNotEmpty) {
        // Get the first match
        String? extractedLink = matches.first.group(0);
        
        // Clean up the URL if it has trailing punctuation
        if (extractedLink != null) {
          // Remove trailing punctuation that might be part of the text but not the URL
          if (extractedLink.endsWith('.') || 
              extractedLink.endsWith(',') || 
              extractedLink.endsWith(')') || 
              extractedLink.endsWith('!') ||
              extractedLink.endsWith('?')) {
            extractedLink = extractedLink.substring(0, extractedLink.length - 1);
          }
          
          // Ensure URL has http/https prefix
          if (!extractedLink.startsWith('http://') && !extractedLink.startsWith('https://')) {
            extractedLink = 'https://$extractedLink';
          }
          
          // Only set state if mounted to prevent memory leaks
          if (mounted) {
            setState(() {
              _firstLink = extractedLink;
            });
            _logger.d('Extracted link from post: $_firstLink');
          }
        }
      }
    } catch (e) {
      _logger.e('Error extracting links: $e');
    }
  }
  
  /// Builds rich text with clickable links
  Widget _buildRichTextWithLinks(String content, bool isDarkMode) {
    // Use the same regex as in _extractLinks
    final urlRegExp = RegExp(
      r'(https?://[^\s]+)',
      caseSensitive: false,
    );
    
    // If no URLs in the content, return simple text
    if (!urlRegExp.hasMatch(content)) {
      return Text(
        content,
        style: TextStyle(
          fontSize: 15,
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
      );
    }
    
    // Split the text by URLs
    final List<InlineSpan> spans = [];
    int lastMatchEnd = 0;
    
    // Find all URLs and create text spans
    for (final match in urlRegExp.allMatches(content)) {
      // Add text before the URL
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: content.substring(lastMatchEnd, match.start),
          style: TextStyle(
            fontSize: 15,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ));
      }
      
      // Extract and clean the URL
      String url = match.group(0)!;
      // Remove trailing punctuation
      if (url.endsWith('.') || url.endsWith(',') || url.endsWith(')') || 
          url.endsWith('!') || url.endsWith('?')) {
        url = url.substring(0, url.length - 1);
      }
      
      // Add the URL as a clickable span
      spans.add(TextSpan(
        text: url,
        style: TextStyle(
          fontSize: 15,
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            _openLinkInAppBrowser(url);
          },
      ));
      
      lastMatchEnd = match.end;
    }
    
    // Add any remaining text after the last URL
    if (lastMatchEnd < content.length) {
      spans.add(TextSpan(
        text: content.substring(lastMatchEnd),
        style: TextStyle(
          fontSize: 15,
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
      ));
    }
    
    return RichText(text: TextSpan(children: spans));
  }
  
  /// Shows a confirmation dialog before opening a link
  void _showLinkPreviewDialog(String url) {
    _logger.d('Showing link preview dialog for: $url');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Open Website'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Do you want to open this website?'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                url,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _openLinkInAppBrowser(url);
            },
            child: const Text('OPEN'),
          ),
        ],
      ),
    );
  }

  /// Opens a link in the in-app browser
  void _openLinkInAppBrowser(String url) {
    _logger.d('Opening link in app browser: $url');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InAppBrowser(
          url: url,
          title: 'Web View',
        ),
      ),
    );
  }
  
  /// Validates if the provided URL is a valid image URL
  bool _isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    if (url == 'custom') return false; // Filter out invalid 'custom' URL
    
    // Basic URL validation
    return url.startsWith('http://') || url.startsWith('https://') || url.startsWith('data:image/');
  }

  @override
  void didUpdateWidget(PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.isLiked != widget.post.isLiked) {
      _isLiked = widget.post.isLiked;
    }
  }
  
  /// Shows options menu for the post
  void _showPostOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share'),
                onTap: () {
                  Navigator.pop(context);
                  if (widget.onShare != null) {
                    widget.onShare!();
                  }
                },
              ),
              // Only show edit and delete options if the current user is the author
              if (_isCurrentUserAuthor) ...[  
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Edit Post'),
                  onTap: () {
                    Navigator.pop(context);
                    _showEditPostDialog(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Delete Post', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirmation(context);
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }
  
  /// Shows a dialog to confirm post deletion
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (widget.onDelete != null) {
                widget.onDelete!();
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  /// Shows a dialog to edit the post content
  void _showEditPostDialog(BuildContext context) {
    final textController = TextEditingController(text: widget.post.content);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Post'),
        content: TextField(
          controller: textController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Edit your post...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newContent = textController.text.trim();
              if (newContent.isNotEmpty && widget.onEdit != null) {
                Navigator.pop(context);
                widget.onEdit!(newContent);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Calculate time ago
    final timeAgo = timeago.format(widget.post.createdAt);

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post header with user info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // User avatar
                CircleAvatar(
                  radius: 18,
                  backgroundImage: _isValidImageUrl(widget.post.userAvatar)
                      ? NetworkImage(widget.post.userAvatar!)
                      : null,
                  child: !_isValidImageUrl(widget.post.userAvatar)
                      ? Text(
                          widget.post.userName?[0] ?? 'U',
                          style: const TextStyle(fontSize: 16),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                // User name and post time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.userName ?? 'Anonymous',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            timeAgo,
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  isDarkMode ? Colors.white60 : Colors.black54,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.public,
                            size: 12,
                            color: isDarkMode ? Colors.white60 : Colors.black54,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // More options
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  iconSize: 20,
                  onPressed: () {
                    _showPostOptions(context);
                  },
                ),
              ],
            ),
          ),
          // Post content with clickable links
          if (widget.post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: _buildRichTextWithLinks(widget.post.content, isDarkMode),
            ),
          
          // Link preview if a link is detected in the content
          if (_firstLink != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: InkWell(
                onTap: () => _showLinkPreviewDialog(_firstLink!),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AnyLinkPreview(
                      link: _firstLink!,
                      displayDirection: UIDirection.uiDirectionVertical, // Changed to vertical for better preview
                      showMultimedia: true,
                      bodyMaxLines: 3,
                      previewHeight: 200, // Taller preview to show more content
                      bodyTextOverflow: TextOverflow.ellipsis,
                      titleStyle: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      bodyStyle: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                        fontSize: 14,
                      ),
                      backgroundColor: isDarkMode ? Colors.grey[850]! : Colors.grey[100]!,
                      borderRadius: 0, // We're using the container for border radius
                      removeElevation: true,
                      cache: const Duration(days: 7),
                      onTap: () => _showLinkPreviewDialog(_firstLink!),
                      errorWidget: Container(
                        height: 80,
                        width: double.infinity,
                        color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                        child: Row(
                          children: [
                            const SizedBox(width: 12),
                            Icon(
                              Icons.link,
                              color: isDarkMode ? Colors.white70 : Colors.black54,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Visit website',
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.white : Colors.black87,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _firstLink!,
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.white70 : Colors.black54,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tap to open preview',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
          // Post image if available
          if (_isValidImageUrl(widget.post.imageUrl))
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 400),
              child: Image.network(
                widget.post.imageUrl!,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.error_outline, size: 40),
                    ),
                  );
                },
              ),
            ),
          // Likes count
          Padding(
            padding:
                const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 4),
            child: Row(
              children: [
                Icon(
                  Icons.thumb_up,
                  size: 14,
                  color: isDarkMode ? Colors.white70 : Colors.grey[700],
                ),
                const SizedBox(width: 4),
                Text(
                  '${widget.post.likeCount}',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDarkMode ? Colors.white70 : Colors.grey[700],
                  ),
                ),
                const Spacer(),
                if (widget.post.commentCount > 0)
                  Text(
                    '${widget.post.commentCount} comments',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDarkMode ? Colors.white70 : Colors.grey[700],
                    ),
                  ),
              ],
            ),
          ),

          // Divider
          Divider(
              height: 1,
              thickness: 1,
              color: isDarkMode ? Colors.grey[800] : Colors.grey[300]),

          // Like, comment, share buttons
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Tree-themed like button with text
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        // Update local state immediately for better UX
                        setState(() {
                          _isLiked = !_isLiked;
                        });

                        // Call the parent's onLike callback
                        widget.onLike();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GroveLikeButton(
                              key: ValueKey('grove_like_${widget.post.id}'),
                              size: 28,
                              initialLiked: _isLiked, // Use local state
                              // Don't use onLikeChanged to avoid duplicate calls
                              onLikeChanged: null,
                              animationDuration:
                                  const Duration(milliseconds: 600),
                              trunkColor: Colors.brown.shade600,
                              rootColor: Colors.brown.shade800,
                              leafColor: Colors.lightGreen.shade400,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Like',
                              style: TextStyle(
                                fontSize: 14,
                                color: _isLiked
                                    ? Colors.green.shade700
                                    : isDarkMode
                                        ? Colors.white70
                                        : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Comment button with seed animation
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        // Toggle comment state locally
                        setState(() {
                          _isCommented = !_isCommented;
                        });

                        // Call the parent's onComment callback
                        widget.onComment();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SeedCommentButton(
                              key: ValueKey('seed_comment_${widget.post.id}'),
                              size: 28,
                              initialCommented:
                                  _isCommented, // Use local comment state
                              // Don't use onCommentedChanged to avoid duplicate calls
                              onCommentedChanged: null,
                              animationDuration:
                                  const Duration(milliseconds: 600),
                              seedColor: Colors.brown.shade600,
                              sproutColor: Colors.green.shade400,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Comment',
                              style: TextStyle(
                                fontSize: 14,
                                color: _isCommented
                                    ? Colors.green.shade700
                                    : isDarkMode
                                        ? Colors.white70
                                        : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Share button
                if (widget.onShare != null)
                  Expanded(
                    child: InkWell(
                      onTap: widget.onShare,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.share_outlined,
                            color:
                                isDarkMode ? Colors.white70 : Colors.grey[700],
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Share',
                            style: TextStyle(
                              color: isDarkMode
                                  ? Colors.white70
                                  : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // No longer needed action button builder as we've implemented custom buttons
}
