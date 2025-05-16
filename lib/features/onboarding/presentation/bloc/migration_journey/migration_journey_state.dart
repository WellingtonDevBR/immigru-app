import 'package:equatable/equatable.dart';
import 'package:immigru/features/onboarding/domain/entities/migration_step.dart';

/// State for migration journey bloc
class MigrationJourneyState extends Equatable {
  /// List of migration steps
  final List<MigrationStep> steps;
  
  /// Whether the bloc is loading data
  final bool isLoading;
  
  /// Whether the bloc is saving data
  final bool isSaving;
  
  /// Error message, if any
  final String? errorMessage;
  
  /// Whether there are unsaved changes
  final bool hasChanges;

  /// Constructor
  const MigrationJourneyState({
    required this.steps,
    required this.isLoading,
    required this.isSaving,
    this.errorMessage,
    required this.hasChanges,
  });

  /// Initial state
  factory MigrationJourneyState.initial() {
    return const MigrationJourneyState(
      steps: [],
      isLoading: true,
      isSaving: false,
      errorMessage: null,
      hasChanges: false,
    );
  }

  /// Create a copy with updated fields
  MigrationJourneyState copyWith({
    List<MigrationStep>? steps,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
    bool? hasChanges,
  }) {
    return MigrationJourneyState(
      steps: steps ?? this.steps,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      hasChanges: hasChanges ?? this.hasChanges,
    );
  }

  @override
  List<Object?> get props => [
        steps,
        isLoading,
        isSaving,
        errorMessage,
        hasChanges,
      ];
}
