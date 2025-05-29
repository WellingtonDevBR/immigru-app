import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:immigru/core/storage/supabase_storage_utils.dart';
import 'package:immigru/features/home/domain/entities/post.dart';
import 'package:immigru/shared/widgets/media/media_gallery_viewer.dart';
import 'package:immigru/features/home/domain/entities/post_media.dart';
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
  late bool _isCommented; // Track comment state locally
  
  // We'll rely on the animation widgets to handle their own animations
  // based on state changes
  
  String? _firstLink;
  final _logger = Logger();
  
  // Track if the current user is the post author
  bool _isCurrentUserAuthor = false;
  String? _currentUserId;

  // Storage utils for handling image URLs
  final _storageUtils = SupabaseStorageUtils.instance;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.isLiked;
    
    // Initialize comment state based on whether the user has commented on this post
    _isCommented = widget.post.hasUserComment;
    
    // Log initialization for debugging
    _logger.d('Initializing post card: id=${widget.post.id}, ' 
             'likes=${widget.post.likeCount}, comments=${widget.post.commentCount}, ' 
             'hasMedia=${widget.post.media != null && widget.post.media!.isNotEmpty}');
    
    // Log detailed media information if available
    if (widget.post.media != null && widget.post.media!.isNotEmpty) {
      _logger.d('Post has ${widget.post.media!.length} media items:');
      for (var i = 0; i < widget.post.media!.length; i++) {
        final media = widget.post.media![i];
        _logger.d('Media[$i]: id=${media.id}, path=${media.path}, type=${media.type}');
      }
    }
    
    _extractLinks();
    
    // Check if the current user is the author of this post
    final supabase = Supabase.instance.client;
    _currentUserId = supabase.auth.currentUser?.id;
    _isCurrentUserAuthor = _currentUserId != null && _currentUserId == widget.post.userId;
  }
  
  // Note: didUpdateWidget is defined below to update state when post data changes
  
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
    return _storageUtils.isValidImageUrl(url);
  }
  
  /// Builds an image widget with proper error handling and fallback
  Widget _buildImageWithFallback(String imagePath, {String? displayName, BoxFit fit = BoxFit.cover}) {
    _logger.d('Building image with path: $imagePath');
    
    // Handle case where the imagePath might be a JSON string
    String processedPath = imagePath;
    if (imagePath.startsWith('[') && imagePath.contains('{') && imagePath.contains('}')) {
      try {
        final List<dynamic> mediaList = json.decode(imagePath) as List<dynamic>;
        if (mediaList.isNotEmpty && mediaList[0] is Map<String, dynamic>) {
          final Map<String, dynamic> mediaItem = mediaList[0] as Map<String, dynamic>;
          // Check for different possible path field names
          if (mediaItem.containsKey('path')) {
            processedPath = mediaItem['path'] as String;
            _logger.d('Extracted path from JSON using "path" key: $processedPath');
          } else if (mediaItem.containsKey('MediaUrl')) {
            processedPath = mediaItem['MediaUrl'] as String;
            _logger.d('Extracted path from JSON using "MediaUrl" key: $processedPath');
          } else if (mediaItem.containsKey('URL')) {
            processedPath = mediaItem['URL'] as String;
            _logger.d('Extracted path from JSON using "URL" key: $processedPath');
          }
        }
      } catch (e) {
        _logger.e('Error parsing JSON in image path: $e');
        // Keep the original path if JSON parsing fails
      }
    }
    
    // Ensure the path is not empty after processing
    if (processedPath.isEmpty) {
      _logger.e('Empty image path after processing');
      return _buildImagePlaceholder('No image available');
    }
    
    // Ensure URL is properly formatted for Supabase storage
    if (processedPath.contains('supabase.co/storage/v1/object') && !processedPath.startsWith('http')) {
      processedPath = 'https://$processedPath';
      _logger.d('Added https prefix to Supabase URL: $processedPath');
    }
    
    final imageUrl = _storageUtils.getImageUrl(processedPath, displayName: displayName);
    _logger.d('Resolved image URL: $imageUrl');
    
    // Enhanced headers for Supabase storage
    final headers = <String, String>{
      'Accept': 'image/jpeg, image/png, image/webp, image/*',
    };
    
    // Add cache control for better performance
    if (imageUrl.contains('supabase.co/storage/v1/object')) {
      headers['Cache-Control'] = 'max-age=3600';
    }
    
    // Use Image.network with headers to handle content type issues
    return Image.network(
      imageUrl,
      fit: fit,
      headers: headers,
      // Retry failed images
      cacheWidth: 800, // Optimize memory usage
      errorBuilder: (context, error, stackTrace) {
        _logger.e('Error loading image: $error', error: error, stackTrace: stackTrace);
        _logger.e('Failed image path: $imagePath, resolved URL: $imageUrl');
        
        // Return a fallback image or placeholder
        return Container(
          color: Colors.grey[200],
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.image_not_supported_outlined, size: 40, color: Colors.grey[600]),
                const SizedBox(height: 8),
                Text(
                  'Image not available',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 4),
                // More descriptive error message
                Text(
                  error.toString().contains('404') ? 'Image not found' : 
                  error.toString().contains('403') ? 'Access denied' : 
                  'Content type issue',
                  style: TextStyle(color: Colors.grey[500], fontSize: 10),
                ),
                const SizedBox(height: 4),
                Text(
                  'Path: ${imagePath.length > 30 ? '${imagePath.substring(0, 30)}...' : imagePath}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 10),
                ),
              ],
            ),
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        
        return Container(
          color: Colors.grey[100],
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
            ),
          ),
        );
      },
    );
  }
  
  /// Builds a gallery view for multiple media items in a mosaic grid layout
  Widget _buildMediaGallery(List<PostMedia> mediaItems) {
    _logger.d('Building media gallery with ${mediaItems.length} items');
    
    // Process media items to ensure valid paths
    final validMediaItems = mediaItems.where((media) {
      // Basic validation - must have a non-empty path
      if (media.path.isEmpty) {
        _logger.e('Skipping media item with empty path: id=${media.id}');
        return false;
      }
      
      // Log the media item for debugging
      _logger.d('Processing media item: id=${media.id}, path=${media.path}, type=${media.type}');
      
      // Accept all non-empty paths - we'll handle JSON strings in _buildImageWithFallback
      return true;
    }).toList();
    
    if (validMediaItems.isEmpty) {
      _logger.e('No valid media items found after filtering');
      return const SizedBox.shrink(); // Return empty widget if no valid media
    }
    
    // Log all valid media items that will be displayed
    for (var i = 0; i < validMediaItems.length; i++) {
      final media = validMediaItems[i];
      _logger.d('Valid media[$i]: id=${media.id}, path=${media.path}, type=${media.type}');
    }
    
    // If there's only one media item, display it full width
    if (validMediaItems.length == 1) {
      final media = validMediaItems.first;
      _logger.d('Displaying single media item: ${media.path}');
      
      if (media.type == MediaType.video) {
        // TODO: Implement video player when needed
        _logger.d('Media is video, showing placeholder');
        return Container(
          width: double.infinity,
          height: 300,
          color: Colors.grey[200],
          child: const Center(
            child: Icon(Icons.video_library, size: 48, color: Colors.grey),
          ),
        );
      } else {
        // Display single image with click to zoom
        _logger.d('Media is image, building image with path: ${media.path}');
        return GestureDetector(
          onTap: () => _openImageGallery(media),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 400),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Hero(
                tag: 'media_${media.id}',
                child: _buildImageWithFallback(media.path),
              ),
            ),
          ),
        );
      }
    }
    
    // For 2 media items, display them side by side
    if (validMediaItems.length == 2) {
      return SizedBox(
        height: 200,
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 2),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                  child: _buildMediaItem(validMediaItems[0]),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 2),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  child: _buildMediaItem(validMediaItems[1]),
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    // For 3 media items, display 1 large on left, 2 stacked on right
    if (validMediaItems.length == 3) {
      return SizedBox(
        height: 300,
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(right: 2),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                  child: _buildMediaItem(validMediaItems[0]),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 2, bottom: 2),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(8),
                        ),
                        child: _buildMediaItem(validMediaItems[1]),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 2, top: 2),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(8),
                        ),
                        child: _buildMediaItem(validMediaItems[2]),
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
    
    // For 4 media items, display in a 2x2 grid
    if (validMediaItems.length == 4) {
      return SizedBox(
        height: 300,
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 2, bottom: 2),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                        ),
                        child: _buildMediaItem(validMediaItems[0]),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 2, bottom: 2),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(8),
                        ),
                        child: _buildMediaItem(validMediaItems[1]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 2, top: 2),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                        ),
                        child: _buildMediaItem(validMediaItems[2]),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 2, top: 2),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(8),
                        ),
                        child: _buildMediaItem(validMediaItems[3]),
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
    
    // For 5 or more media items, show first 4 in a grid with a +X overlay on the last one
    final remainingCount = validMediaItems.length - 4;
    
    return SizedBox(
      height: 300,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 2, bottom: 2),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                      ),
                      child: _buildMediaItem(validMediaItems[0]),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 2, bottom: 2),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(8),
                      ),
                      child: _buildMediaItem(validMediaItems[1]),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 2, top: 2),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                      ),
                      child: _buildMediaItem(validMediaItems[2]),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 2, top: 2),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(8),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _buildMediaItem(validMediaItems[3]),
                          if (remainingCount > 0)
                            Container(
                              color: Colors.black.withOpacity(0.5),
                              child: Center(
                                child: Text(
                                  '+$remainingCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
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
  
  /// Helper method to build a media item (image or video)
  Widget _buildMediaItem(PostMedia media) {
    if (media.type == MediaType.video) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Container(color: Colors.black54),
          const Center(
            child: Icon(Icons.play_circle_outline, size: 48, color: Colors.white),
          ),
        ],
      );
    } else {
      // Make the image clickable to open the gallery viewer
      return GestureDetector(
        onTap: () {
          _openImageGallery(media);
        },
        child: Hero(
          tag: 'media_${media.id}',
          child: _buildImageWithFallback(
            media.path,
            fit: BoxFit.cover,
          ),
        ),
      );
    }
  }
  
  /// Opens the image gallery viewer for a specific media item
  void _openImageGallery(PostMedia selectedMedia) {
    _logger.d('Opening gallery for media: ${selectedMedia.path}');
    
    // Find the index of the selected media in the post's media list
    final mediaItems = widget.post.media ?? [];
    if (mediaItems.isEmpty) {
      _logger.w('Cannot open gallery: post has no media items');
      return;
    }
    
    // Find the index of the selected media
    final selectedIndex = mediaItems.indexWhere((m) => m.id == selectedMedia.id);
    final initialIndex = selectedIndex >= 0 ? selectedIndex : 0;
    
    // Show the gallery viewer
    showMediaGallery(context, mediaItems, initialIndex: initialIndex);
  }

  /// Builds a placeholder widget for when an image can't be displayed
  Widget _buildImagePlaceholder(String message) {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image_not_supported_outlined, size: 40, color: Colors.grey[600]),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update local state if the post data has changed
    if (oldWidget.post.isLiked != widget.post.isLiked ||
        oldWidget.post.likeCount != widget.post.likeCount ||
        oldWidget.post.hasUserComment != widget.post.hasUserComment ||
        oldWidget.post.commentCount != widget.post.commentCount) {
      
      setState(() {
        _isLiked = widget.post.isLiked;
        _isCommented = widget.post.hasUserComment;
      });
      
      _logger.d('Post data updated: isLiked=$_isLiked, isCommented=$_isCommented, ' 'likeCount=${widget.post.likeCount}, commentCount=${widget.post.commentCount}');
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
            
          // Post media if available
          if (widget.post.media != null && widget.post.media!.isNotEmpty) ...[  
            // Log that we're trying to build media gallery
            Builder(builder: (context) {
              _logger.d('Attempting to build media gallery for post ${widget.post.id}');
              return _buildMediaGallery(widget.post.media!);
            }),
          ]
          // Legacy support for posts with only imageUrl
          else if (_isValidImageUrl(widget.post.imageUrl)) ...[  
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 400),
              child: _buildImageWithFallback(
                widget.post.imageUrl!,
                displayName: widget.post.userName,
              ),
            ),
          ],
          // Engagement stats (likes and comments)
          Padding(
            padding:
                const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 4),
            child: Row(
              children: [
                // Only show if there are likes
                if (widget.post.likeCount > 0) ...[  
                  Row(
                    children: [
                      Icon(
                        Icons.favorite,
                        size: 14,
                        color: _isLiked ? Colors.green.shade600 : (isDarkMode ? Colors.white70 : Colors.grey[700]),
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
                        color: _isCommented ? Colors.green.shade600 : (isDarkMode ? Colors.white70 : Colors.grey[700]),
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
                        
                        // Log the action for performance tracking
                        _logger.d('Like button tapped. New state: $_isLiked');
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Use animated icon with scale effect for better visual feedback
                            AnimatedScale(
                              scale: _isLiked ? 1.2 : 1.0,
                              duration: const Duration(milliseconds: 200),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                child: Icon(
                                  _isLiked ? Icons.favorite : Icons.favorite_border,
                                  color: _isLiked ? Colors.green.shade600 : Colors.grey[600],
                                  size: 24,
                                ),
                              ),
                            ),
                            
                            const SizedBox(width: 6),
                            Flexible(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
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
                                  if (widget.post.likeCount > 0) ...[  
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _isLiked ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '${widget.post.likeCount}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: _isLiked ? Colors.green.shade700 : Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
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
                        // Do not toggle comment state locally - this should be controlled by the post data
                        // The state will be updated in didUpdateWidget when the post is refreshed
                        
                        // Call the parent's onComment callback
                        widget.onComment();
                        
                        // Log the action for performance tracking
                        _logger.d('Comment button tapped');
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Use animated icon with scale effect for better visual feedback
                            AnimatedScale(
                              scale: _isCommented ? 1.2 : 1.0,
                              duration: const Duration(milliseconds: 200),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                child: Icon(
                                  _isCommented ? Icons.comment : Icons.comment_outlined,
                                  color: _isCommented ? Colors.green.shade600 : Colors.grey[600],
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
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
                                  if (widget.post.commentCount > 0) ...[  
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _isCommented ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '${widget.post.commentCount}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: _isCommented ? Colors.green.shade700 : Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
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
