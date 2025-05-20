// ImmiGrove events for the onboarding flow
import '../onboarding/onboarding_event.dart';

/// Event triggered when ImmiGroves are updated
class ImmiGrovesUpdated extends OnboardingEvent {
  /// List of ImmiGrove IDs
  final List<String> immiGroveIds;

  /// Creates a new ImmiGrovesUpdated event
  const ImmiGrovesUpdated(this.immiGroveIds);

  @override
  List<Object?> get props => [immiGroveIds];
}

/// Event triggered when ImmiGroves need to be saved
class ImmiGrovesSaveRequested extends OnboardingEvent {
  /// List of ImmiGrove IDs to save
  final List<String> immiGroveIds;

  /// Creates a new ImmiGrovesSaveRequested event
  const ImmiGrovesSaveRequested(this.immiGroveIds);

  @override
  List<Object?> get props => [immiGroveIds];
}
