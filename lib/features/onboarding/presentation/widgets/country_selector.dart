import 'package:flutter/material.dart';
import 'package:immigru/new_core/country/domain/entities/country.dart';
import 'package:immigru/new_core/country/domain/usecases/get_countries_usecase.dart';
import 'package:immigru/new_core/di/service_locator.dart';
import 'package:immigru/presentation/theme/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// A dropdown widget for selecting a country
class CountrySelector extends StatefulWidget {
  /// Currently selected country
  final Country? selectedCountry;
  
  /// ISO code of the country to select (alternative to selectedCountry)
  final String? selectedCountryCode;

  /// Callback when a country is selected
  final Function(Country) onCountrySelected;

  /// Label for the dropdown
  final String label;

  /// Hint text when no country is selected
  final String hint;

  /// Whether the field is required
  final bool isRequired;

  /// Constructor
  const CountrySelector({
    super.key,
    this.selectedCountry,
    this.selectedCountryCode,
    required this.onCountrySelected,
    this.label = 'Country',
    this.hint = 'Select a country',
    this.isRequired = true,
  });

  @override
  State<CountrySelector> createState() => _CountrySelectorState();
}

class _CountrySelectorState extends State<CountrySelector> {
  // Countries data
  List<Country> _countries = [];
  List<Country> _filteredCountries = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Selected country
  Country? _selectedCountry;
  bool _showSelector = false;
  
  // Search controller
  late TextEditingController _searchController;
  
  // Popular countries (top 10 most common)
  List<Country> _popularCountries = [];
  List<Country> _otherCountries = [];
  
  // ISO codes of popular countries
  final List<String> _popularCountryCodes = [
    'US', 'GB', 'CA', 'AU', 'DE', 'FR', 'IT', 'ES', 'BR', 'IN', 'JP'
  ];

  @override
  void initState() {
    super.initState();
    _selectedCountry = widget.selectedCountry;
    _showSelector = _selectedCountry == null; // Show selector if no country is selected
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
    _loadCountries();
    
    // If we have a country code, try to find the country once countries are loaded
    if (widget.selectedCountryCode != null) {
      // We'll handle this in the _loadCountries callback
    }
  }

  @override
  void didUpdateWidget(CountrySelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCountry != widget.selectedCountry) {
      setState(() {
        _selectedCountry = widget.selectedCountry;
      });
    }
    
