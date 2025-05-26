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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display name and verification badge
        Row(
          children: [
            Text(
              profile.displayName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (profile.isMentor)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(
                  Icons.verified,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
          ],
        ),
        
        // Username
        Text(
          '@${profile.userName}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Bio
        if (profile.bio != null && profile.bio!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              profile.bio!,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        
        // Location
        if (profile.currentCity != null && profile.currentCity!.isNotEmpty)
          _buildInfoRow(
            Icons.location_on_outlined,
            profile.currentCity!,
          ),
        
        // Profession
        if (profile.profession != null && profile.profession!.isNotEmpty)
          _buildInfoRow(
            Icons.work_outline,
            profile.profession!,
          ),
        
        // Origin country
        if (profile.originCountry != null && profile.originCountry!.isNotEmpty)
          _buildInfoRow(
            Icons.flight_takeoff,
            'From ${profile.originCountry!}',
          ),
        
        // Destination city
        if (profile.destinationCity != null && profile.destinationCity!.isNotEmpty)
          _buildInfoRow(
            Icons.flight_land,
            'To ${profile.destinationCity!}',
          ),
        
        // Migration stage
        if (profile.migrationStage != null && profile.migrationStage!.isNotEmpty)
          _buildInfoRow(
            Icons.timeline,
            'Stage: ${profile.migrationStage!}',
          ),
        
        const SizedBox(height: 16),
        
        // Edit profile button for current user
        if (isCurrentUser)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // TODO: Navigate to edit profile screen
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Theme.of(context).colorScheme.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'Edit Profile',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        
        // Follow button for other users
        if (!isCurrentUser)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Implement follow/unfollow functionality
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Follow',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Build an info row with icon and text
  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
