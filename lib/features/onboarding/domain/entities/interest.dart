/// Entity representing an interest in the onboarding flow
class Interest {
  final int id;
  final String name;
  final String? description;
  final bool isSelected;
  
  const Interest({
    required this.id,
    required this.name,
    this.description,
    this.isSelected = false,
  });
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Interest &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          isSelected == other.isSelected;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ description.hashCode ^ isSelected.hashCode;
  
  @override
  String toString() => 'Interest{id: $id, name: $name, isSelected: $isSelected}';
}
