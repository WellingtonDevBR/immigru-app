import 'package:immigru/features/auth/domain/entities/user.dart';

/// Data model for User entity
class UserModel extends User {
  /// Constructor
  UserModel({
    required super.id,
    super.email,
    super.phone,
    super.displayName,
    super.photoUrl,
    super.emailVerified,
    super.hasCompletedOnboarding,
  });

  /// Create a UserModel from a JSON map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle both camelCase and PascalCase field names for compatibility
    return UserModel(
      id: json['Id'] as String? ?? json['id'] as String,
      email: json['Email'] as String? ?? json['email'] as String?,
      phone: json['PhoneNumber'] as String? ?? json['phone'] as String?,
      displayName: json['DisplayName'] as String? ?? json['display_name'] as String?,
      photoUrl: json['AvatarUrl'] as String? ?? json['photo_url'] as String?,
      emailVerified: json['EmailVerified'] as bool? ?? json['email_verified'] as bool? ?? false,
      hasCompletedOnboarding: json['HasCompletedOnboarding'] as bool? ?? json['has_completed_onboarding'] as bool? ?? false,
    );
  }

  /// Convert UserModel to a JSON map with PascalCase field names for database operations
  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Email': email,
      'PhoneNumber': phone,
      'DisplayName': displayName,
      'AvatarUrl': photoUrl,
      'EmailVerified': emailVerified,
      'HasCompletedOnboarding': hasCompletedOnboarding,
    };
  }
  
  /// Convert UserModel to a JSON map with snake_case field names for API compatibility
  Map<String, dynamic> toApiJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'display_name': displayName,
      'photo_url': photoUrl,
      'email_verified': emailVerified,
      'has_completed_onboarding': hasCompletedOnboarding,
    };
  }

  /// Create a UserModel from a User entity
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      phone: user.phone,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
      emailVerified: user.emailVerified,
      hasCompletedOnboarding: user.hasCompletedOnboarding,
    );
  }

  /// Create a copy of this UserModel with the given fields replaced with new values
  @override
  UserModel copyWith({
    String? id,
    String? email,
    String? phone,
    String? displayName,
    String? photoUrl,
    bool? emailVerified,
    bool? hasCompletedOnboarding,
  }) {
    return UserModel(
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
