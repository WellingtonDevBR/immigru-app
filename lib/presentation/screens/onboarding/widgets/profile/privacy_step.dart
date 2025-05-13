import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/presentation/blocs/onboarding/onboarding_bloc.dart';
import 'package:immigru/presentation/blocs/onboarding/onboarding_event.dart';
import 'package:immigru/presentation/theme/app_colors.dart';

/// Widget for the privacy step in profile setup as part of onboarding
class PrivacyStep extends StatefulWidget {
  final bool isPrivate;

  const PrivacyStep({
    super.key,
    required this.isPrivate,
  });

  @override
  State<PrivacyStep> createState() => _PrivacyStepState();
}

class _PrivacyStepState extends State<PrivacyStep> {
  late bool _isPrivate;

  @override
  void initState() {
    super.initState();
    _isPrivate = widget.isPrivate;
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'Privacy Settings',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 12.0),
              
              // Subtitle
              Text(
                'Control who can see your profile information.',
                style: TextStyle(
                  fontSize: 16.0,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 32.0),
              
              // Profile visibility switch
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isPrivate ? Icons.lock_outline : Icons.public,
                          color: _isPrivate 
                              ? AppColors.primaryColor 
                              : Colors.green,
                          size: 28.0,
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isPrivate ? 'Private Profile' : 'Public Profile',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                _isPrivate
                                    ? 'Only approved connections can see your full profile'
                                    : 'Anyone in the community can see your profile',
                                style: TextStyle(
                                  color: isDarkMode ? Colors.white70 : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _isPrivate,
                          onChanged: _togglePrivacy,
                          activeColor: AppColors.primaryColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32.0),
              
              // What's shared section
              Text(
                'What\'s shared on your profile',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 16.0),
              
              // Profile items visibility
              _buildProfileItem(
                icon: Icons.person_outline,
                title: 'Basic Info',
                description: 'Name and display name',
                isAlwaysVisible: true,
              ),
              _buildProfileItem(
                icon: Icons.photo_outlined,
                title: 'Profile Photo',
                description: _isPrivate 
                    ? 'Visible only to connections' 
                    : 'Visible to everyone',
                isAlwaysVisible: !_isPrivate,
              ),
              _buildProfileItem(
                icon: Icons.description_outlined,
                title: 'Bio',
                description: _isPrivate 
                    ? 'Visible only to connections' 
                    : 'Visible to everyone',
                isAlwaysVisible: !_isPrivate,
              ),
              _buildProfileItem(
                icon: Icons.location_on_outlined,
                title: 'Location',
                description: _isPrivate 
                    ? 'Visible only to connections' 
                    : 'Visible to everyone',
                isAlwaysVisible: !_isPrivate,
              ),
              const SizedBox(height: 24.0),
              
              // Privacy tip
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
                            'You can change your privacy settings at any time from your profile page.',
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
    );
  }

  /// Build a profile item with visibility indicator
  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required String description,
    required bool isAlwaysVisible,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(
              icon,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16.0,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  description,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                    fontSize: 14.0,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            isAlwaysVisible ? Icons.visibility : Icons.visibility_off,
            color: isAlwaysVisible 
                ? Colors.green 
                : isDarkMode ? Colors.white54 : Colors.black45,
            size: 20.0,
          ),
        ],
      ),
    );
  }

  /// Toggle privacy setting
  void _togglePrivacy(bool value) {
    setState(() {
      _isPrivate = value;
    });
    
    // Update the profile with the privacy setting
    context.read<OnboardingBloc>().add(
      ProfilePrivacyUpdated(_isPrivate),
    );
  }
}
