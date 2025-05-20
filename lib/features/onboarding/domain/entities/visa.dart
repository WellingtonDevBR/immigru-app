/// Entity representing a visa type
class Visa {
  /// Unique identifier for the visa
  final int id;
  
  /// Name of the visa
  final String name;
  
  /// Visa name (alias for name for backward compatibility)
  String get visaName => name;
  
  /// Visa code or identifier
  final String? visaCode;
  
  /// Description of the visa
  final String? description;
  
  /// ID of the country this visa is for
  final int countryId;
  
  /// Whether this is a common visa type
  final bool isCommon;
  
  /// Type of visa (e.g., work, study, tourist)
  final String? type;
  
  /// Whether this visa provides a pathway to permanent residency
  final bool pathwayToPR;
  
  /// Whether this visa allows the holder to work
  final bool allowsWork;
  
  /// Constructor
  const Visa({
    required this.id,
    required this.name,
    this.visaCode,
    this.description,
    required this.countryId,
    this.isCommon = false,
    this.type,
    this.pathwayToPR = false,
    this.allowsWork = false,
  });
  
  /// Create a copy of this visa with the given fields replaced with new values
  Visa copyWith({
    int? id,
    String? name,
    String? description,
    int? countryId,
    bool? isCommon,
  }) {
    return Visa(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      countryId: countryId ?? this.countryId,
      isCommon: isCommon ?? this.isCommon,
    );
  }
  
  @override
  String toString() => name;
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Visa && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}
