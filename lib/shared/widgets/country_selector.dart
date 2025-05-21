import 'package:flutter/material.dart';
import 'package:immigru/core/country/domain/entities/country.dart';
import 'package:immigru/shared/theme/app_colors.dart';
import 'package:immigru/shared/widgets/loading_indicator.dart';
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
  });

  @override
  State<CountrySelector> createState() => _CountrySelectorState();
}

class _CountrySelectorState extends State<CountrySelector> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  List<Country> _filteredCountries = [];
  List<Country> _popularCountries = [];
  List<Country> _otherCountries = [];

  @override
  void initState() {
    super.initState();
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
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _filterCountries();
    });
  }

  /// Filter countries based on search query and separate into popular and other categories
  void _filterCountries() {
    // Popular country codes (can be customized)
    const popularCountryCodes = [
      'US',
      'CA',
      'GB',
      'AU',
      'BR',
      'IN',
      'CN',
      'JP',
      'DE',
      'FR'
    ];

    if (_searchQuery.isEmpty) {
      _filteredCountries = List.from(widget.countries);
    } else {
      final query = _searchQuery.toLowerCase();
      _filteredCountries = widget.countries.where((country) {
        return country.name.toLowerCase().contains(query) ||
            country.isoCode.toLowerCase().contains(query) ||
            country.nationality.toLowerCase().contains(query);
      }).toList();
    }

    if (widget.showPopularCountries) {
      _popularCountries = _filteredCountries
          .where((country) => popularCountryCodes.contains(country.isoCode))
          .toList();
      _otherCountries = _filteredCountries
          .where((country) => !popularCountryCodes.contains(country.isoCode))
          .toList();
    } else {
      _popularCountries = [];
      _otherCountries = _filteredCountries;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    if (widget.isLoading) {
      return const Center(
        child: LoadingIndicator(),
      );
    }

    if (widget.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.errorMessage!,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (widget.onRetry != null)
              ElevatedButton(
                onPressed: widget.onRetry,
                child: const Text('Retry'),
              ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Search field
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              hintText: widget.searchHint,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
            ),
          ),
        ),

        // Country list
        Expanded(
          child: _filteredCountries.isEmpty
              ? Center(
                  child: Text(
                    'No countries found',
                    style: theme.textTheme.bodyLarge,
                  ),
                )
              : ListView(
                  children: [
                    if (_popularCountries.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          top: 16,
                          bottom: 8,
                        ),
                        child: Text(
                          'Popular Countries',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ..._popularCountries.map(
                        (country) =>
                            _buildCountryItem(country, isDarkMode, theme),
                      ),
                      const Divider(),
                    ],
                    if (_otherCountries.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          top: 16,
                          bottom: 8,
                        ),
                        child: Text(
                          _popularCountries.isNotEmpty
                              ? 'Other Countries'
                              : 'All Countries',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ..._otherCountries.map(
                        (country) =>
                            _buildCountryItem(country, isDarkMode, theme),
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  /// Build a country item widget
  Widget _buildCountryItem(Country country, bool isDarkMode, ThemeData theme) {
    final isSelected = widget.selectedCountry?.isoCode == country.isoCode;

    return ListTile(
      leading: country.flagUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: country.flagUrl,
              width: 32,
              height: 24,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 32,
                height: 24,
                color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
              ),
              errorWidget: (context, url, error) => Container(
                width: 32,
                height: 24,
                color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                child: const Center(
                  child: Icon(
                    Icons.error_outline,
                    size: 16,
                    color: Colors.red,
                  ),
                ),
              ),
            )
          : Container(
              width: 32,
              height: 24,
              color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
              child: Center(
                child: Text(
                  country.isoCode.substring(0, 2),
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ),
      title: Text(country.name),
      subtitle: Text(country.isoCode),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: AppColors.primaryColor,
            )
          : null,
      selected: isSelected,
      onTap: () {
        widget.onCountrySelected(country);
      },
    );
  }
}
