import 'package:equatable/equatable.dart';

/// Entity representing a post author
class Author extends Equatable {
  /// Unique identifier for the author
  final String id;
  
  /// Display name of the author
  final String? displayName;
  
  /// Avatar URL of the author
  final String? avatarUrl;
  
  /// Create a new Author
  const Author({
    required this.id,
    this.displayName,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, displayName, avatarUrl];
  
  /// Convert Author to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
    };
  }

  /// Create an Author from a JSON map
  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['id'] as String,
      displayName: json['displayName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
  
  /// String representation for debugging
  @override
  String toString() {
    return 'Author{id: $id, displayName: $displayName}';
  }
}
