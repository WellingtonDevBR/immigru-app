import 'package:equatable/equatable.dart';

/// Base class for all language events
abstract class LanguageEvent extends Equatable {
  const LanguageEvent();
  
  @override
  List<Object?> get props => [];
}

/// Event to load all available languages
class LanguagesLoaded extends LanguageEvent {
  const LanguagesLoaded();
}

/// Event to load user's selected languages
class UserLanguagesLoaded extends LanguageEvent {
  const UserLanguagesLoaded();
}

/// Event to toggle selection of a language
class LanguageToggled extends LanguageEvent {
  final String isoCode;
  
  const LanguageToggled(this.isoCode);
  
  @override
  List<Object?> get props => [isoCode];
}

/// Event to save selected languages
class LanguagesSaved extends LanguageEvent {
  final List<int> languageIds;
  
  const LanguagesSaved(this.languageIds);
  
  @override
  List<Object?> get props => [languageIds];
}

/// Event to update search query
class LanguageSearchUpdated extends LanguageEvent {
  final String query;
  
  const LanguageSearchUpdated(this.query);
  
  @override
  List<Object?> get props => [query];
}
