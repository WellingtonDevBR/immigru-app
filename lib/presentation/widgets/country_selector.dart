import 'package:flutter/material.dart';
import 'package:immigru/domain/entities/country.dart';
import 'package:immigru/presentation/theme/app_colors.dart';
import 'package:immigru/presentation/widgets/loading_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// A reusable country selector widget that can be used across the application
/// for consistent country selection UI
class CountrySelector extends StatefulWidget {
  /// List of countries to display
  final List<Country> countries;

  /// Currently selected country
  final Country? selectedCountry;

  /// Callback when a country is selected
  final Function(Country) onCountrySelected;

  /// Hint text for the search field
  final String searchHint;

  /// Whether to show popular countries at the top
  final bool showPopularCountries;

  /// Whether the component is in loading state
  final bool isLoading;

  /// Error message to display if there's an error
  final String? errorMessage;

  /// Callback to retry loading countries if there's an error
  final VoidCallback? onRetry;

  /// Whether the component is compact
  final bool isCompact;

  const CountrySelector({
    super.key,
    required this.countries,
    this.selectedCountry,
    required this.onCountrySelected,
    this.searchHint = 'Search for a country',
    this.showPopularCountries = true,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
    this.isCompact = false,
  });

  @override
  State<CountrySelector> createState() => _CountrySelectorState();
}

class _CountrySelectorState extends State<CountrySelector> {
  // Search controller
  late TextEditingController _searchController;

  // Filtered countries
  List<Country> _filteredCountries = [];

  // Popular countries (top 20 most common)
  List<Country> _popularCountries = [];

  // Other countries
  List<Country> _otherCountries = [];

  // Search query
  String _searchQuery = '';

  // ISO codes of popular countries
  final List<String> _popularCountryCodes = [
    'US',
    'GB',
    'CA',
    'AU',
    'DE',
    'FR',
    'IT',
    'ES',
    'BR',
    'IN',
    'CN',
    'JP',
    'RU',
    'MX',
    'ZA',
    'KR',
    'NZ',
    'SG',
    'AE',
    'IE'
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
    _filterCountries();
  }

  @override
  void didUpdateWidget(CountrySelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.countries != widget.countries) {
      _filterCountries();
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
      _filterCountries();
    });
  }

  /// Filter countries based on search query and separate into popular and other categories
  void _filterCountries() {
    // Filter countries based on search query
    List<Country> filtered;
    if (_searchQuery.isEmpty) {
      // Show all countries
      filtered = widget.countries;
    } else {
      // Filter by search query
      filtered = widget.countries
          .where((country) =>
              country.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              country.officialName
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              country.nationality
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    if (widget.showPopularCountries) {
      // Separate into popular and other countries
      _popularCountries = filtered
          .where((country) => _popularCountryCodes.contains(country.isoCode))
          .toList();

      // Sort popular countries by their position in the popularCountryCodes list
      _popularCountries.sort((a, b) =>
          _popularCountryCodes.indexOf(a.isoCode) -
          _popularCountryCodes.indexOf(b.isoCode));

      // Get other countries and sort alphabetically
      _otherCountries = filtered
          .where((country) => !_popularCountryCodes.contains(country.isoCode))
          .toList();
      _otherCountries.sort((a, b) => a.name.compareTo(b.name));
    } else {
      _popularCountries = [];
      _otherCountries = filtered;
      _otherCountries.sort((a, b) => a.name.compareTo(b.name));
    }

    // Update filtered countries list
    _filteredCountries = filtered;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Loading state
    if (widget.isLoading) {
      return ShimmerLoadingList(
        itemCount: 10,
        itemHeight: 70,
        isDarkMode: isDarkMode,
      );
    }

    // Error state
    if (widget.errorMessage != null) {
      return ErrorStateWidget(
        errorMessage: widget.errorMessage,
        onRetry: widget.onRetry,
      );
    }

    // Empty state
    if (_filteredCountries.isEmpty) {
      return EmptyStateWidget(
        message: 'No countries found',
        icon: Icons.search_off,
        actionText: 'Clear Search',
        onAction: () {
          _searchController.clear();
          _onSearchChanged();
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search field with brand colors
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: widget.searchHint,
            prefixIcon: Icon(Icons.search, color: AppColors.primaryColor),
            filled: true,
            fillColor: isDarkMode ? AppColors.darkSurface : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primaryColor.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primaryColor.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primaryColor),
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: AppColors.primaryColor),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged();
                    },
                  )
                : null,
          ),
        ),
        const SizedBox(height: 16),

        // Country list
        Expanded(
          child: ListView(
            children: [
              // Popular countries section
              if (_popularCountries.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Popular Countries',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ..._popularCountries.map(
                    (country) => _buildCountryItem(country, isDarkMode, theme)),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'All Countries',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],

              // Other countries
              ..._otherCountries.map(
                  (country) => _buildCountryItem(country, isDarkMode, theme)),
            ],
          ),
        ),
      ],
    );
  }

  /// Build a country item widget
  Widget _buildCountryItem(Country country, bool isDarkMode, ThemeData theme) {
    final isSelected = widget.selectedCountry?.isoCode == country.isoCode;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onCountrySelected(country),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryColor.withValues(alpha: 0.15)
                  : isDarkMode
                      ? AppColors.cardDark
                      : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primaryColor.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ],
              border: isSelected
                  ? Border.all(color: AppColors.primaryColor, width: 2)
                  : Border.all(
                      color: isDarkMode
                          ? AppColors.borderDark
                          : AppColors.borderLight,
                      width: 1),
            ),
            child: Row(
              children: [
                // Country flag
                Container(
                  width: 48,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: country.flagUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: country.flagUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: isDarkMode
                                ? AppColors.surfaceDark
                                : AppColors.surfaceLight,
                            child: Center(
                              child: Text(
                                country.isoCode.substring(0, 2),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight,
                                ),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: isDarkMode
                                ? AppColors.surfaceDark
                                : AppColors.surfaceLight,
                            child: Center(
                              child: Text(
                                country.isoCode.substring(0, 2),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight,
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(
                          color: isDarkMode
                              ? AppColors.surfaceDark
                              : AppColors.surfaceLight,
                          child: Center(
                            child: Text(
                              country.isoCode.substring(0, 2),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                              ),
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 16),

                // Country details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        country.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? AppColors.primaryColor
                              : isDarkMode
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                        ),
                      ),
                      if (country.nationality.isNotEmpty)
                        Text(
                          country.nationality,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isSelected
                                ? AppColors.primaryColor.withValues(alpha: 0.8)
                                : isDarkMode
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                          ),
                        ),
                    ],
                  ),
                ),

                // Selection indicator
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