    // Handle country code changes
    if (oldWidget.selectedCountryCode != widget.selectedCountryCode && 
        widget.selectedCountryCode != null && 
        _countries.isNotEmpty) {
      // Find country by code when countries are loaded
      _findAndSelectCountryByCode(widget.selectedCountryCode!);
    }
  }
  
  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }
  
  void _onSearchChanged() {
    _filterCountries(_searchController.text);
  }
  
  void _filterCountries(String query) {
    final searchQuery = query.toLowerCase().trim();
    
    if (searchQuery.isEmpty) {
      setState(() {
        _filteredCountries = _countries;
      });
    } else {
      setState(() {
        _filteredCountries = _countries.where((country) => 
          country.name.toLowerCase().contains(searchQuery) ||
          (country.isoCode.toLowerCase().contains(searchQuery))
        ).toList();
      });
    }
    
    _separateCountries();
  }
  
  void _separateCountries() {
    // Separate into popular and other countries
    _popularCountries = _filteredCountries
        .where((country) => _popularCountryCodes.contains(country.isoCode))
        .toList();

    // Sort popular countries by their position in the popularCountryCodes list
    _popularCountries.sort((a, b) =>
        _popularCountryCodes.indexOf(a.isoCode) -
        _popularCountryCodes.indexOf(b.isoCode));

    // Get other countries and sort alphabetically
    _otherCountries = _filteredCountries
        .where((country) => !_popularCountryCodes.contains(country.isoCode))
        .toList();
    _otherCountries.sort((a, b) => a.name.compareTo(b.name));
  }

  /// Load countries from the repository
  Future<void> _loadCountries() async {
    try {
      final getCountriesUseCase = ServiceLocator.instance<GetCountriesUseCase>();
      final countries = await getCountriesUseCase();
      
      print('Loaded ${countries.length} countries in CountrySelector');
      
      // Separate popular countries
      final popular = <Country>[];
      final others = <Country>[];
      
      for (final country in countries) {
        if (_popularCountryCodes.contains(country.isoCode)) {
          popular.add(country);
        } else {
          others.add(country);
        }
      }
      
      // Sort both lists by name
      popular.sort((a, b) => a.name.compareTo(b.name));
      others.sort((a, b) => a.name.compareTo(b.name));
      
      setState(() {
        _countries = countries;
        _popularCountries = popular;
        _otherCountries = others;
        _filteredCountries = countries;
        _isLoading = false;
      });
      
      // If we have a country code, find and select the country
      if (widget.selectedCountryCode != null) {
        _findAndSelectCountryByCode(widget.selectedCountryCode!);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load countries';
        _isLoading = false;
      });
    }
  }
  
  /// Find a country by its ISO code and select it
  void _findAndSelectCountryByCode(String isoCode) {
    if (_countries.isEmpty) {
      print('Cannot find country by code $isoCode: countries list is empty');
      return;
    }
    
    try {
      // Try exact match first (case insensitive)
      final exactMatches = _countries.where(
        (c) => c.isoCode.toLowerCase() == isoCode.toLowerCase()
      ).toList();
      
      if (exactMatches.isNotEmpty) {
        final country = exactMatches.first;
        print('Found country by exact code match $isoCode: ${country.name}');
        _selectCountry(country);
        return;
      }
      
      // Try partial match
      final partialMatches = _countries.where(
        (c) => c.isoCode.toLowerCase().contains(isoCode.toLowerCase()) || 
               isoCode.toLowerCase().contains(c.isoCode.toLowerCase())
      ).toList();
      
      if (partialMatches.isNotEmpty) {
        final country = partialMatches.first;
        print('Found country by partial code match $isoCode: ${country.name}');
        _selectCountry(country);
        return;
      }
      
      // Try matching by country ID (some codes might be IDs)
      if (int.tryParse(isoCode) != null) {
        final idMatches = _countries.where(
          (c) => c.id == int.parse(isoCode)
        ).toList();
        
        if (idMatches.isNotEmpty) {
          final country = idMatches.first;
          print('Found country by ID match $isoCode: ${country.name}');
          _selectCountry(country);
          return;
        }
      }
      
      // If all else fails, use the first country
      print('Could not find country with code $isoCode, using first country: ${_countries.first.name}');
      _selectCountry(_countries.first);
    } catch (e) {
      print('Error finding country by code $isoCode: $e');
      if (_countries.isNotEmpty) {
        _selectCountry(_countries.first);
      }
    }
  }
  
  /// Helper method to select a country and notify the parent
  void _selectCountry(Country country) {
    setState(() {
      _selectedCountry = country;
      _showSelector = false;
    });
    
    // Notify the parent widget
    widget.onCountrySelected(country);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (widget.label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              widget.label,
              style: theme.textTheme.titleSmall?.copyWith(
                color: isDarkMode ? Colors.white70 : Colors.grey[700],
              ),
            ),
          ),

        // Loading state
        if (_isLoading)
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[850] : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
              ),
            ),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          )
        // Error state
        else if (_errorMessage != null)
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[850] : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.red[300]!,
              ),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red[300],
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _errorMessage!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.red[300],
                    ),
                  ),
                ],
              ),
            ),
          )
        // If country is selected and not showing selector, just show the selected country
        else if (_selectedCountry != null && !_showSelector)
          _buildSelectedCountryDisplay(theme, isDarkMode)
        // Otherwise show the country selector with search
        else
          _buildCountrySelector(theme, isDarkMode),
      ],
    );
  }
  
  Widget _buildSelectedCountryDisplay(ThemeData theme, bool isDarkMode) {
    return GestureDetector(
      onTap: () {
        // Clear the selected country to show the selector again
        setState(() {
          // Don't actually clear the selected country, just show the selector
          // We'll keep track of whether to show the selector or not
          _showSelector = true;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[850] : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primaryColor,
          ),
        ),
        child: Row(
          children: [
            // Country flag
            _buildCountryFlag(_selectedCountry!, isDarkMode, size: 32),
            const SizedBox(width: 12),
            
            // Country name
            Expanded(
              child: Text(
                _selectedCountry!.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ),
            
            // Edit button
            Icon(
              Icons.edit,
              color: AppColors.primaryColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCountrySelector(ThemeData theme, bool isDarkMode) {
    return Column(
      children: [
        // Search field
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search countries',
            prefixIcon: Icon(Icons.search, color: AppColors.primaryColor),
            filled: true,
            fillColor: isDarkMode ? Colors.grey[850] : Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primaryColor),
            ),
            suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: AppColors.primaryColor),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          ),
        ),
        const SizedBox(height: 12),
        
          
        // Country list
        Container(
          height: 250,
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[850] : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
            ),
          ),
          child: _filteredCountries.isEmpty
            ? Center(
                child: Text(
                  'No countries found',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDarkMode ? Colors.white70 : Colors.grey[700],
                  ),
                ),
              )
            : ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  // Popular countries section
                  if (_popularCountries.isNotEmpty && _searchController.text.isEmpty) ...[                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        'Popular Countries',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white70 : Colors.grey[700],
                        ),
                      ),
                    ),
                    ..._popularCountries.map((country) => _buildCountryItem(country, isDarkMode, theme)),
                    
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Divider(),
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        'All Countries',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white70 : Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                  
                  // All countries or search results
                  ...(_searchController.text.isEmpty ? _otherCountries : _filteredCountries)
                    .map((country) => _buildCountryItem(country, isDarkMode, theme)),
                ],
              ),
        ),
      ],
    );
  }
  
  Widget _buildCountryItem(Country country, bool isDarkMode, ThemeData theme) {
    final isSelected = _selectedCountry?.id == country.id;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedCountry = country;
          _showSelector = false; // Hide the selector after selection
        });
        widget.onCountrySelected(country);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected 
            ? AppColors.primaryColor.withOpacity(0.1) 
            : Colors.transparent,
        ),
        child: Row(
          children: [
            // Country flag
            _buildCountryFlag(country, isDarkMode),
            const SizedBox(width: 12),
            
            // Country name
            Expanded(
              child: Text(
                country.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                    ? AppColors.primaryColor
                    : isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ),
            
            // Selection indicator
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primaryColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCountryFlag(Country country, bool isDarkMode, {double size = 24}) {
    final flagUrl = 'https://flagcdn.com/w80/${country.isoCode.toLowerCase()}.png';
    
    return Container(
      width: size,
      height: size * 0.75, // Standard flag aspect ratio
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: CachedNetworkImage(
        imageUrl: flagUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
          child: Center(
            child: Text(
              country.isoCode.substring(0, 2),
              style: TextStyle(
                fontSize: size * 0.4,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white70 : Colors.grey[700],
              ),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
          child: Center(
            child: Text(
              country.isoCode.substring(0, 2),
              style: TextStyle(
                fontSize: size * 0.4,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white70 : Colors.grey[700],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
