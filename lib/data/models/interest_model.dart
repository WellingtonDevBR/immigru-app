import 'package:immigru/domain/entities/interest.dart';

/// Model class for Interest data
class InterestModel extends Interest {
  const InterestModel({
    required super.id,
    required super.name,
    super.category,
    super.isActive,
  });

  /// Create an InterestModel from a JSON map
  factory InterestModel.fromJson(Map<String, dynamic> json) {
    return InterestModel(
      id: json['Id'] as int,
      name: json['Name'] as String,
      category: json['Category'] as String?,
      isActive: json['IsActive'] as bool? ?? true,
    );
  }

  /// Convert InterestModel to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Name': name,
      'Category': category,
      'IsActive': isActive,
    };
  }
}
