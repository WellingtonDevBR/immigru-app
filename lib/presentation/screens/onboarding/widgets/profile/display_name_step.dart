import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/presentation/blocs/onboarding/onboarding_bloc.dart';
import 'package:immigru/presentation/blocs/onboarding/onboarding_event.dart';
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

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(text: widget.displayName);
  }

  @override
  void dispose() {
    _displayNameController.dispose();
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
                      onChanged: (_) => _updateDisplayName(),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                
                // Tip
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: Colors.amber.withOpacity(0.3),
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
    );
  }

  /// Update display name in the onboarding bloc
  void _updateDisplayName() {
    if (_formKey.currentState?.validate() ?? false) {
      // Use the ProfileDisplayNameUpdated event from OnboardingBloc
      context.read<OnboardingBloc>().add(
        ProfileDisplayNameUpdated(_displayNameController.text.trim()),
      );
    }
  }
}
