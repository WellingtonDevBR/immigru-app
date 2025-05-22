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
}
