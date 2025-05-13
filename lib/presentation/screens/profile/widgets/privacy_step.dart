import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/presentation/blocs/profile/profile_bloc.dart';
import 'package:immigru/presentation/blocs/profile/profile_event.dart';
import 'package:immigru/presentation/theme/app_colors.dart';

/// Widget for the privacy settings step in profile setup
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
                  'Privacy Settings',
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              
              // Privacy explanation
              Text(
                'Control who can see your profile information and how you appear in the community. You can change these settings anytime from your profile page.',
                style: TextStyle(
                  fontSize: 16.0,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 32.0),
              
              // Privacy toggle
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isPrivate ? Icons.lock : Icons.public,
                          color: _isPrivate
                              ? AppColors.primaryColor
                              : isDarkMode
                                  ? Colors.white70
                                  : Colors.black87,
                          size: 24.0,
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isPrivate
                                    ? 'Private Profile'
                                    : 'Public Profile',
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                _isPrivate
                                    ? 'Only approved connections can see your full profile'
                                    : 'Anyone in the community can see your profile',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: isDarkMode
                                      ? Colors.white70
                                      : Colors.black87,
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
              const SizedBox(height: 24.0),
              
              // What's visible section
              _buildVisibilitySection(isDarkMode),
              const SizedBox(height: 32.0),
              
              // Privacy policy link
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    // Navigate to privacy policy
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Privacy Policy would open here'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.privacy_tip_outlined),
                  label: const Text('View Full Privacy Policy'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the visibility section
  Widget _buildVisibilitySection(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isPrivate ? 'What\'s visible with a private profile:' : 'What\'s visible with a public profile:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 16.0),
          _buildVisibilityItem(
            'Display Name',
            'Always visible to everyone',
            Icons.person,
            true,
            isDarkMode,
          ),
          _buildVisibilityItem(
            'Profile Photo',
            _isPrivate ? 'Visible to connections only' : 'Visible to everyone',
            Icons.photo,
            !_isPrivate,
            isDarkMode,
          ),
          _buildVisibilityItem(
            'Bio',
            _isPrivate ? 'Visible to connections only' : 'Visible to everyone',
            Icons.description,
            !_isPrivate,
            isDarkMode,
          ),
          _buildVisibilityItem(
            'Current Location',
            _isPrivate ? 'Visible to connections only' : 'Visible to everyone',
            Icons.location_on,
            !_isPrivate,
            isDarkMode,
          ),
          _buildVisibilityItem(
            'Destination City',
            _isPrivate ? 'Visible to connections only' : 'Visible to everyone',
            Icons.flight_land,
            !_isPrivate,
            isDarkMode,
          ),
        ],
      ),
    );
  }

  /// Build a visibility item
  Widget _buildVisibilityItem(
    String title,
    String subtitle,
    IconData icon,
    bool isVisible,
    bool isDarkMode,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20.0,
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.0,
                    color: isDarkMode ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            isVisible ? Icons.visibility : Icons.visibility_off,
            size: 18.0,
            color: isVisible
                ? AppColors.primaryColor
                : isDarkMode
                    ? Colors.white60
                    : Colors.black54,
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
    
    context.read<ProfileBloc>().add(
      PrivacySettingsUpdated(_isPrivate),
    );
  }
}
