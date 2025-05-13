import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/presentation/blocs/profile/profile_bloc.dart';
import 'package:immigru/presentation/blocs/profile/profile_event.dart';
import 'package:immigru/presentation/theme/app_colors.dart';

/// Widget for the location step in profile setup
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
                    'Your Location',
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),
                
                // Location explanation
                Text(
                  'Sharing your current location and destination helps us connect you with relevant resources and community members.',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 32.0),
                
                // Current location field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current location',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      controller: _currentLocationController,
                      decoration: InputDecoration(
                        hintText: 'City, Country',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 14.0,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.my_location),
                          tooltip: 'Use current location',
                          onPressed: () {
                            // This would be implemented with location services
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Location detection not implemented in this demo'),
                              ),
                            );
                          },
                        ),
                      ),
                      textInputAction: TextInputAction.next,
                      onChanged: (_) => _updateLocation(),
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),
                
                // Destination city field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Destination city',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Where are you moving to?',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      controller: _destinationCityController,
                      decoration: InputDecoration(
                        hintText: 'Where are you moving to?',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 14.0,
                        ),
                      ),
                      textInputAction: TextInputAction.done,
                      onChanged: (_) => _updateLocation(),
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),
                
                // Privacy note
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.grey[800]
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.privacy_tip_outlined,
                        color: isDarkMode
                            ? Colors.white70
                            : Colors.black54,
                        size: 20.0,
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Text(
                          'Your location information helps us personalize your experience. You can control who sees this in your privacy settings.',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: isDarkMode
                                ? Colors.white70
                                : Colors.black87,
                          ),
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

  /// Update location in the bloc
  void _updateLocation() {
    context.read<ProfileBloc>().add(
          LocationUpdated(
            currentLocation: _currentLocationController.text,
            destinationCity: _destinationCityController.text,
          ),
        );
  }
}
