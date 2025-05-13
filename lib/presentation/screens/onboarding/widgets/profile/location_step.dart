import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/presentation/blocs/onboarding/onboarding_bloc.dart';
import 'package:immigru/presentation/blocs/onboarding/onboarding_event.dart';
import 'package:immigru/presentation/theme/app_colors.dart';

/// Widget for the location step in profile setup as part of onboarding
class LocationStep extends StatefulWidget {
  final String currentLocation;
  final String destinationCity;

  const LocationStep({
    super.key,
    required this.currentLocation,
    required this.destinationCity,
  });

  @override
  State<LocationStep> createState() => _LocationStepState();
}

class _LocationStepState extends State<LocationStep> {
  late final TextEditingController _currentLocationController;
  late final TextEditingController _destinationCityController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _currentLocationController = TextEditingController(text: widget.currentLocation);
    _destinationCityController = TextEditingController(text: widget.destinationCity);
  }

  @override
  void dispose() {
    _currentLocationController.dispose();
    _destinationCityController.dispose();
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
            onChanged: _updateLocation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  'Where are you located?',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 12.0),
                
                // Subtitle
                Text(
                  'This helps us connect you with relevant resources and community members.',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 32.0),
                
                // Current location field
                _buildTextField(
                  label: 'Current location',
                  controller: _currentLocationController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your current location';
                    }
                    return null;
                  },
                  isRequired: true,
                  hintText: 'City, Country',
                  leadingIcon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 24.0),
                
                // Destination city field
                _buildTextField(
                  label: 'Destination city',
                  controller: _destinationCityController,
                  hintText: 'City, Country (if different from current)',
                  leadingIcon: Icons.flight_land_outlined,
                  isOptional: true,
                ),
                const SizedBox(height: 24.0),
                
                // Privacy notice
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: AppColors.primaryColor.withValues(alpha:0.3),
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
                              'Your location information helps us personalize your experience. You can control who sees this information in your privacy settings.',
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
    bool isOptional = false,
    String? hintText,
    IconData? leadingIcon,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
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
            const SizedBox(width: 8.0),
            if (isRequired) ...[
              Text(
                '*',
                style: TextStyle(
                  color: Colors.red[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ] else if (isOptional) ...[
              Text(
                '(optional)',
                style: TextStyle(
                  fontSize: 14.0,
                  color: isDarkMode ? Colors.white60 : Colors.black45,
                  fontStyle: FontStyle.italic,
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
            hintText: hintText ?? 'Enter your ${label.toLowerCase()}',
            prefixIcon: leadingIcon != null ? Icon(leadingIcon) : null,
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
          onChanged: (_) => _updateLocation(),
        ),
      ],
    );
  }

  /// Update location in the onboarding bloc
  void _updateLocation() {
    if (_formKey.currentState?.validate() ?? false) {
      // Use the ProfileLocationUpdated event from OnboardingBloc
      context.read<OnboardingBloc>().add(
        ProfileLocationUpdated(
          currentLocation: _currentLocationController.text.trim(),
          destinationCity: _destinationCityController.text.trim(),
        ),
      );
    }
  }
}
