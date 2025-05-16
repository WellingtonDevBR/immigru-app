import 'package:equatable/equatable.dart';

/// Base class for all onboarding steps
abstract class OnboardingStep extends Equatable {
  final String id;
  final String title;
  final bool isCompleted;

  const OnboardingStep({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  @override
  List<Object?> get props => [id, title, isCompleted];
}

/// Birth country step entity
class BirthCountryStep extends OnboardingStep {
  final String? selectedCountryId;

  const BirthCountryStep({
    required super.id,
    required super.title,
    super.isCompleted = false,
    this.selectedCountryId,
  });

  /// Create a copy of this step with updated properties
  BirthCountryStep copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    String? selectedCountryId,
  }) {
    return BirthCountryStep(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      selectedCountryId: selectedCountryId ?? this.selectedCountryId,
    );
  }

  @override
  List<Object?> get props => [...super.props, selectedCountryId];
}
