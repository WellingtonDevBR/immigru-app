import 'package:flutter/material.dart';
import 'package:immigru/features/profile/domain/entities/user_profile.dart';

/// Widget for displaying the profile information section
class ProfileInfoSection extends StatelessWidget {
  /// The user profile data
  final UserProfile profile;

  /// Whether this is the current user's profile
  final bool isCurrentUser;

  /// Constructor
  const ProfileInfoSection({
    super.key,
    required this.profile,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // About section
        if (profile.bio != null && profile.bio!.isNotEmpty)
          _buildSectionWithTitle(
            context,
            'About',
            Icons.format_quote,
            profile.bio!,
            primaryColor,
          ),

        // Personal info section
        _buildPersonalInfoSection(context, primaryColor),

        // Migration journey section
        _buildMigrationJourneySection(context, primaryColor),

        // Follow button for other users (only show for non-current users)
        if (!isCurrentUser)
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement follow/unfollow functionality
                },
                icon: const Icon(Icons.person_add_outlined, size: 18),
                label: const Text('Follow'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Build a section with title and icon
  Widget _buildSectionWithTitle(BuildContext context, String title,
      IconData icon, String content, Color primaryColor) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title with icon
          Row(
            children: [
              Icon(
                icon,
                color: primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Content
          Text(
            content,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  /// Build personal info section
  Widget _buildPersonalInfoSection(BuildContext context, Color primaryColor) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Row(
            children: [
              Icon(
                Icons.person_outline,
                color: primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Personal Info',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Location
          if (profile.currentCity != null && profile.currentCity!.isNotEmpty)
            _buildInfoItem(context, Icons.location_on_outlined,
                'Lives in ${profile.currentCity!}'),

          // Profession
          if (profile.profession != null && profile.profession!.isNotEmpty)
            _buildInfoItem(context, Icons.work_outlined,
                'Works as ${profile.profession!}'),
        ],
      ),
    );
  }

  /// Build migration journey section
  Widget _buildMigrationJourneySection(
      BuildContext context, Color primaryColor) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Row(
            children: [
              Icon(
                Icons.flight,
                color: primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Migration Journey',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Origin country
          if (profile.originCountry != null &&
              profile.originCountry!.isNotEmpty)
            _buildInfoItem(context, Icons.flight_takeoff,
                'From ${profile.originCountry!}'),

          // Destination city
          if (profile.destinationCity != null &&
              profile.destinationCity!.isNotEmpty)
            _buildInfoItem(
                context, Icons.flight_land, 'To ${profile.destinationCity!}'),
        ],
      ),
    );
  }

  /// Build an info item with icon and text
  Widget _buildInfoItem(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 18,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
