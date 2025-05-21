import 'package:equatable/equatable.dart';
import 'package:immigru/core/country/domain/entities/country.dart';

/// State for the birth country step
class BirthCountryState extends Equatable {
  final List<Country> countries;
  final Country? selectedCountry;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;
  final List<Country> filteredCountries;

  const BirthCountryState({
    this.countries = const [],
    this.selectedCountry,
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
    this.filteredCountries = const [],
  });

  /// Initial state for the birth country step
  factory BirthCountryState.initial() {
    return const BirthCountryState(
      isLoading: true,
    );
  }

  /// Create a copy of this state with updated properties
  BirthCountryState copyWith({
    List<Country>? countries,
    Country? selectedCountry,
    bool? isLoading,
    String? errorMessage,
    String? searchQuery,
    List<Country>? filteredCountries,
  }) {
    return BirthCountryState(
      countries: countries ?? this.countries,
      selectedCountry: selectedCountry ?? this.selectedCountry,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      filteredCountries: filteredCountries ?? this.filteredCountries,
    );
  }

  @override
  List<Object?> get props => [
        countries,
        selectedCountry,
        isLoading,
        errorMessage,
        searchQuery,
        filteredCountries,
      ];
}
