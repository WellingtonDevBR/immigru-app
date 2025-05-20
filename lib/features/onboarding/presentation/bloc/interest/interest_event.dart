import 'package:equatable/equatable.dart';

/// Base class for all interest events
abstract class InterestEvent extends Equatable {
  const InterestEvent();
  
  @override
  List<Object?> get props => [];
}

/// Event to load all available interests
class InterestsLoaded extends InterestEvent {
  const InterestsLoaded();
}

/// Event to load user's selected interests
class UserInterestsLoaded extends InterestEvent {
  const UserInterestsLoaded();
}

/// Event to toggle selection of an interest
class InterestToggled extends InterestEvent {
  final int interestId;
  
  const InterestToggled(this.interestId);
  
  @override
  List<Object?> get props => [interestId];
}

/// Event to save selected interests
class InterestsSaved extends InterestEvent {
  final List<int> interestIds;
  
  const InterestsSaved(this.interestIds);
  
  @override
  List<Object?> get props => [interestIds];
}

/// Event to update search query
class InterestSearchUpdated extends InterestEvent {
  final String query;
  
  const InterestSearchUpdated(this.query);
  
  @override
  List<Object?> get props => [query];
}
