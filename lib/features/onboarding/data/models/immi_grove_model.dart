import '../../domain/entities/immi_grove.dart';

/// Model class for ImmiGrove data
class ImmiGroveModel extends ImmiGrove {
  /// Creates a new ImmiGroveModel instance
  const ImmiGroveModel({
    required String id,
    required String name,
    required String description,
    String? iconUrl,
    required int memberCount,
    bool isJoined = false,
    List<String> categories = const [],
  }) : super(
          id: id,
          name: name,
          description: description,
          iconUrl: iconUrl,
          memberCount: memberCount,
          isJoined: isJoined,
          categories: categories,
        );

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
}
