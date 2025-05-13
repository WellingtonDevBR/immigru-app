import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:immigru/presentation/blocs/onboarding/onboarding_bloc.dart';
import 'package:immigru/presentation/blocs/onboarding/onboarding_event.dart';
import 'package:immigru/presentation/theme/app_colors.dart';

/// Widget for the basic info step in profile setup as part of onboarding
class BasicInfoStep extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String photoUrl;

  const BasicInfoStep({
    super.key,
    required this.firstName,
    required this.lastName,
    this.photoUrl = '',
  });

  @override
  State<BasicInfoStep> createState() => _BasicInfoStepState();
}

class _BasicInfoStepState extends State<BasicInfoStep> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  final _formKey = GlobalKey<FormState>();
  File? _selectedImage;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.firstName);
    _lastNameController = TextEditingController(text: widget.lastName);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      color: isDarkMode ? AppColors.darkBackground : Colors.white,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            onChanged: _updateBasicInfo,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Privacy notice
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: AppColors.primaryColor.withOpacity(0.3),
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
                              'We value your privacy. Your profile information is stored securely and you\'ll be able to control who can see your details. You can adjust privacy settings in the next step.',
                              style: TextStyle(
                                color: isDarkMode
                                    ? Colors.white70
                                    : Colors.black87,
                                fontSize: 14.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32.0),
                
                // Profile photo
                Center(
                  child: _buildProfilePhoto(isDarkMode),
                ),
                const SizedBox(height: 16.0),
                
                // Photo upload buttons
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Camera button
                      ElevatedButton.icon(
                        onPressed: _isUploading ? null : () => _pickImage(ImageSource.camera),
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
                        onPressed: _isUploading ? null : () => _pickImage(ImageSource.gallery),
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
                  const SizedBox(height: 8.0),
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
                
                // First name field
                _buildTextField(
                  label: 'First name',
                  controller: _firstNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                  isRequired: true,
                ),
                const SizedBox(height: 16.0),
                
                // Last name field
                _buildTextField(
                  label: 'Last name',
                  controller: _lastNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your last name';
                    }
                    return null;
                  },
                  isRequired: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build a text field with label and validation
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16.0,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4.0),
              Text(
                '*',
                style: TextStyle(
                  color: Colors.red[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8.0),
        TextFormField(
          controller: controller,
          validator: validator,
          decoration: InputDecoration(
            hintText: 'Enter your ${label.toLowerCase()}',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: Colors.grey[400]!,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 14.0,
            ),
          ),
          textInputAction: TextInputAction.next,
          onChanged: (_) => _updateBasicInfo(),
        ),
      ],
    );
  }

  /// Update basic info in the onboarding bloc
  void _updateBasicInfo() {
    if (_formKey.currentState?.validate() ?? false) {
      // Use the ProfileBasicInfoUpdated event from OnboardingBloc
      context.read<OnboardingBloc>().add(
        ProfileBasicInfoUpdated(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
        ),
      );
    }
  }

  /// Build the profile photo widget
  Widget _buildProfilePhoto(bool isDarkMode) {
    // If there's a selected image, show it
    if (_selectedImage != null) {
      return Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: FileImage(_selectedImage!),
          ),
          if (_isUploading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
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
        radius: 60,
        backgroundImage: NetworkImage(widget.photoUrl),
      );
    }
    
    // Otherwise, show a placeholder
    return CircleAvatar(
      radius: 60,
      backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
      child: Icon(
        Icons.person,
        size: 60,
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
      // In a real implementation, this would upload the image to a storage service
      // and then get back a URL to store in the profile
      
      // Simulate upload delay
      await Future.delayed(const Duration(seconds: 1));
      
      // For now, we'll just use a placeholder URL
      const photoUrl = 'https://example.com/profile-photo.jpg';
      
      // Update the profile with the photo URL
      context.read<OnboardingBloc>().add(
        const ProfilePhotoUpdated(photoUrl),
      );
    } catch (e) {
      // Show error snackbar
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
