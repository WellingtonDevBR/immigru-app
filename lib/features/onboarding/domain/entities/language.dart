import 'package:equatable/equatable.dart';

/// Entity representing a language
class Language extends Equatable {
  final int id;
  final String isoCode;
  final String name;
  final String? nativeName;
  final bool isActive;

  const Language({
    required this.id,
    required this.isoCode,
    required this.name,
    this.nativeName,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [id, isoCode, name, nativeName, isActive];
}
