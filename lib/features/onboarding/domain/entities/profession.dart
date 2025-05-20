/// Represents a profession in the onboarding process
class Profession {
  /// The name of the profession
  final String name;
  
  /// The industry category of the profession (optional)
  final String? industry;
  
  /// Whether this is a custom profession entered by the user
  final bool isCustom;

  /// Creates a new profession
  const Profession({
    required this.name,
    this.industry,
    this.isCustom = false,
  });

  /// Creates a copy of this profession with the given fields replaced with new values
  Profession copyWith({
    String? name,
    String? industry,
    bool? isCustom,
  }) {
    return Profession(
      name: name ?? this.name,
      industry: industry ?? this.industry,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Profession &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          industry == other.industry &&
          isCustom == other.isCustom;

  @override
  int get hashCode => name.hashCode ^ industry.hashCode ^ isCustom.hashCode;

  @override
  String toString() {
    return 'Profession{name: $name, industry: $industry, isCustom: $isCustom}';
  }
}
