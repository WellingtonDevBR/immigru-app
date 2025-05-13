import 'package:equatable/equatable.dart';

/// Base class for all ImmiGrove events
abstract class ImmiGroveEvent extends Equatable {
  const ImmiGroveEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load recommended ImmiGroves
class LoadRecommendedImmiGroves extends ImmiGroveEvent {
  final int limit;

  const LoadRecommendedImmiGroves({this.limit = 6});

  @override
  List<Object?> get props => [limit];
}

/// Event to join an ImmiGrove
class JoinImmiGrove extends ImmiGroveEvent {
  final String immiGroveId;

  const JoinImmiGrove(this.immiGroveId);

  @override
  List<Object?> get props => [immiGroveId];
}

/// Event to leave an ImmiGrove
class LeaveImmiGrove extends ImmiGroveEvent {
  final String immiGroveId;

  const LeaveImmiGrove(this.immiGroveId);

  @override
  List<Object?> get props => [immiGroveId];
}

/// Event to load ImmiGroves that the user has joined
class LoadJoinedImmiGroves extends ImmiGroveEvent {
  const LoadJoinedImmiGroves();
}

/// Event to refresh ImmiGrove data
class RefreshImmiGroves extends ImmiGroveEvent {
  const RefreshImmiGroves();
}
