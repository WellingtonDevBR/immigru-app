import 'package:immigru/features/home/domain/entities/immi_grove.dart';

/// Model class for ImmiGrove entity
class ImmiGroveModel extends ImmiGrove {
  const ImmiGroveModel({
    required super.id,
    required super.name,
    super.description,
    required super.memberCount,
    super.isJoined,
    super.imageUrl,
  });

  /// Create an ImmiGroveModel from JSON
  factory ImmiGroveModel.fromJson(Map<String, dynamic> json) {
    return ImmiGroveModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      memberCount: json['member_count'] != null
          ? int.tryParse(json['member_count'].toString()) ?? 0
          : 0,
      isJoined: json['is_joined'] != null ? json['is_joined'] as bool : false,
      imageUrl: json['image_url']?.toString(),
    );
  }

  /// Convert ImmiGroveModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'member_count': memberCount,
      'is_joined': isJoined,
      'image_url': imageUrl,
    };
  }

  /// Create a list of ImmiGroveModels from a list of JSON objects
  static List<ImmiGroveModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => ImmiGroveModel.fromJson(json)).toList();
  }
}
