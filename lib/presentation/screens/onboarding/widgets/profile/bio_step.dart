import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/presentation/blocs/onboarding/onboarding_bloc.dart';
import 'package:immigru/presentation/blocs/onboarding/onboarding_event.dart';
import 'package:immigru/presentation/blocs/onboarding/onboarding_state.dart';
import 'package:immigru/presentation/theme/app_colors.dart';

/// Widget for the bio step in profile setup as part of onboarding
class BioStep extends StatefulWidget {
  final String bio;

  const BioStep({
    super.key,
    required this.bio,
  });

  @override
  State<BioStep> createState() => _BioStepState();
}

class _BioStepState extends State<BioStep> {
  late final TextEditingController _bioController;
  final _formKey = GlobalKey<FormState>();
  int _characterCount = 0;
  final int _maxCharacters = 250;

  // Timer for debouncing text input changes
  Timer? _debounceTimer;

  // Store the current value to prevent redundant state updates
  String _currentValue = '';

  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController(text: widget.bio);
    _characterCount = _bioController.text.length;
    _currentValue = widget.bio;
    _bioController.addListener(_updateCharacterCount);

    
  }

  void _updateCharacterCount() {
    setState(() {
      _characterCount = _bioController.text.length;
    });
  }

  @override
  void dispose() {
    _bioController.removeListener(_updateCharacterCount);
    _bioController.dispose();
    _debounceTimer?.cancel();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Listen to onboarding state changes to track bio updates
    return BlocListener<OnboardingBloc, OnboardingState>(
      listenWhen: (previous, current) => previous.data.bio != current.data.bio,
      listener: (context, state) {
        final newBio = state.data.bio ?? '';
        

        // Update the controller text if it's different from the current input
        // but only if the controller doesn't have focus to avoid cursor jumps
        if (newBio != _currentValue && !FocusScope.of(context).hasFocus) {
          _currentValue = newBio;
          // Only update controller if text is different to avoid cursor jumps
          if (_bioController.text != newBio) {
            _bioController.text = newBio;
          }
        }
      },
      child: Container(
        color: isDarkMode ? AppColors.darkBackground : Colors.white,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              onChanged: _updateBio,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    'Tell us about yourself',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12.0),

                  // Subtitle
                  Text(
                    'Share a bit about your background, interests, or what brings you to Immigru.',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 32.0),

                  // Bio field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Bio',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16.0,
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Text(
                            '(optional)',
                            style: TextStyle(
                              fontSize: 14.0,
                              color: isDarkMode
                                  ? Colors.white60
                                  : Colors.black45,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      // Wrap TextFormField with Focus widget to detect when focus is lost
                      Focus(
                        onFocusChange: (hasFocus) {
                          // When focus is lost, update the bio in the bloc
                          if (!hasFocus) {
                            final bioText = _bioController.text.trim();
                            final sanitizedBio = _sanitizeBio(bioText);

                            // Only update if the value has changed
                            if (sanitizedBio != _currentValue) {
                              
                              _currentValue = sanitizedBio;

                              // Update the bio in the bloc
                              context.read<OnboardingBloc>().add(
                                ProfileBioUpdated(sanitizedBio),
                              );
                            }
                          }
                        },
                        child: TextFormField(
                          controller: _bioController,
                          maxLength: _maxCharacters,
                          maxLines: 5,
                          minLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Tell others about yourself...',
                            hintStyle: TextStyle(
                              color: isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(
                                color: isDarkMode
                                    ? Colors.grey[700]!
                                    : Colors.grey[300]!,
                              ),
                            ),
                          ),
                          textInputAction: TextInputAction.newline,
                          onChanged: (value) {
                            // Cancel previous timer if it exists
                            _debounceTimer?.cancel();

                            // Only update after a short delay to avoid excessive updates during typing
                            _debounceTimer = Timer(const Duration(milliseconds: 500), () {
                              final sanitizedValue = _sanitizeBio(value.trim());

                              // Only update if the value has actually changed from our tracked current value
                              if (sanitizedValue != _currentValue) {
                                // Update our tracked value
                                _currentValue = sanitizedValue;

                                // Just update the state, don't save to backend
                                context.read<OnboardingBloc>().add(
                                  ProfileBioUpdated(sanitizedValue),
                                );
                              }
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      // Character count
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '$_characterCount/$_maxCharacters',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: _characterCount > (_maxCharacters * 0.9)
                                ? Colors.red
                                : isDarkMode
                                    ? Colors.white60
                                    : Colors.black45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Sanitize the bio text to prevent XSS and other security issues
  String _sanitizeBio(String text) {
    if (text.isEmpty) return '';

    // Remove any potentially harmful HTML/script tags
    final sanitized = text
        .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
        .replaceAll(RegExp(r'\\'), '\\\\') // Escape backslashes
        .replaceAll(RegExp(r'"'), '\\"') // Escape double quotes
        .replaceAll(RegExp(r"'"), "\\'") // Escape single quotes
        .replaceAll(RegExp(r'`'), '\\`') // Escape backticks
        .replaceAll(RegExp(r'\$'), '\\\$'); // Escape dollar signs

    
    return sanitized;
  }

  /// Update bio in the onboarding bloc when Next button is pressed
  void _updateBio() {
    // Bio is optional, so no validation required
    final bioText = _bioController.text.trim();
    final sanitizedBio = _sanitizeBio(bioText);

    // Only update the bloc state if the bio has changed from our tracked value
    if (_currentValue != sanitizedBio) {
      _currentValue = sanitizedBio;

      

      // Update the bio in the bloc
      context.read<OnboardingBloc>().add(
        ProfileBioUpdated(sanitizedBio),
      );
    } else {
      
    }

    // The OnboardingSaved event will be triggered by the Next button in the onboarding screen
    // We don't need to trigger it here to avoid redundant API calls
  }
}
