import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:any_link_preview/any_link_preview.dart';
import 'package:immigru/core/logging/unified_logger.dart';
import 'package:immigru/core/storage/supabase_storage_utils.dart';
import 'package:immigru/features/home/domain/entities/post.dart';
import 'package:immigru/features/home/presentation/bloc/home_bloc.dart';
import 'package:immigru/shared/widgets/in_app_browser.dart';
import 'package:immigru/shared/widgets/post_interaction/post_interaction_bar.dart';
import 'package:immigru/shared/widgets/post_interaction/post_options_menu.dart';
import 'package:immigru/shared/handlers/post_action_handlers.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:get_it/get_it.dart';

/// A unified post card that can be used in both profile and home feed
/// This ensures consistent styling and behavior across the app
class UnifiedPostCard extends StatefulWidget {
  final Post post;
  final String userId;
  final Function(Post) onPostUpdated;
  final Function(Post)? onPostDeleted;
  final String tag;
  final bool showShareButton;
  final HomeBloc? homeBloc;

  const UnifiedPostCard({
    super.key,
    required this.post,
    required this.userId,
    required this.onPostUpdated,
    this.onPostDeleted,
    required this.tag,
    this.showShareButton = true,
    this.homeBloc,
  });

  @override
  State<UnifiedPostCard> createState() => _UnifiedPostCardState();
}

class _UnifiedPostCardState extends State<UnifiedPostCard> {
  final UnifiedLogger _logger = GetIt.instance<UnifiedLogger>();
  final SupabaseStorageUtils _storageUtils = SupabaseStorageUtils.instance;
  
  String? _firstLink;
  late PostActionHandlers _actionHandlers;
  late bool _isCurrentUserAuthor;
  
  @override
  void initState() {
    super.initState();
    _extractLinks();
    _isCurrentUserAuthor = widget.post.userId == widget.userId;
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize action handlers with the current context
    _actionHandlers = PostActionHandlers(
      context: context,
      tag: widget.tag,
      userId: widget.userId,
      homeBloc: widget.homeBloc,
      onPostUpdated: widget.onPostUpdated,
      onPostDeleted: widget.onPostDeleted,
    );
  }
  
  @override
  void didUpdateWidget(UnifiedPostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update link extraction if the post content changed
    if (oldWidget.post.content != widget.post.content) {
      _extractLinks();
    }
    
    // Update author check if the post userId or current userId changed
    if (oldWidget.post.userId != widget.post.userId || 
        oldWidget.userId != widget.userId) {
      _isCurrentUserAuthor = widget.post.userId == widget.userId;
    }
  }
  
  /// Extracts the first valid URL from the post content
  void _extractLinks() {
    try {
      // Skip extraction if content is empty
      if (widget.post.content.isEmpty) {
        return;
      }
      
      // More comprehensive regex for better matching
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
            _logger.d('Extracted link from post: $_firstLink', tag: widget.tag);
          }
        }
      }
    } catch (e) {
      _logger.e('Error extracting links: $e', tag: widget.tag);
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
        style: const TextStyle(
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
  
  /// Opens a link in the in-app browser
  void _openLinkInAppBrowser(String url) {
    _logger.d('Opening link in app browser: $url', tag: widget.tag);
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
    return _storageUtils.isValidImageUrl(url);
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
                      ? NetworkImage(_storageUtils.getImageUrl(widget.post.userAvatar!))
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
                PostOptionsMenu(
                  post: widget.post,
                  isCurrentUserAuthor: _isCurrentUserAuthor,
                  onShare: () => _actionHandlers.handleShare(widget.post),
                  onEdit: _isCurrentUserAuthor ? () => _actionHandlers.handleEdit(widget.post) : null,
                  onDelete: _isCurrentUserAuthor ? () => _actionHandlers.handleDelete(widget.post) : null,
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
                onTap: () => _openLinkInAppBrowser(_firstLink!),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AnyLinkPreview(
                      link: _firstLink!,
                      displayDirection: UIDirection.uiDirectionVertical,
                      showMultimedia: true,
                      bodyMaxLines: 3,
                      previewHeight: 200,
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
                      borderRadius: 0,
                      removeElevation: true,
                      cache: const Duration(days: 7),
                      onTap: () => _openLinkInAppBrowser(_firstLink!),
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
                _storageUtils.getImageUrl(widget.post.imageUrl!),
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
          // Engagement stats (likes and comments)
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 4),
            child: Row(
              children: [
                // Only show if there are likes
                if (widget.post.likeCount > 0) ...[  
                  Row(
                    children: [
                      Icon(
                        Icons.favorite,
                        size: 14,
                        color: widget.post.isLiked ? Colors.green.shade600 : (isDarkMode ? Colors.white70 : Colors.grey[700]),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.post.likeCount}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDarkMode ? Colors.white70 : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ],
                
                if (widget.post.likeCount > 0 && widget.post.commentCount > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '•',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.grey[700],
                      ),
                    ),
                  ),
                  
                // Only show if there are comments
                if (widget.post.commentCount > 0) ...[  
                  Row(
                    children: [
                      Icon(
                        Icons.comment,
                        size: 14,
                        color: widget.post.hasUserComment ? Colors.green.shade600 : (isDarkMode ? Colors.white70 : Colors.grey[700]),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.post.commentCount} ${widget.post.commentCount == 1 ? 'comment' : 'comments'}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDarkMode ? Colors.white70 : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ],
                
                const Spacer(),
              ],
            ),
          ),

          // Divider
          Divider(
              height: 1,
              thickness: 1,
              color: isDarkMode ? Colors.grey[800] : Colors.grey[300]),

          // Like, comment, share buttons
          PostInteractionBar(
            post: widget.post,
            onLike: () => _actionHandlers.handleLike(widget.post),
            onComment: () => _actionHandlers.handleComment(widget.post),
            onShare: widget.showShareButton ? () => _actionHandlers.handleShare(widget.post) : null,
            showShareButton: widget.showShareButton,
          ),
        ],
      ),
    );
  }
}
