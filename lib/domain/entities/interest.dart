import 'package:equatable/equatable.dart';

/// Entity representing a user interest
class Interest extends Equatable {
  final int id;
  final String name;
  final String? category;
  final bool isActive;

  const Interest({
    required this.id,
    required this.name,
    this.category,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [id, name, category, isActive];
}
