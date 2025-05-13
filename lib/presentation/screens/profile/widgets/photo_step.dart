import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:immigru/presentation/blocs/profile/profile_bloc.dart';
import 'package:immigru/presentation/blocs/profile/profile_event.dart';
import 'package:immigru/presentation/theme/app_colors.dart';
import 'package:immigru/presentation/widgets/loading_indicator.dart';

/// Widget for the photo step in profile setup
class PhotoStep extends StatefulWidget {
  final String? photoUrl;
  final bool isUploading;

  const PhotoStep({
    super.key,
    this.photoUrl,
    required this.isUploading,
  });

  @override
  State<PhotoStep> createState() => _PhotoStepState();
}

class _PhotoStepState extends State<PhotoStep> {
  File? _selectedImage;

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
              // Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.primaryColor,
                      width: 2.0,
                    ),
                  ),
                ),
                child: Text(
                  'Add Profile Photo',
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              
              // Photo explanation
              Text(
                'Adding a profile photo helps community members recognize you and builds trust. Choose a clear photo that represents you well.',
                style: TextStyle(
                  fontSize: 16.0,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 32.0),
              
              // Profile photo preview
              Center(
                child: _buildProfilePhotoPreview(isDarkMode),
              ),
              const SizedBox(height: 24.0),
              
              // Photo upload buttons
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildPhotoButton(
                      icon: Icons.photo_library,
                      label: 'Gallery',
                      onPressed: widget.isUploading
                          ? null
                          : () => _pickImage(ImageSource.gallery),
                    ),
                    const SizedBox(width: 16.0),
                    _buildPhotoButton(
                      icon: Icons.camera_alt,
                      label: 'Camera',
                      onPressed: widget.isUploading
                          ? null
                          : () => _pickImage(ImageSource.camera),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32.0),
              
              // Photo guidelines
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.primaryColor,
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          'Photo Guidelines',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.0),
                    _buildGuidelineItem(
                      'Use a clear, well-lit photo of yourself',
                      isDarkMode,
                    ),
                    _buildGuidelineItem(
                      'Make sure your face is visible',
                      isDarkMode,
                    ),
                    _buildGuidelineItem(
                      'Avoid using logos or group photos',
                      isDarkMode,
                    ),
                    _buildGuidelineItem(
                      'Square photos work best',
                      isDarkMode,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              
              // Optional note
              Center(
                child: Text(
                  'This step is optional. You can skip it if you prefer.',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontStyle: FontStyle.italic,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the profile photo preview
  Widget _buildProfilePhotoPreview(bool isDarkMode) {
    // If uploading, show loading indicator
    if (widget.isUploading) {
      return Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: LoadingIndicator(),
        ),
      );
    }
    
    // If there's a selected image, show it
    if (_selectedImage != null) {
      return Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: FileImage(_selectedImage!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }
    
    // If there's a photo URL, show it
    if (widget.photoUrl != null && widget.photoUrl!.isNotEmpty) {
      return Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: NetworkImage(widget.photoUrl!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }
    
    // Otherwise, show placeholder
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.person,
          size: 80,
          color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
        ),
      ),
    );
  }

  /// Build a photo button
  Widget _buildPhotoButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
      ),
    );
  }

  /// Build a guideline item with bullet point
  Widget _buildGuidelineItem(String text, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.0,
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Pick an image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        
        // Upload the image
        context.read<ProfileBloc>().add(
          ProfilePhotoUploaded(pickedFile.path),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
