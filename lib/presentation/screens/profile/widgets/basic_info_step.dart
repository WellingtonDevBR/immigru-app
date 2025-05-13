import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/presentation/blocs/profile/profile_bloc.dart';
import 'package:immigru/presentation/blocs/profile/profile_event.dart';
import 'package:immigru/presentation/theme/app_colors.dart';

/// Widget for the basic info step in profile setup
class BasicInfoStep extends StatefulWidget {
  final String firstName;
  final String lastName;

  const BasicInfoStep({
    super.key,
    required this.firstName,
    required this.lastName,
  });

  @override
  State<BasicInfoStep> createState() => _BasicInfoStepState();
}

class _BasicInfoStepState extends State<BasicInfoStep> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  final _formKey = GlobalKey<FormState>();

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
                
                // Profile photo placeholder
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.grey[800]
                          : Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        'U',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                
                // Add profile photo button (will be implemented in a later step)
                Center(
                  child: OutlinedButton.icon(
                    onPressed: null, // Will be implemented in photo step
                    icon: const Icon(Icons.add_a_photo),
                    label: const Text('Add Profile Photo'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                    ),
                  ),
                ),
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

  /// Update basic info in the bloc
  void _updateBasicInfo() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<ProfileBloc>().add(
            BasicInfoUpdated(
              firstName: _firstNameController.text,
              lastName: _lastNameController.text,
            ),
          );
    }
  }
}
