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
  
  /// Success message, if any
  final String? successMessage;
  
  /// Whether there are unsaved changes
  final bool hasChanges;

  /// Constructor
  const MigrationJourneyState({
    required this.steps,
    required this.isLoading,
    required this.isSaving,
    this.errorMessage,
    this.successMessage,
    required this.hasChanges,
  });

  /// Initial state
  factory MigrationJourneyState.initial() {
    return const MigrationJourneyState(
      steps: [],
      isLoading: true,
      isSaving: false,
      errorMessage: null,
      successMessage: null,
      hasChanges: false,
    );
  }

  /// Create a copy with updated fields
  MigrationJourneyState copyWith({
    List<MigrationStep>? steps,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
    bool? hasChanges,
  }) {
    return MigrationJourneyState(
      steps: steps ?? this.steps,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      successMessage: clearSuccess ? null : successMessage ?? this.successMessage,
      hasChanges: hasChanges ?? this.hasChanges,
    );
  }

  @override
  List<Object?> get props => [
        steps,
        isLoading,
        isSaving,
        errorMessage,
        successMessage,
        hasChanges,
      ];
}
