import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:immigru/core/logging/unified_logger.dart';
import 'package:immigru/features/home/domain/entities/post_media.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

/// A full-screen gallery viewer for media items with zoom capabilities
/// Allows users to view images in a carousel with pinch-to-zoom functionality
class MediaGalleryViewer extends StatefulWidget {
  /// List of media items to display in the gallery
  final List<PostMedia> mediaItems;

  /// Initial page index to show
  final int initialIndex;

  const MediaGalleryViewer({
    super.key,
    required this.mediaItems,
    this.initialIndex = 0,
  });

  @override
  State<MediaGalleryViewer> createState() => _MediaGalleryViewerState();
}

class _MediaGalleryViewerState extends State<MediaGalleryViewer> {
  late PageController _pageController;
  late int _currentIndex;
  final UnifiedLogger _logger = GetIt.instance<UnifiedLogger>();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);

    // Use a system UI overlay style that works well with dark backgrounds
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    _logger.d(
        'Initialized gallery viewer with ${widget.mediaItems.length} items, starting at index $_currentIndex',
        tag: 'MediaGalleryViewer');
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Restore system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Gallery with zoomable images
          PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            builder: _buildItem,
            itemCount: widget.mediaItems.length,
            loadingBuilder: (context, event) => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            pageController: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
              _logger.d('Gallery page changed to index $index',
                  tag: 'MediaGalleryViewer');
            },
          ),

          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),

          // Page indicator
          if (widget.mediaItems.length > 1)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${widget.mediaItems.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  PhotoViewGalleryPageOptions _buildItem(BuildContext context, int index) {
    final media = widget.mediaItems[index];

    _logger.d('Building gallery item at index $index: ${media.path}',
        tag: 'MediaGalleryViewer');

    // Handle different types of media paths
    String mediaPath = media.path;

    // For video thumbnails or unsupported media types, show a placeholder
    if (media.type == MediaType.video) {
      return PhotoViewGalleryPageOptions.customChild(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.videocam, color: Colors.white, size: 64),
              const SizedBox(height: 16),
              Text(
                'Video playback not supported in gallery view',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
              ),
            ],
          ),
        ),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 2,
      );
    }

    // For images, use PhotoView for zooming capabilities
    return PhotoViewGalleryPageOptions(
      imageProvider: NetworkImage(mediaPath),
      initialScale: PhotoViewComputedScale.contained,
      minScale: PhotoViewComputedScale.contained,
      maxScale: PhotoViewComputedScale.covered * 3,
      heroAttributes: PhotoViewHeroAttributes(tag: 'media_${media.id}'),
      errorBuilder: (context, error, stackTrace) {
        _logger.e('Error loading image in gallery: $error',
            tag: 'MediaGalleryViewer');
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.broken_image, color: Colors.white70, size: 64),
              const SizedBox(height: 16),
              Text(
                'Failed to load image',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Helper function to open the media gallery viewer
void showMediaGallery(BuildContext context, List<PostMedia> mediaItems,
    {int initialIndex = 0}) {
  if (mediaItems.isEmpty) return;

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => MediaGalleryViewer(
        mediaItems: mediaItems,
        initialIndex: initialIndex,
      ),
    ),
  );
}
