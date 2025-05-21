import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/features/onboarding/presentation/bloc/birth_country/birth_country_bloc.dart';
import 'package:immigru/features/onboarding/presentation/bloc/birth_country/birth_country_event.dart';
import 'package:immigru/features/onboarding/presentation/bloc/birth_country/birth_country_state.dart';
import 'package:immigru/features/onboarding/presentation/bloc/onboarding/onboarding_event.dart';
import 'package:immigru/features/onboarding/presentation/common/base_onboarding_step.dart';
import 'package:immigru/features/onboarding/presentation/common/onboarding_step_header.dart';
import 'package:immigru/core/country/domain/entities/country.dart';
import 'package:immigru/core/di/service_locator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:immigru/shared/theme/app_colors.dart';

/// Widget for the birth country selection step in onboarding
///
/// This step allows users to select their birth country from a searchable list.
/// It follows the new architecture pattern using the BaseOnboardingStep.
class BirthCountryStep extends BaseOnboardingStep {
  /// The currently selected country ID
  final String? selectedCountryId;

  const BirthCountryStep({
    super.key,
    this.selectedCountryId,
  });

  @override
  State<BirthCountryStep> createState() => _BirthCountryStepState();
}

class _BirthCountryStepState extends BaseOnboardingStepState<BirthCountryStep>
    with SingleTickerProviderStateMixin {
  // Search controller
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // Animation controller for search box
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Selected country
  Country? _selectedCountry;

  // Flags for UI state
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Add listener to search controller
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Handle country selection
  void _handleCountrySelected(Country country) {
    HapticFeedback.selectionClick();

    setState(() {
      _selectedCountry = country;
    });

    // Update the onboarding bloc with the selected country
    addOnboardingEvent(BirthCountryUpdated(country));

    // Add a visual feedback before moving to next step
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected ${country.name} as your birth country'),
        backgroundColor: AppColors.primaryColor,
        duration: const Duration(milliseconds: 800),
      ),
    );

    // Automatically trigger next step after a short delay
    Future.delayed(const Duration(milliseconds: 1000), () {
      // Check if widget is still mounted before proceeding
      if (mounted) {
        goToNextStep();
      }
    });
  }

  /// Toggle search mode
  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (_isSearching) {
        _animationController.forward();
        _searchFocusNode.requestFocus();
      } else {
        _animationController.reverse();
        _searchController.clear();
        _searchFocusNode.unfocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ServiceLocator.instance<BirthCountryBloc>()
        ..add(const BirthCountryInitialized()),
      child: Builder(
        builder: (context) {
          return _buildContent(context);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const OnboardingStepHeader(
            title: 'Where were you born?',
            subtitle:
                'Select your country of birth to help us personalize your experience.',
            icon: Icons.public,
          ),

          // Info box
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
                  Icons.info_outline,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your birth country helps us understand your immigration journey better.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Search bar
          _buildSearchBar(isDarkMode, theme),

          const SizedBox(height: 16),

          // Country list
          Expanded(
            child: BlocBuilder<BirthCountryBloc, BirthCountryState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load countries',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.errorMessage!,
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            context.read<BirthCountryBloc>().add(
                                  const BirthCountryInitialized(),
                                );
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                // Filter countries based on search query
                final filteredCountries = _searchQuery.isEmpty
                    ? state.countries
                    : state.countries
                        .where((country) => country.name
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase()))
                        .toList();

                if (filteredCountries.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 48,
                          color:
                              isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No countries found',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try a different search term',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredCountries.length,
                  itemBuilder: (context, index) {
                    final country = filteredCountries[index];
                    final isSelected =
                        widget.selectedCountryId == country.isoCode ||
                            _selectedCountry?.isoCode == country.isoCode;

                    return _buildCountryItem(
                        country, isSelected, isDarkMode, theme);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDarkMode, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Container(
                height: 50,
                decoration: BoxDecoration(
                  color: isDarkMode ? AppColors.surfaceDark : Colors.grey[200],
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: _isSearching
                        ? AppColors.primaryColor
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Icon(
                      Icons.search,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        decoration: InputDecoration(
                          hintText: 'Search countries...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: isDarkMode ? Colors.white38 : Colors.black38,
                          ),
                        ),
                        style: theme.textTheme.bodyMedium,
                        onTap: () {
                          if (!_isSearching) {
                            _toggleSearch();
                          }
                        },
                      ),
                    ),
                    if (_isSearching && _searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        if (!_isSearching)
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _toggleSearch,
          ),
        if (_isSearching)
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _toggleSearch,
          ),
      ],
    );
  }

  Widget _buildCountryItem(
      Country country, bool isSelected, bool isDarkMode, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      color: isSelected
          ? AppColors.primaryColor.withValues(alpha: 0.15)
          : isDarkMode
              ? AppColors.cardDark
              : Colors.white,
      elevation: isSelected ? 2 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColors.primaryColor : Colors.transparent,
          width: isSelected ? 2 : 0,
        ),
      ),
      child: InkWell(
        onTap: () => _handleCountrySelected(country),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Flag
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: CachedNetworkImage(
                  imageUrl:
                      'https://flagcdn.com/w80/${country.isoCode.toLowerCase()}.png',
                  width: 40,
                  height: 30,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 40,
                    height: 30,
                    color: Colors.grey[300],
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 40,
                    height: 30,
                    color: Colors.grey[300],
                    child: const Icon(Icons.flag, size: 20),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Country name
              Expanded(
                child: Text(
                  country.name,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),

              // Selection indicator
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppColors.primaryColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
