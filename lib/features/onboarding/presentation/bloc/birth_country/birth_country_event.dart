import 'package:equatable/equatable.dart';
import 'package:immigru/core/country/domain/entities/country.dart';

/// Base class for birth country events
abstract class BirthCountryEvent extends Equatable {
  const BirthCountryEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when the birth country screen is initialized
class BirthCountryInitialized extends BirthCountryEvent {
  const BirthCountryInitialized();
}

/// Event triggered when a country is selected
class BirthCountrySelected extends BirthCountryEvent {
  final Country country;

  const BirthCountrySelected(this.country);

  @override
  List<Object?> get props => [country];
}

/// Event triggered when the country search query changes
class BirthCountrySearchQueryChanged extends BirthCountryEvent {
  final String query;

  const BirthCountrySearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

/// Event triggered when countries need to be reloaded
class BirthCountryReloadRequested extends BirthCountryEvent {
  const BirthCountryReloadRequested();
}
