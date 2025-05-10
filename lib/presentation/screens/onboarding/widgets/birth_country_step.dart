import 'package:flutter/material.dart';
import 'package:immigru/presentation/theme/app_colors.dart';

/// Widget for the birth country selection step in onboarding
class BirthCountryStep extends StatefulWidget {
  final String? selectedCountry;
  final Function(String) onCountrySelected;

  const BirthCountryStep({
    Key? key,
    this.selectedCountry,
    required this.onCountrySelected,
  }) : super(key: key);

  @override
  State<BirthCountryStep> createState() => _BirthCountryStepState();
}

class _BirthCountryStepState extends State<BirthCountryStep> {
  // List of common countries (this would typically come from an API or larger dataset)
  final List<String> _commonCountries = [
    'Australia',
    'Brazil',
    'Canada',
    'China',
    'France',
    'Germany',
    'India',
    'Indonesia',
    'Italy',
    'Japan',
    'Mexico',
    'Nigeria',
    'Philippines',
    'Russia',
    'South Korea',
    'Spain',
    'United Kingdom',
    'United States',
    'Vietnam',
  ];

  // Controller for the search field
  late TextEditingController _searchController;
  
  // Filtered countries based on search
  List<String> _filteredCountries = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredCountries = _commonCountries;
    
    // Set initial search text if a country is already selected
    if (widget.selectedCountry != null && widget.selectedCountry!.isNotEmpty) {
      _searchController.text = widget.selectedCountry!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filter countries based on search query
  void _filterCountries(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCountries = _commonCountries;
      } else {
        _filteredCountries = _commonCountries
            .where((country) => 
                country.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Your Journey',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Subtitle
          Text(
            'Track your migration path and future goals',
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Country of birth label
          Text(
            'Country of Birth',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Country search field
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDarkMode ? AppColors.borderDark : AppColors.borderLight,
                width: 1,
              ),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _filterCountries,
              decoration: InputDecoration(
                hintText: 'Select your country of birth',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterCountries('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Country list
          Expanded(
            child: _filteredCountries.isEmpty
                ? Center(
                    child: Text(
                      'No countries found',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredCountries.length,
                    itemBuilder: (context, index) {
                      final country = _filteredCountries[index];
                      final isSelected = widget.selectedCountry == country;
                      
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary.withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : Colors.transparent,
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isSelected
                                ? theme.colorScheme.primary
                                : isDarkMode
                                    ? AppColors.surfaceDark
                                    : AppColors.surfaceLight,
                            child: Text(
                              country.substring(0, 1),
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : isDarkMode
                                        ? Colors.white
                                        : Colors.black87,
                              ),
                            ),
                          ),
                          title: Text(
                            country,
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle,
                                  color: theme.colorScheme.primary,
                                )
                              : null,
                          onTap: () {
                            widget.onCountrySelected(country);
                            _searchController.text = country;
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
