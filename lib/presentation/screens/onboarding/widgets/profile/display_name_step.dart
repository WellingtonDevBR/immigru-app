import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/presentation/blocs/onboarding/onboarding_bloc.dart';
import 'package:immigru/presentation/blocs/onboarding/onboarding_event.dart';
import 'package:immigru/presentation/blocs/onboarding/onboarding_state.dart';
import 'package:immigru/presentation/theme/app_colors.dart';

/// Widget for the display name step in profile setup as part of onboarding
class DisplayNameStep extends StatefulWidget {
  final String displayName;

  const DisplayNameStep({
    super.key,
    required this.displayName,
  });

  @override
  State<DisplayNameStep> createState() => _DisplayNameStepState();
}

class _DisplayNameStepState extends State<DisplayNameStep> {
  late final TextEditingController _displayNameController;
  final _formKey = GlobalKey<FormState>();
  // Timer for debouncing text input changes
  Timer? _debounceTimer;
  
  // Store the current value to prevent redundant state updates
  String _currentValue = '';

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(text: widget.displayName);
    _currentValue = widget.displayName;
    
  }

  @override
  void dispose() {
    
    _displayNameController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    

    // Listen to onboarding state changes to track display name updates
    return BlocListener<OnboardingBloc, OnboardingState>(
        listenWhen: (previous, current) =>
            previous.data.displayName != current.data.displayName,
        listener: (context, state) {
          
        },
        child: Container(
          color: isDarkMode ? AppColors.darkBackground : Colors.white,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                onChanged: _updateDisplayName,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      'What should we call you?',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12.0),

                    // Subtitle
                    Text(
                      'This is the name that will be displayed to other users in the community.',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 32.0),

                    // Display name field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Display name',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16.0,
                              ),
                            ),
                            const SizedBox(width: 4.0),
                            Text(
                              '*',
                              style: TextStyle(
                                color: Colors.red[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        TextFormField(
                          controller: _displayNameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a display name';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'Enter your display name',
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
                          textInputAction: TextInputAction.done,
                          // Update state on change but don't save yet - with debouncing
                          onChanged: (value) {
                            // Cancel previous timer if it exists
                            _debounceTimer?.cancel();
                            
                            // Only update after a short delay to avoid excessive updates during typing
                            _debounceTimer = Timer(const Duration(milliseconds: 500), () {
                              final trimmedValue = value.trim();
                              
                              // Only update if the value has actually changed from our tracked current value
                              if (trimmedValue != _currentValue) {
                                // Update our tracked value
                                _currentValue = trimmedValue;
                                
                                // Just update the state, don't save to backend
                                context.read<OnboardingBloc>().add(
                                  ProfileDisplayNameUpdated(trimmedValue),
                                );
                              }
                            });
                          },
                          // Save when user submits the field
                          onFieldSubmitted: (value) {
                            
                            context.read<OnboardingBloc>().add(
                                  ProfileDisplayNameUpdated(value.trim()),
                                );
                            // Also trigger save to Supabase
                            
                            context.read<OnboardingBloc>().add(
                                  const OnboardingSaved(),
                                );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),

                    // Tip
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
                                  'Tip',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber[700],
                                  ),
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  'Your display name can be your real name, a nickname, or any name you prefer to be called in the community.',
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
        ));
  }

  @override
  void didUpdateWidget(DisplayNameStep oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.displayName != widget.displayName) {
      
      
      // Only update controller if the text is different to avoid cursor jumps
      if (_displayNameController.text != widget.displayName) {
        _displayNameController.text = widget.displayName;
      }
    }
  }

  /// Update display name in the onboarding bloc when Next button is pressed
  void _updateDisplayName() {
    if (_formKey.currentState?.validate() ?? false) {
      final displayName = _displayNameController.text.trim();
      
      // Only update the bloc state if the display name has changed from our tracked value
      if (_currentValue != displayName) {
        _currentValue = displayName;
        
        // Update the display name in the bloc
        context.read<OnboardingBloc>().add(
          ProfileDisplayNameUpdated(displayName),
        );
      }
      
      // The OnboardingSaved event will be triggered by the Next button in the onboarding screen
      // We don't need to trigger it here to avoid redundant API calls
    }
  }
}
