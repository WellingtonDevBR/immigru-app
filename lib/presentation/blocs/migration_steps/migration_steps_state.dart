import 'package:equatable/equatable.dart';
import 'package:immigru/domain/entities/onboarding_data.dart';

/// State for the migration steps BLoC
class MigrationStepsState extends Equatable {
  final List<MigrationStep> steps;
  final bool isLoading;
  final bool isSaving;
  final bool hasChanges;
  final String? errorMessage;
  final DateTime? lastSavedAt;

  const MigrationStepsState({
    required this.steps,
    required this.isLoading,
    required this.isSaving,
    required this.hasChanges,
    this.errorMessage,
    this.lastSavedAt,
  });

  /// Initial state
  factory MigrationStepsState.initial() {
    return const MigrationStepsState(
      steps: [],
      isLoading: false,
      isSaving: false,
      hasChanges: false,
    );
  }

  /// Create a copy of this state with the given fields replaced
  MigrationStepsState copyWith({
    List<MigrationStep>? steps,
    bool? isLoading,
    bool? isSaving,
    bool? hasChanges,
    String? errorMessage,
    DateTime? lastSavedAt,
  }) {
    return MigrationStepsState(
      steps: steps ?? this.steps,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      hasChanges: hasChanges ?? this.hasChanges,
      errorMessage: errorMessage,
      lastSavedAt: lastSavedAt ?? this.lastSavedAt,
    );
  }

  @override
  List<Object?> get props => [
        steps,
        isLoading,
        isSaving,
        hasChanges,
        errorMessage,
        lastSavedAt,
      ];
}
