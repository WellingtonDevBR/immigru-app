import 'package:equatable/equatable.dart';
import 'package:immigru/features/onboarding/domain/entities/migration_status.dart';

/// State for the current status step
class CurrentStatusState extends Equatable {
  final MigrationStatus? selectedStatus;
  final List<MigrationStatus> availableStatuses;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;

  const CurrentStatusState({
    this.selectedStatus,
    required this.availableStatuses,
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
  });

  /// Create the initial state
  factory CurrentStatusState.initial() {
    return CurrentStatusState(
      availableStatuses: MigrationStatus.getAvailableStatuses(),
    );
  }

  /// Create a copy of the state with updated fields
  CurrentStatusState copyWith({
    MigrationStatus? selectedStatus,
    List<MigrationStatus>? availableStatuses,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
  }) {
    return CurrentStatusState(
      selectedStatus: selectedStatus ?? this.selectedStatus,
      availableStatuses: availableStatuses ?? this.availableStatuses,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        selectedStatus,
        availableStatuses,
        isLoading,
        isSaving,
        errorMessage,
      ];
}
