import 'package:immigru/features/home/domain/entities/author.dart';

/// Model class for Author entity
class AuthorModel extends Author {
  /// Create a new AuthorModel
  const AuthorModel({
    required super.id,
    super.displayName,
    super.avatarUrl,
  });

  /// Create an AuthorModel from JSON
  factory AuthorModel.fromJson(Map<String, dynamic> json) {
    return AuthorModel(
      id: json['id']?.toString() ?? '',
      displayName: json['display_name']?.toString(),
      avatarUrl: json['avatar_url']?.toString(),
    );
  }

  /// Convert AuthorModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'display_name': displayName,
      'avatar_url': avatarUrl,
    };
  }
}
