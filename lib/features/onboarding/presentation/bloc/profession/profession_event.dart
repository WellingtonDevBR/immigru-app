import 'package:equatable/equatable.dart';
import 'package:immigru/features/onboarding/domain/entities/profession.dart';

/// Base class for all profession-related events
abstract class ProfessionEvent extends Equatable {
  /// Creates a new instance of [ProfessionEvent]
  const ProfessionEvent();

  @override
  List<Object?> get props => [];
}

/// Event fired when the profession step is initialized
class ProfessionInitialized extends ProfessionEvent {
  /// Creates a new instance of [ProfessionInitialized]
  const ProfessionInitialized();
}

/// Event fired when a profession is selected
class ProfessionSelected extends ProfessionEvent {
  /// The selected profession
  final Profession profession;

  /// Creates a new instance of [ProfessionSelected]
  const ProfessionSelected(this.profession);

  @override
  List<Object?> get props => [profession];
}

/// Event fired when a custom profession is entered
class CustomProfessionEntered extends ProfessionEvent {
  /// The custom profession name
  final String profession;
  
  /// The industry (optional)
  final String? industry;

  /// Creates a new instance of [CustomProfessionEntered]
  const CustomProfessionEntered(this.profession, {this.industry});

  @override
  List<Object?> get props => [profession, industry];
}

/// Event fired when the search query changes
class SearchQueryChanged extends ProfessionEvent {
  /// The search query
  final String query;

  /// Creates a new instance of [SearchQueryChanged]
  const SearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

/// Event fired when the custom input toggle is changed
class ShowCustomInputToggled extends ProfessionEvent {
  /// Whether to show the custom input
  final bool show;

  /// Creates a new instance of [ShowCustomInputToggled]
  const ShowCustomInputToggled(this.show);

  @override
  List<Object?> get props => [show];
}
