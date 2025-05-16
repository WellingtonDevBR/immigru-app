import 'package:equatable/equatable.dart';

/// State for the welcome screen
class WelcomeState extends Equatable {
  /// Whether the welcome animations are playing
  final bool isAnimating;
  
  /// Whether the welcome screen has been seen before
  final bool hasBeenSeen;
  
  /// Whether there was an error
  final String? errorMessage;

  /// Creates a new welcome state
  const WelcomeState({
    this.isAnimating = false,
    this.hasBeenSeen = false,
    this.errorMessage,
  });

  /// Creates the initial welcome state
  factory WelcomeState.initial() => const WelcomeState();

  /// Creates a copy of this state with the given fields replaced
  WelcomeState copyWith({
    bool? isAnimating,
    bool? hasBeenSeen,
    String? errorMessage,
  }) {
    return WelcomeState(
      isAnimating: isAnimating ?? this.isAnimating,
      hasBeenSeen: hasBeenSeen ?? this.hasBeenSeen,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [isAnimating, hasBeenSeen, errorMessage];
}
