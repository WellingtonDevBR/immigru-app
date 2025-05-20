import 'package:equatable/equatable.dart';

/// Entity representing an ImmiGrove community
class ImmiGrove extends Equatable {
  final String id;
  final String name;
  final String? description;
  final int memberCount;
  final bool isJoined;
  final String? imageUrl;

  const ImmiGrove({
    required this.id,
    required this.name,
    this.description,
    required this.memberCount,
    this.isJoined = false,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        memberCount,
        isJoined,
        imageUrl,
      ];

  ImmiGrove copyWith({
    String? id,
    String? name,
    String? description,
    int? memberCount,
    bool? isJoined,
    String? imageUrl,
  }) {
    return ImmiGrove(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      memberCount: memberCount ?? this.memberCount,
      isJoined: isJoined ?? this.isJoined,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
