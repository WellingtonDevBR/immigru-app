/// User entity representing an authenticated user
class User {
  /// Unique identifier for the user
  final String id;
  
  /// User's email address
  final String? email;
  
  /// User's phone number
  final String? phone;
  
  /// User's display name
  final String? displayName;
  
  /// URL to the user's profile photo
  final String? photoUrl;
  
  /// Whether the user's email has been verified
  final bool emailVerified;
  
  /// Whether the user has completed onboarding
  final bool hasCompletedOnboarding;
  
  /// Constructor
  User({
    required this.id,
    this.email,
    this.phone,
    this.displayName,
    this.photoUrl,
    this.emailVerified = false,
    this.hasCompletedOnboarding = false,
  });
  
  /// Create a copy of this user with the given fields replaced with new values
  User copyWith({
    String? id,
    String? email,
    String? phone,
    String? displayName,
    String? photoUrl,
    bool? emailVerified,
    bool? hasCompletedOnboarding,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      emailVerified: emailVerified ?? this.emailVerified,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }
}
