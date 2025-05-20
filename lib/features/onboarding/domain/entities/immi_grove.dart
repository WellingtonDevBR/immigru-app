import 'package:equatable/equatable.dart';

/// Entity representing an ImmiGrove community
class ImmiGrove extends Equatable {
  /// Unique identifier for the ImmiGrove
  final String id;
  
  /// Name of the ImmiGrove
  final String name;
  
  /// Description of the ImmiGrove
  final String description;
  
  /// URL to the ImmiGrove's icon
  final String? iconUrl;
  
  /// Number of members in the ImmiGrove
  final int memberCount;
  
  /// Whether the current user has joined this ImmiGrove
  final bool isJoined;
  
  /// Categories or tags associated with this ImmiGrove
  final List<String> categories;

  /// Creates a new ImmiGrove instance
  const ImmiGrove({
    required this.id,
    required this.name,
    required this.description,
    this.iconUrl,
    required this.memberCount,
    this.isJoined = false,
    this.categories = const [],
  });

  @override
  List<Object?> get props => [
    id, 
    name, 
    description, 
    iconUrl, 
    memberCount, 
    isJoined,
    categories,
  ];
  
  /// Creates a copy of this ImmiGrove with the given fields replaced with new values
  ImmiGrove copyWith({
    String? id,
    String? name,
    String? description,
    String? iconUrl,
    int? memberCount,
    bool? isJoined,
    List<String>? categories,
  }) {
    return ImmiGrove(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconUrl: iconUrl ?? this.iconUrl,
      memberCount: memberCount ?? this.memberCount,
      isJoined: isJoined ?? this.isJoined,
      categories: categories ?? this.categories,
    );
  }
}
