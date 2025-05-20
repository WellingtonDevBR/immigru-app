import '../../domain/entities/interest.dart';

/// Model class for Interest entity
class InterestModel extends Interest {
  const InterestModel({
    required int id,
    required String name,
    String? description,
    bool isSelected = false,
  }) : super(
          id: id,
          name: name,
          description: description,
          isSelected: isSelected,
        );
        
  /// Create an InterestModel from a JSON map
  factory InterestModel.fromJson(Map<String, dynamic> json) {
    // Handle both direct and nested interest data structures
    if (json.containsKey('Interest')) {
      final interestData = json['Interest'] as Map<String, dynamic>;
      return InterestModel(
        id: interestData['Id'] as int,
        name: interestData['Name'] as String,
        description: interestData['Description'] as String?,
        isSelected: true,
      );
    }
    
    return InterestModel(
      id: json['Id'] as int,
      name: json['Name'] as String,
      description: json['Description'] as String?,
      isSelected: json['IsSelected'] as bool? ?? false,
    );
  }
  
  /// Convert the model to a JSON map
  Map<String, dynamic> toJson() => {
    'Id': id,
    'Name': name,
    'Description': description,
    'IsSelected': isSelected,
  };
}
