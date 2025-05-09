import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;
  final String? phone;
  
  // Alias for photoUrl to match our UI naming convention
  String? get avatarUrl => photoUrl;

  const User({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
    this.phone,
  });
  
  // Create a copy of this User with the given fields replaced
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    String? phone,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      phone: phone ?? this.phone,
    );
  }

  @override
  List<Object?> get props => [id, email, name, photoUrl, phone];
}
