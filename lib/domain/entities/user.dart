import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;
  
  // Alias for photoUrl to match our UI naming convention
  String? get avatarUrl => photoUrl;

  const User({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
  });
  
  // Create a copy of this User with the given fields replaced
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  @override
  List<Object?> get props => [id, email, name, photoUrl];
}
