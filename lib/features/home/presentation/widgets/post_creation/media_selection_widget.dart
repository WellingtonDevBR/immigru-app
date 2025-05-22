import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:immigru/core/logging/unified_logger.dart';
import 'package:immigru/features/home/data/models/post_media_model.dart';
import 'package:immigru/features/home/presentation/bloc/post_creation/post_creation_bloc.dart';
import 'package:immigru/features/home/presentation/bloc/post_creation/post_creation_event.dart';
import 'package:immigru/shared/theme/app_colors.dart';

/// Widget for selecting media (images/videos) for a post
class MediaSelectionWidget extends StatelessWidget {
  final ImagePicker _imagePicker = ImagePicker();
  final UnifiedLogger _logger = UnifiedLogger();

  MediaSelectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Row(
      children: [
        _buildMediaButton(
          context: context,
          icon: Icons.image_outlined,
          label: 'Photo',
          color: AppColors.sproutGreen,
          onTap: () {
            HapticFeedback.lightImpact();
            _pickImage(context);
          },
        ),
        const SizedBox(width: 12),
        _buildMediaButton(
          context: context,
          icon: Icons.videocam_outlined,
          label: 'Video',
          color: AppColors.skyBlue,
          onTap: () {
            HapticFeedback.lightImpact();
            _pickVideo(context);
          },
        ),
      ],
    );
  }

  /// Build a styled media selection button
  Widget _buildMediaButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  /// Show options to pick image from gallery or take a photo with camera
  Future<void> _pickImage(BuildContext context) async {
    _logger.d('Add photo button pressed', tag: 'MediaSelectionWidget');

    // Show bottom sheet with options
    await showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from gallery'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _getImageFromSource(context, ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take a photo'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _getImageFromSource(context, ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Show options to pick video from gallery or record with camera
  Future<void> _pickVideo(BuildContext context) async {
    _logger.d('Add video button pressed', tag: 'MediaSelectionWidget');

    // Show bottom sheet with options
    await showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.video_library),
                  title: const Text('Choose from gallery'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _getVideoFromSource(context, ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.videocam),
                  title: const Text('Record a video'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _getVideoFromSource(context, ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Get image from the specified source (gallery or camera)
  Future<void> _getImageFromSource(
      BuildContext context, ImageSource source) async {
    try {
      _logger.d('Attempting to pick image from ${source.name}', tag: 'MediaSelectionWidget');
      
      // Show loading indicator
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Selecting image...'),
          duration: Duration(seconds: 1),
        ),
      );
      
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 70, // Slightly lower quality to reduce file size
        maxWidth: 1200,   // Limit max dimensions to avoid huge images
        maxHeight: 1200,
      );

      if (pickedFile != null) {
        _logger.d('Image picked: ${pickedFile.path}', tag: 'MediaSelectionWidget');
        
        // Verify the file exists before adding to state
        final file = File(pickedFile.path);
        final exists = await file.exists();
        _logger.d('File exists: $exists', tag: 'MediaSelectionWidget');
        
        if (exists) {
          final fileSize = await file.length();
          _logger.d('Image file size: $fileSize bytes', tag: 'MediaSelectionWidget');

          // Create a PostMediaModel from the picked file
          final media = PostMediaModel.fromPath(pickedFile.path);
          _logger.d('Created media model: ${media.name} (${media.path})', tag: 'MediaSelectionWidget');

          // Add the media to the bloc
          if (context.mounted) {
            context.read<PostCreationBloc>().add(MediaAdded(media));
            
            // Show success message
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: const Text('Image selected successfully'),
                backgroundColor: Colors.green[700],
                duration: const Duration(seconds: 1),
              ),
            );
            
            // Log the current state after a short delay
            Future.delayed(const Duration(milliseconds: 500), () {
              if (context.mounted) {
                final state = context.read<PostCreationBloc>().state;
                _logger.d('Current media count in state: ${state.media.length}', tag: 'MediaSelectionWidget');
              }
            });
          }
        } else {
          _logger.e('Image file does not exist: ${pickedFile.path}', tag: 'MediaSelectionWidget');
          if (context.mounted) {
            scaffoldMessenger.showSnackBar(
              const SnackBar(
                content: Text('Error: Selected image file not found'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        _logger.d('No image selected', tag: 'MediaSelectionWidget');
        if (context.mounted) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('No image was selected'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      _logger.e('Error picking image: $e', tag: 'MediaSelectionWidget');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Get video from the specified source (gallery or camera)
  Future<void> _getVideoFromSource(
      BuildContext context, ImageSource source) async {
    try {
      _logger.d('Attempting to pick video from ${source.name}', tag: 'MediaSelectionWidget');
      
      // Show loading indicator
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Selecting video...'),
          duration: Duration(seconds: 1),
        ),
      );
      
      final XFile? pickedFile = await _imagePicker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 2), // Reduced from 5 to 2 minutes
      );

      if (pickedFile != null) {
        _logger.d('Video picked: ${pickedFile.path}', tag: 'MediaSelectionWidget');
        
        // Verify the file exists before adding to state
        final file = File(pickedFile.path);
        final exists = await file.exists();
        _logger.d('File exists: $exists', tag: 'MediaSelectionWidget');
        
        if (exists) {
          final fileSize = await file.length();
          _logger.d('Video file size: $fileSize bytes', tag: 'MediaSelectionWidget');

          // Check if video is too large (>30MB instead of 50MB)
          if (fileSize > 30 * 1024 * 1024) {
            _logger.w('Video file too large: $fileSize bytes', tag: 'MediaSelectionWidget');
            if (context.mounted) {
              scaffoldMessenger.showSnackBar(
                const SnackBar(
                  content: Text('Video is too large (max 30MB)'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
            return;
          }

          // Create a PostMediaModel from the picked file
          final media = PostMediaModel.fromPath(pickedFile.path);
          _logger.d('Created media model: ${media.name} (${media.path})', tag: 'MediaSelectionWidget');

          // Add the media to the bloc
          if (context.mounted) {
            context.read<PostCreationBloc>().add(MediaAdded(media));
            
            // Show success message
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: const Text('Video selected successfully'),
                backgroundColor: Colors.green[700],
                duration: const Duration(seconds: 1),
              ),
            );
            
            // Log the current state after a short delay
            Future.delayed(const Duration(milliseconds: 500), () {
              if (context.mounted) {
                final state = context.read<PostCreationBloc>().state;
                _logger.d('Current media count in state: ${state.media.length}', tag: 'MediaSelectionWidget');
              }
            });
          }
        } else {
          _logger.e('Video file does not exist: ${pickedFile.path}', tag: 'MediaSelectionWidget');
          if (context.mounted) {
            scaffoldMessenger.showSnackBar(
              const SnackBar(
                content: Text('Error: Selected video file not found'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        _logger.d('No video selected', tag: 'MediaSelectionWidget');
        if (context.mounted) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('No video was selected'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      _logger.e('Error picking video: $e', tag: 'MediaSelectionWidget');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting video: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
