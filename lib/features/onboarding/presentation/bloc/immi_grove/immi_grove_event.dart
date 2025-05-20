import 'package:equatable/equatable.dart';

/// Base class for all ImmiGrove events
abstract class ImmiGroveEvent extends Equatable {
  /// Creates a new ImmiGroveEvent
  const ImmiGroveEvent();
  
  @override
  List<Object?> get props => [];
}

/// Event to load recommended ImmiGroves
class LoadRecommendedImmiGroves extends ImmiGroveEvent {
  /// Maximum number of ImmiGroves to load
  final int limit;
  
  /// Creates a new LoadRecommendedImmiGroves event
  const LoadRecommendedImmiGroves({this.limit = 6});
  
  @override
  List<Object?> get props => [limit];
}

/// Event to load ImmiGroves that the user has joined
class LoadJoinedImmiGroves extends ImmiGroveEvent {
  /// Creates a new LoadJoinedImmiGroves event
  const LoadJoinedImmiGroves();
}

/// Event to join an ImmiGrove
class JoinImmiGrove extends ImmiGroveEvent {
  /// ID of the ImmiGrove to join
  final String immiGroveId;
  
  /// Creates a new JoinImmiGrove event
  const JoinImmiGrove(this.immiGroveId);
  
  @override
  List<Object?> get props => [immiGroveId];
}

/// Event to leave an ImmiGrove
class LeaveImmiGrove extends ImmiGroveEvent {
  /// ID of the ImmiGrove to leave
  final String immiGroveId;
  
  /// Creates a new LeaveImmiGrove event
  const LeaveImmiGrove(this.immiGroveId);
  
  @override
  List<Object?> get props => [immiGroveId];
}

/// Event to save selected ImmiGroves
class SaveSelectedImmiGroves extends ImmiGroveEvent {
  /// List of ImmiGrove IDs to save
  final List<String> immiGroveIds;
  
  /// Creates a new SaveSelectedImmiGroves event
  const SaveSelectedImmiGroves(this.immiGroveIds);
  
  @override
  List<Object?> get props => [immiGroveIds];
}

/// Event to refresh ImmiGroves
class RefreshImmiGroves extends ImmiGroveEvent {
  /// Creates a new RefreshImmiGroves event
  const RefreshImmiGroves();
}

/// Event to preselect ImmiGroves
class ImmiGrovesPreselected extends ImmiGroveEvent {
  /// Set of ImmiGrove IDs to preselect
  final Set<String> immiGroveIds;
  
  /// Creates a new ImmiGrovesPreselected event
  const ImmiGrovesPreselected(this.immiGroveIds);
  
  @override
  List<Object?> get props => [immiGroveIds];
}
