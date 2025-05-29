import 'dart:io';
import 'package:flutter/material.dart';
import 'package:immigru/features/home/domain/entities/post_media.dart';

/// A reusable component to display selected media items
class MediaDisplay extends StatelessWidget {
  /// List of media items to display
  final List<PostMedia> media;
  
  /// Callback when a media item is removed
  final Function(String) onRemoveMedia;

  const MediaDisplay({
    super.key,
    required this.media,
    required this.onRemoveMedia,
  });

  @override
  Widget build(BuildContext context) {
    if (media.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: media.length,
        itemBuilder: (context, index) {
          final mediaItem = media[index];
          return _buildMediaChip(context, mediaItem);
        },
      ),
    );
  }

  /// Build a media chip for the selected media list
  Widget _buildMediaChip(BuildContext context, PostMedia media) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Extract filename from path
    final fileName = media.name.length > 15
        ? '${media.name.substring(0, 12)}...'
        : media.name;

    // Determine if it's an image or video
    final isVideo = media.type == MediaType.video;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(7),
                bottomLeft: Radius.circular(7),
              ),
              child: SizedBox(
                width: 50,
                height: 50,
                child: _buildThumbnail(media.path, isVideo),
              ),
            ),

            // Filename and type icon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Icon(
                    isVideo ? Icons.videocam : Icons.image,
                    size: 16,
                    color: isVideo ? Colors.blue : Colors.green,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    fileName,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),

            // Remove button
            GestureDetector(
              onTap: () => onRemoveMedia(media.id),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(7),
                    bottomRight: Radius.circular(7),
                  ),
                ),
                child: Icon(
                  Icons.close,
                  size: 14,
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build a thumbnail for a media item
  Widget _buildThumbnail(String path, bool isVideo) {
    try {
      if (path.startsWith('http')) {
        // Network image
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              path,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildErrorThumbnail();
              },
            ),
            if (isVideo)
              const Center(
                child: Icon(
                  Icons.play_circle_outline,
                  color: Colors.white,
                  size: 24,
                ),
              ),
          ],
        );
      } else {
        // Local file
        final file = File(path);
        if (file.existsSync()) {
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.file(
                file,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildErrorThumbnail();
                },
              ),
              if (isVideo)
                const Center(
                  child: Icon(
                    Icons.play_circle_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
            ],
          );
        } else {
          return _buildErrorThumbnail();
        }
      }
    } catch (e) {
      return _buildErrorThumbnail();
    }
  }

  /// Build a placeholder for when the thumbnail can't be loaded
  Widget _buildErrorThumbnail() {
    return Container(
      color: Colors.grey[800],
      child: const Center(
        child: Icon(
          Icons.broken_image,
          color: Colors.white54,
          size: 20,
        ),
      ),
    );
  }
}
