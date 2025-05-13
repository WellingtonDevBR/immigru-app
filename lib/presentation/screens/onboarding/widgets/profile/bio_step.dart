import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/presentation/blocs/onboarding/onboarding_bloc.dart';
import 'package:immigru/presentation/blocs/onboarding/onboarding_event.dart';
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

  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController(text: widget.bio);
    _characterCount = _bioController.text.length;
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
                            color: isDarkMode ? Colors.white60 : Colors.black45,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      controller: _bioController,
                      maxLength: _maxCharacters,
                      maxLines: 5,
                      buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
                        return Text(
                          '$_characterCount/$maxLength',
                          style: TextStyle(
                            color: _characterCount > (maxLength! * 0.9)
                                ? Colors.red
                                : isDarkMode
                                    ? Colors.white60
                                    : Colors.black54,
                            fontSize: 12.0,
                          ),
                        );
                      },
                      decoration: InputDecoration(
                        hintText: 'Write a short bio...',
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
                      textInputAction: TextInputAction.newline,
                      onChanged: (_) => _updateBio(),
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),
                
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
                              'A good bio helps others connect with you. Consider sharing your immigration journey, professional background, or personal interests.',
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

  /// Update bio in the onboarding bloc
  void _updateBio() {
    // Bio is optional, so no validation required
    context.read<OnboardingBloc>().add(
      ProfileBioUpdated(_bioController.text.trim()),
    );
  }
}
