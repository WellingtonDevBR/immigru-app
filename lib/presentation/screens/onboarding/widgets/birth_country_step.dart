import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/core/di/injection_container.dart' as di;
import 'package:immigru/domain/entities/country.dart';
import 'package:immigru/domain/usecases/country_usecases.dart';
import 'package:immigru/presentation/blocs/onboarding/onboarding_bloc.dart';
import 'package:immigru/presentation/blocs/onboarding/onboarding_event.dart';
import 'package:immigru/presentation/theme/app_colors.dart';
import 'package:immigru/presentation/widgets/country_selector.dart';

/// Widget for the birth country selection step in onboarding
/// Uses the shared CountrySelector component for consistent UI
class BirthCountryStep extends StatefulWidget {
  final Function(Country) onCountrySelected;
  final String? selectedCountryId;

  const BirthCountryStep({
    super.key,
    required this.onCountrySelected,
    this.selectedCountryId,
  });

  @override
  State<BirthCountryStep> createState() => _BirthCountryStepState();
}

class _BirthCountryStepState extends State<BirthCountryStep> {
  // Country data
  final GetCountriesUseCase _countriesUseCase = di.sl<GetCountriesUseCase>();
  List<Country> _countries = [];
  bool _isLoading = true;
  String? _errorMessage;
  Country? _selectedCountry;

  @override
  void initState() {
    super.initState();
    _fetchCountries();
  }

  /// Fetch countries from the repository
  Future<void> _fetchCountries() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final countries = await _countriesUseCase();

      setState(() {
        _countries = countries;
        _isLoading = false;

        // Set selected country if ID was provided
        if (widget.selectedCountryId != null &&
            widget.selectedCountryId!.isNotEmpty &&
            _countries.isNotEmpty) {
          try {
            final matchingCountries = _countries
                .where((country) => country.isoCode == widget.selectedCountryId)
                .toList();

            if (matchingCountries.isNotEmpty) {
              _selectedCountry = matchingCountries.first;
            }
          } catch (e) {
            // Ignore errors when trying to set initial selection
          }
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load countries. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      color: isDarkMode ? AppColors.darkBackground : Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Animated header with brand colors
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColors.primaryColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.public,
                    color: AppColors.primaryColor,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'I was born in...',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Select your country of birth to continue',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDarkMode
                                ? Colors.grey[300]
                                : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Country selector component with auto-navigation
            Expanded(
              child: CountrySelector(
                countries: _countries,
                selectedCountry: _selectedCountry,
                onCountrySelected: (country) {
                  setState(() {
                    _selectedCountry = country;
                  });

                  // Call the callback to move to the next step
                  widget.onCountrySelected(country);

                  // Add a visual feedback before moving to next step
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Selected ${country.name} as your birth country'),
                      backgroundColor: AppColors.primaryColor,
                      duration: const Duration(milliseconds: 800),
                    ),
                  );

                  // Automatically trigger next step after a short delay
                  // Store the bloc reference before the async operation
                  final onboardingBloc =
                      BlocProvider.of<OnboardingBloc>(context);

                  Future.delayed(const Duration(milliseconds: 1000), () {
                    // Check if widget is still mounted before using the bloc
                    if (mounted) {
                      // Use the stored bloc reference
                      onboardingBloc.add(const NextStepRequested());
                    }
                  });
                },
                isLoading: _isLoading,
                errorMessage: _errorMessage,
                onRetry: _fetchCountries,
                searchHint: 'Search for your birth country',
              ),
            ),
          ],
        ), // <-- closes Column
      ),
    );
  }
}
