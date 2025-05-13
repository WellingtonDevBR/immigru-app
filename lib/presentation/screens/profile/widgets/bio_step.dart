import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/presentation/blocs/profile/profile_bloc.dart';
import 'package:immigru/presentation/blocs/profile/profile_event.dart';
import 'package:immigru/presentation/theme/app_colors.dart';

/// Widget for the bio step in profile setup
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
  final int _maxBioLength = 300;

  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController(text: widget.bio);
  }

  @override
  void dispose() {
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
                    'Tell Us About Yourself',
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),
                
                // Bio explanation
                Text(
                  'Share a bit about yourself with the community. What brought you here? What are your goals? This helps others connect with you.',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 32.0),
                
                // Bio field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bio',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Tell us about yourself',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      controller: _bioController,
                      maxLines: 6,
                      maxLength: _maxBioLength,
                      decoration: InputDecoration(
                        hintText: 'Write a short bio...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        contentPadding: const EdgeInsets.all(16.0),
                      ),
                      onChanged: (_) => _updateBio(),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                
                // Bio tips
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: AppColors.primaryColor,
                          ),
                          const SizedBox(width: 8.0),
                          Text(
                            'Tips for a Great Bio',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12.0),
                      _buildTipItem(
                        'Keep it concise and friendly',
                        isDarkMode,
                      ),
                      _buildTipItem(
                        'Share your immigration journey or goals',
                        isDarkMode,
                      ),
                      _buildTipItem(
                        'Mention your interests or expertise',
                        isDarkMode,
                      ),
                      _buildTipItem(
                        'Avoid sharing sensitive personal information',
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
      ),
    );
  }

  /// Build a tip item with bullet point
  Widget _buildTipItem(String text, bool isDarkMode) {
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

  /// Update bio in the bloc
  void _updateBio() {
    context.read<ProfileBloc>().add(
          BioUpdated(_bioController.text),
        );
  }
}
