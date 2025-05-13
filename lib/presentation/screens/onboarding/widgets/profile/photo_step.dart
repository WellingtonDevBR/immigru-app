import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:immigru/presentation/blocs/onboarding/onboarding_bloc.dart';
import 'package:immigru/presentation/blocs/onboarding/onboarding_event.dart';
import 'package:immigru/presentation/theme/app_colors.dart';

/// Widget for the photo step in profile setup as part of onboarding
class PhotoStep extends StatefulWidget {
  final String photoUrl;

  const PhotoStep({
    super.key,
    required this.photoUrl,
  });

  @override
  State<PhotoStep> createState() => _PhotoStepState();
}

class _PhotoStepState extends State<PhotoStep> {
  File? _selectedImage;
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      color: isDarkMode ? AppColors.darkBackground : Colors.white,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'Add a profile photo',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 12.0),

              // Subtitle
              Text(
                'Help others recognize you with a profile photo.',
                style: TextStyle(
                  fontSize: 16.0,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 32.0),

              // Profile photo
              Center(
                child: _buildProfilePhoto(isDarkMode),
              ),
              const SizedBox(height: 24.0),

              // Photo upload buttons
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Camera button
                    ElevatedButton.icon(
                      onPressed: _isUploading
                          ? null
                          : () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),

                    // Gallery button
                    OutlinedButton.icon(
                      onPressed: _isUploading
                          ? null
                          : () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryColor,
                        side: BorderSide(color: AppColors.primaryColor),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_selectedImage != null) ...[
                const SizedBox(height: 16.0),
                Center(
                  child: TextButton(
                    onPressed: _isUploading ? null : _removeImage,
                    child: Text(
                      'Remove Photo',
                      style: TextStyle(
                        color: Colors.red[700],
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32.0),

              // Tips
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Colors.amber[700],
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tips for a great profile photo',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.amber[700],
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          _buildTipItem(
                              'Choose a well-lit photo where your face is clearly visible'),
                          _buildTipItem('A neutral background works best'),
                          _buildTipItem(
                              'Smile! A friendly expression makes you more approachable'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),

              // Privacy notice
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: AppColors.primaryColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.privacy_tip_outlined,
                      color: AppColors.primaryColor,
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Privacy Notice',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            'Your profile photo will be visible to other community members. You can always change or remove it later.',
                            style: TextStyle(
                              color:
                                  isDarkMode ? Colors.white70 : Colors.black87,
                              fontSize: 14.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build a tip item with bullet point
  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16.0)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14.0),
            ),
          ),
        ],
      ),
    );
  }

  /// Build the profile photo widget
  Widget _buildProfilePhoto(bool isDarkMode) {
    // If there's a selected image, show it
    if (_selectedImage != null) {
      return Stack(
        children: [
          CircleAvatar(
            radius: 75,
            backgroundImage: FileImage(_selectedImage!),
          ),
          if (_isUploading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
        ],
      );
    }

    // If there's a photo URL, show it
    if (widget.photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 75,
        backgroundImage: NetworkImage(widget.photoUrl),
      );
    }

    // Otherwise, show a placeholder
    return CircleAvatar(
      radius: 75,
      backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
      child: Icon(
        Icons.person,
        size: 75,
        color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
      ),
    );
  }

  /// Pick an image from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedImage != null) {
        setState(() {
          _selectedImage = File(pickedImage.path);
        });

        // Upload the image and get the URL
        await _uploadImage();
      }
    } catch (e) {
      // Show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Remove the selected image
  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });

    // Update the profile with empty photo URL
    context.read<OnboardingBloc>().add(
          const ProfilePhotoUpdated(''),
        );
  }

  /// Upload the image to storage and update the profile
  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      // Simula upload
      await Future.delayed(const Duration(seconds: 1));

      // Substituir por URL real em produção
      const photoUrl = 'https://example.com/profile-photo.jpg';

      // Protege o uso do context após await
      if (mounted) {
        context.read<OnboardingBloc>().add(
              const ProfilePhotoUpdated(photoUrl),
            );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading photo: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }
}
