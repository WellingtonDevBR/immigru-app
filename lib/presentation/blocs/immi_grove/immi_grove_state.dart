import 'package:equatable/equatable.dart';
import 'package:immigru/domain/entities/immi_grove.dart';

/// ImmiGrove state status
enum ImmiGroveStatus {
  initial,
  loading,
  loaded,
  joining,
  joined,
  leaving,
  left,
  error,
}

/// ImmiGrove state
class ImmiGroveState extends Equatable {
  final ImmiGroveStatus status;
  final List<ImmiGrove> recommendedImmiGroves;
  final List<ImmiGrove> joinedImmiGroves;
  final String? errorMessage;
  final bool isLoading;

  const ImmiGroveState({
    this.status = ImmiGroveStatus.initial,
    this.recommendedImmiGroves = const [],
    this.joinedImmiGroves = const [],
    this.errorMessage,
    this.isLoading = false,
  });

  /// Create a copy of the current state with updated values
  ImmiGroveState copyWith({
    ImmiGroveStatus? status,
    List<ImmiGrove>? recommendedImmiGroves,
    List<ImmiGrove>? joinedImmiGroves,
    String? errorMessage,
    bool? isLoading,
  }) {
    return ImmiGroveState(
      status: status ?? this.status,
      recommendedImmiGroves: recommendedImmiGroves ?? this.recommendedImmiGroves,
      joinedImmiGroves: joinedImmiGroves ?? this.joinedImmiGroves,
      errorMessage: errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
        status,
        recommendedImmiGroves,
        joinedImmiGroves,
        errorMessage,
        isLoading,
      ];
}
