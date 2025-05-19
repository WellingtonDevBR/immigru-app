import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:immigru/core/di/injection_container.dart' as di;
import 'package:immigru/core/services/supabase_service.dart';
import 'package:immigru/presentation/blocs/onboarding/onboarding_bloc.dart';
import 'package:immigru/presentation/blocs/onboarding/onboarding_event.dart';
import 'package:immigru/presentation/blocs/profile/profile_bloc.dart';
import 'package:immigru/presentation/blocs/profile/profile_event.dart';
import 'package:immigru/presentation/theme/app_colors.dart';

/// Widget for the basic info step in profile setup as part of onboarding
class BasicInfoStep extends StatefulWidget {
  final String? fullName;
  final String photoUrl;

  const BasicInfoStep({
    super.key,
    this.fullName,
    this.photoUrl = '',
  });

  @override
  State<BasicInfoStep> createState() => _BasicInfoStepState();
}

class _BasicInfoStepState extends State<BasicInfoStep> {
  late final TextEditingController _fullNameController;
  final _formKey = GlobalKey<FormState>();
  File? _selectedImage;
  bool _isUploading = false;
  final _supabaseService = di.sl<SupabaseService>();

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.fullName ?? '');
  }

  /// Check if the URL is a valid image URL
  bool _isValidImageUrl(String url) {
    if (url.isEmpty) return false;

    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
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
            onChanged: () => _updateBasicInfo(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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

                // Full name field
                _buildTextField(
                  label: 'Full name',
                  controller: _fullNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
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
            labelText: label,
            hintText: 'Enter your $label',
            border: OutlineInputBorder(),
            suffixIcon: isRequired
                ? const Padding(
                    padding: EdgeInsets.only(top: 12.0),
                    child: Text(
                      '*',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 18.0,
                      ),
                    ),
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 14.0,
            ),
          ),
          textInputAction: TextInputAction.next,
        ),
      ],
    );
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

    // If there's a valid photo URL, show it
    if (widget.photoUrl.isNotEmpty && _isValidImageUrl(widget.photoUrl)) {
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
        // Set loading state and update selected image
        setState(() {
          _isUploading = true;
          _selectedImage = File(pickedImage.path);
        });

        // Upload the image and get the URL
        await _uploadImage(pickedImage);
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
      _isUploading = false;
    });

    // Update the profile with empty photo URL
    if (context.read<OnboardingBloc?>() != null) {
      context.read<OnboardingBloc>().add(
            const ProfilePhotoUpdated(''),
          );
    } else if (context.read<ProfileBloc?>() != null) {
      context.read<ProfileBloc>().add(
            BasicInfoUpdated(
              fullName: _fullNameController.text.trim(),
              photoUrl: '',
            ),
          );
    }
  }

  /// Update basic info in the onboarding bloc
  void _updateBasicInfo() {
    if (_formKey.currentState?.validate() ?? false) {
      final fullName = _fullNameController.text.trim();

      // Only update when the user is done editing (when form is submitted)
      // This prevents re-renders with every keystroke
      // Check which bloc is available and update accordingly
      if (context.read<OnboardingBloc?>() != null) {
        // Update the profile with the full name in OnboardingBloc
        context.read<OnboardingBloc>().add(
              ProfileBasicInfoUpdated(fullName: fullName),
            );
      } else if (context.read<ProfileBloc?>() != null) {
        // Update the profile with the full name in ProfileBloc
        context.read<ProfileBloc>().add(
              BasicInfoUpdated(fullName: fullName),
            );
      }
    }
  }

  /// Upload the selected image to Supabase storage
  Future<void> _uploadImage(XFile image) async {
    try {
      // Convert XFile to File
      final File imageFile = File(image.path);
      final fileExt = image.path.split('.').last;
      final userId = _supabaseService.client.auth.currentUser?.id ?? 'unknown';
      final fileName =
          'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      // Upload the file to Supabase storage using the recommended method
      await _supabaseService.client.storage
          .from('avatars') // Use 'avatars' bucket as per the example
          .upload(
            'public/$fileName',
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      // Get the public URL of the uploaded file
      final photoUrl = _supabaseService.client.storage
          .from('avatars')
          .getPublicUrl('public/$fileName');

      // Check which bloc is available and update accordingly
      if (context.read<OnboardingBloc?>() != null) {
        // Update the profile with the photo URL in OnboardingBloc
        context.read<OnboardingBloc>().add(
              ProfilePhotoUpdated(photoUrl),
            );
      } else if (context.read<ProfileBloc?>() != null) {
        // Update the profile with the photo URL in ProfileBloc
        context.read<ProfileBloc>().add(
              BasicInfoUpdated(
                fullName: _fullNameController.text.trim(),
                photoUrl: photoUrl,
              ),
            );
      }
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
