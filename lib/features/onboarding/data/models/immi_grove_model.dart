import '../../domain/entities/immi_grove.dart';

/// Model class for ImmiGrove data
class ImmiGroveModel extends ImmiGrove {
  /// Creates a new ImmiGroveModel instance
  const ImmiGroveModel({
    required super.id,
    required super.name,
    required super.description,
    super.iconUrl,
    required super.memberCount,
    super.isJoined,
    super.categories,
  });

  /// Creates an ImmiGroveModel from a JSON map
  factory ImmiGroveModel.fromJson(Map<String, dynamic> json) {
    return ImmiGroveModel(
      id: json['id']?.toString() ?? '', // Convert to String safely
      name: json['name']?.toString() ?? '', // Convert to String safely
      description: json['description']?.toString() ?? '', // Convert to String safely
      iconUrl: json['icon_url']?.toString(), // Convert to String? safely
      memberCount: json['member_count'] is int ? json['member_count'] as int : 0,
      isJoined: json['is_joined'] is bool ? json['is_joined'] as bool : false,
      categories: json['categories'] != null
          ? List<String>.from((json['categories'] as List).map((item) => item?.toString() ?? ''))
          : [],
    );
  }

  /// Converts this ImmiGroveModel to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon_url': iconUrl,
      'member_count': memberCount,
      'is_joined': isJoined,
      'categories': categories,
    };
  }
  
  /// Creates a copy of this ImmiGroveModel with the given fields replaced with new values
  @override
  ImmiGroveModel copyWith({
    String? id,
    String? name,
    String? description,
    String? iconUrl,
    int? memberCount,
    bool? isJoined,
    List<String>? categories,
  }) {
    return ImmiGroveModel(
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
