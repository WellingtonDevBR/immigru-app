import 'package:equatable/equatable.dart';
import '../../../domain/entities/immi_grove.dart';

/// Status of ImmiGrove operations
enum ImmiGroveStatus {
  /// Initial state
  initial,
  
  /// Loading data
  loading,
  
  /// Data loaded successfully
  loaded,
  
  /// Error occurred
  error,
  
  /// Saving data
  saving,
  
  /// Data saved successfully
  saved,
}

/// State for ImmiGrove operations
class ImmiGroveState extends Equatable {
  /// Status of ImmiGrove operations
  final ImmiGroveStatus status;
  
  /// List of recommended ImmiGroves
  final List<ImmiGrove> recommendedImmiGroves;
  
  /// List of ImmiGroves that the user has joined
  final List<ImmiGrove> joinedImmiGroves;
  
  /// Set of selected ImmiGrove IDs
  final Set<String> selectedImmiGroveIds;
  
  /// Whether data is being loaded
  final bool isLoading;
  
  /// Error message if an error occurred
  final String? errorMessage;

  /// Creates a new ImmiGroveState
  const ImmiGroveState({
    this.status = ImmiGroveStatus.initial,
    this.recommendedImmiGroves = const [],
    this.joinedImmiGroves = const [],
    this.selectedImmiGroveIds = const {},
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
    status,
    recommendedImmiGroves,
    joinedImmiGroves,
    selectedImmiGroveIds,
    isLoading,
    errorMessage,
  ];

  /// Creates a copy of this ImmiGroveState with the given fields replaced with new values
  ImmiGroveState copyWith({
    ImmiGroveStatus? status,
    List<ImmiGrove>? recommendedImmiGroves,
    List<ImmiGrove>? joinedImmiGroves,
    Set<String>? selectedImmiGroveIds,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ImmiGroveState(
      status: status ?? this.status,
      recommendedImmiGroves: recommendedImmiGroves ?? this.recommendedImmiGroves,
      joinedImmiGroves: joinedImmiGroves ?? this.joinedImmiGroves,
      selectedImmiGroveIds: selectedImmiGroveIds ?? this.selectedImmiGroveIds,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
