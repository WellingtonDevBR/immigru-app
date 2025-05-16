import 'package:equatable/equatable.dart';

/// Base class for all welcome events
abstract class WelcomeEvent extends Equatable {
  const WelcomeEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when the welcome screen is initialized
class WelcomeInitialized extends WelcomeEvent {
  const WelcomeInitialized();
}

/// Event triggered when the user completes the welcome screen
class WelcomeCompleted extends WelcomeEvent {
  const WelcomeCompleted();
}
