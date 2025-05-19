import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/new_core/country/domain/entities/country.dart';
import 'package:immigru/features/onboarding/domain/usecases/update_birth_country_usecase.dart';
import 'package:immigru/features/onboarding/presentation/bloc/birth_country/birth_country_event.dart';
import 'package:immigru/features/onboarding/presentation/bloc/birth_country/birth_country_state.dart';
import 'package:immigru/new_core/country/domain/usecases/get_countries_usecase.dart';
import 'package:immigru/shared/interfaces/logger_interface.dart';

/// BLoC for managing the birth country step in onboarding
class BirthCountryBloc extends Bloc<BirthCountryEvent, BirthCountryState> {
  final GetCountriesUseCase _getCountriesUseCase;
  final UpdateBirthCountryUseCase _updateBirthCountryUseCase;
  final LoggerInterface _logger;

  BirthCountryBloc({
    required GetCountriesUseCase getCountriesUseCase,
    required UpdateBirthCountryUseCase updateBirthCountryUseCase,
    required LoggerInterface logger,
  })  : _getCountriesUseCase = getCountriesUseCase,
        _updateBirthCountryUseCase = updateBirthCountryUseCase,
        _logger = logger,
        super(BirthCountryState.initial()) {
    on<BirthCountryInitialized>(_onInitialized);
    on<BirthCountrySelected>(_onCountrySelected);
    on<BirthCountrySearchQueryChanged>(_onSearchQueryChanged);
    on<BirthCountryReloadRequested>(_onReloadRequested);
  }

  /// Handle initialization event
  Future<void> _onInitialized(
    BirthCountryInitialized event,
    Emitter<BirthCountryState> emit,
  ) async {
    await _fetchCountries(emit);
  }

  /// Handle country selection event
  Future<void> _onCountrySelected(
    BirthCountrySelected event,
    Emitter<BirthCountryState> emit,
  ) async {
    try {
      emit(state.copyWith(
        selectedCountry: event.country,
        isLoading: true,
      ));

      // Save the selected country
      await _updateBirthCountryUseCase(event.country);

      emit(state.copyWith(
        isLoading: false,
      ));
    } catch (e, stackTrace) {
      _logger.e(
        'Error selecting birth country',
        tag: 'BirthCountry',
        error: e,
        stackTrace: stackTrace,
      );
      emit(state.copyWith(
        errorMessage: 'Failed to save country selection. Please try again.',
        isLoading: false,
      ));
    }
  }

  /// Handle search query change event
  void _onSearchQueryChanged(
    BirthCountrySearchQueryChanged event,
    Emitter<BirthCountryState> emit,
  ) {
    final query = event.query.toLowerCase();
    final filteredCountries = state.countries.where((country) {
      return country.name.toLowerCase().contains(query) ||
          country.nationality.toLowerCase().contains(query) ||
          country.isoCode.toLowerCase().contains(query);
    }).toList();

    emit(state.copyWith(
      searchQuery: event.query,
      filteredCountries: filteredCountries,
    ));
  }

  /// Handle reload request event
  Future<void> _onReloadRequested(
    BirthCountryReloadRequested event,
    Emitter<BirthCountryState> emit,
  ) async {
    await _fetchCountries(emit);
  }

  /// Fetch countries from the repository
  Future<void> _fetchCountries(Emitter<BirthCountryState> emit) async {
    try {
      emit(state.copyWith(
        isLoading: true,
        errorMessage: null,
      ));

      _logger.i('Fetching countries from repository', tag: 'BirthCountry');
      final countries = await _getCountriesUseCase();
      _logger.i('Received ${countries.length} countries from repository', tag: 'BirthCountry');

      if (countries.isEmpty) {
        _logger.w('No countries returned from repository', tag: 'BirthCountry');
        emit(state.copyWith(
          errorMessage: 'No countries available. Please try again later.',
          isLoading: false,
        ));
        return;
      }

      // Apply any existing search filter
      final filteredCountries = _filterCountries(countries, state.searchQuery);
      _logger.i('Filtered to ${filteredCountries.length} countries based on search query: "${state.searchQuery}"', tag: 'BirthCountry');

      // Log some sample countries to verify data format
      if (countries.isNotEmpty) {
        final sampleCountry = countries.first;
        _logger.i(
          'Sample country: ${sampleCountry.name} (${sampleCountry.isoCode}), ' 'Flag URL: ${sampleCountry.flagUrl.isNotEmpty ? "Valid" : "Empty"}',
          tag: 'BirthCountry',
        );
      }

      emit(state.copyWith(
        countries: countries,
        filteredCountries: filteredCountries,
        isLoading: false,
      ));
    } catch (e, stackTrace) {
      _logger.e(
        'Error fetching countries',
        tag: 'BirthCountry',
        error: e,
        stackTrace: stackTrace,
      );
      emit(state.copyWith(
        errorMessage: 'Failed to load countries. Please try again.',
        isLoading: false,
      ));
    }
  }

  /// Filter countries based on search query
  List<Country> _filterCountries(List<Country> countries, String query) {
    if (query.isEmpty) {
      return countries;
    }

    final lowerQuery = query.toLowerCase();
    return countries.where((country) {
      return country.name.toLowerCase().contains(lowerQuery) ||
          country.nationality.toLowerCase().contains(lowerQuery) ||
          country.isoCode.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
