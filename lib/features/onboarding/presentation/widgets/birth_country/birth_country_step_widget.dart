import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:immigru/new_core/country/domain/entities/country.dart';
import 'package:immigru/features/onboarding/presentation/bloc/birth_country/birth_country_bloc.dart';
import 'package:immigru/features/onboarding/presentation/bloc/birth_country/birth_country_event.dart';
import 'package:immigru/features/onboarding/presentation/bloc/birth_country/birth_country_state.dart';
import 'package:immigru/new_core/di/service_locator.dart';
import 'package:immigru/shared/theme/app_colors.dart';
// No longer using the CountrySelector widget as we've built a custom implementation
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math' as math;

/// Widget for the birth country selection step in onboarding
class BirthCountryStepWidget extends StatelessWidget {
  final Function(Country) onCountrySelected;
  final String? selectedCountryId;

  const BirthCountryStepWidget({
    super.key,
    required this.onCountrySelected,
    this.selectedCountryId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ServiceLocator.instance<BirthCountryBloc>()
        ..add(const BirthCountryInitialized()),
      child: _BirthCountryStepContent(
        onCountrySelected: onCountrySelected,
        selectedCountryId: selectedCountryId,
      ),
    );
  }
}

class _BirthCountryStepContent extends StatefulWidget {
  final Function(Country) onCountrySelected;
  final String? selectedCountryId;

  const _BirthCountryStepContent({
    required this.onCountrySelected,
    this.selectedCountryId,
  });

  @override
  State<_BirthCountryStepContent> createState() => _BirthCountryStepContentState();
}

class _BirthCountryStepContentState extends State<_BirthCountryStepContent> with SingleTickerProviderStateMixin {
  late TextEditingController _searchController;
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Track if a country has been selected
  bool _countrySelected = false;
  
  // Popular countries to highlight
  final List<String> _popularCountryCodes = ['US', 'CA', 'GB', 'AU', 'BR', 'IN', 'CN', 'JP', 'DE', 'FR'];
  
  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    
    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _fadeInAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    // Start animations
    _animationController.forward();
    
    // Add haptic feedback when screen appears
    Future.delayed(const Duration(milliseconds: 100), () {
      HapticFeedback.lightImpact();
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return BlocConsumer<BirthCountryBloc, BirthCountryState>(
      listener: (context, state) {
        // Handle country selection
        if (state.selectedCountry != null && !state.isLoading && !_countrySelected) {
          setState(() {
            _countrySelected = true;
          });
          
          // Provide haptic feedback
          HapticFeedback.mediumImpact();
          
          // Animate out before navigating
          _animationController.reverse().then((_) {
            // Notify parent about country selection
            widget.onCountrySelected(state.selectedCountry!);
          });
        }
      },
      builder: (context, state) {
        // Set initial selection if ID was provided
        if (widget.selectedCountryId != null && 
            widget.selectedCountryId!.isNotEmpty && 
            state.selectedCountry == null && 
            !state.isLoading && 
            state.countries.isNotEmpty) {
          final matchingCountries = state.countries
              .where((country) => country.isoCode == widget.selectedCountryId)
              .toList();

          if (matchingCountries.isNotEmpty) {
            // Use a post-frame callback to avoid triggering during build
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<BirthCountryBloc>().add(
                    BirthCountrySelected(matchingCountries.first),
                  );
            });
          }
        }

        // Separate countries into popular and other
        List<Country> popularCountries = [];
        List<Country> otherCountries = [];
        
        if (!state.isLoading && state.countries.isNotEmpty) {
          popularCountries = state.countries
              .where((country) => _popularCountryCodes.contains(country.isoCode))
              .toList();
          
          otherCountries = state.countries
              .where((country) => !_popularCountryCodes.contains(country.isoCode))
              .toList();
        }

        return Container(
          color: isDarkMode ? AppColors.darkBackground : Colors.white,
          child: FadeTransition(
            opacity: _fadeInAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    
                    // Progress indicator
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: LinearProgressIndicator(
                        value: 0.1, // First step
                        backgroundColor: isDarkMode 
                            ? Colors.grey[800] 
                            : Colors.grey[200],
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(10),
                        minHeight: 6,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Animated header with brand colors and illustration
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryColor.withValues(alpha:0.7),
                            AppColors.primaryColor,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryColor.withValues(alpha:0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Left side: Text
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Where were you born?',
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'This helps us personalize your experience',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withValues(alpha:0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Right side: Globe illustration
                          Expanded(
                            flex: 2,
                            child: Transform.rotate(
                              angle: -math.pi / 20, // Slight tilt for visual interest
                              child: Container(
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha:0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.public,
                                    color: AppColors.primaryColor,
                                    size: 60,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Search field
                    Container(
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[850] : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha:0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          context.read<BirthCountryBloc>().add(
                                BirthCountrySearchQueryChanged(value),
                              );
                        },
                        decoration: InputDecoration(
                          hintText: 'Search for your birth country',
                          prefixIcon: const Icon(Icons.search),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    context.read<BirthCountryBloc>().add(
                                          const BirthCountrySearchQueryChanged(''),
                                        );
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Loading, error, or country list
                    Expanded(
                      child: _buildCountryList(
                        state, 
                        popularCountries, 
                        otherCountries, 
                        isDarkMode, 
                        theme,
                        size,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildCountryList(
    BirthCountryState state, 
    List<Country> popularCountries, 
    List<Country> otherCountries, 
    bool isDarkMode, 
    ThemeData theme,
    Size size,
  ) {
    if (state.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primaryColor),
            const SizedBox(height: 16),
            Text(
              'Loading countries...',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
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
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              state.errorMessage!,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<BirthCountryBloc>().add(
                      const BirthCountryReloadRequested(),
                    );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      );
    }
    
    // No search results
    if (_searchController.text.isNotEmpty && state.filteredCountries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: isDarkMode ? Colors.white54 : Colors.black38,
            ),
            const SizedBox(height: 16),
            Text(
              'No countries found matching "${_searchController.text}"',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                _searchController.clear();
                context.read<BirthCountryBloc>().add(
                      const BirthCountrySearchQueryChanged(''),
                    );
              },
              child: const Text('Clear Search'),
            ),
          ],
        ),
      );
    }
    
    // Country grid/list view
    final displayCountries = _searchController.text.isNotEmpty
        ? state.filteredCountries
        : [...popularCountries, ...otherCountries];
    
    // Use grid for larger screens, list for smaller ones
    final isWideScreen = size.width > 600;
    
    if (isWideScreen) {
      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: displayCountries.length,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          return _buildCountryCard(
            displayCountries[index],
            state.selectedCountry?.isoCode == displayCountries[index].isoCode,
            isDarkMode,
            theme,
          );
        },
      );
    }
    
    return ListView.builder(
      itemCount: _searchController.text.isEmpty && popularCountries.isNotEmpty
          ? displayCountries.length + 1 // +1 for the popular countries header
          : displayCountries.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        // Show popular countries header if needed
        if (_searchController.text.isEmpty && popularCountries.isNotEmpty) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
              child: Text(
                'Popular Countries',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
            );
          }
          
          // Adjust index to account for header
          final countryIndex = index - 1;
          if (countryIndex < displayCountries.length) {
            return _buildCountryCard(
              displayCountries[countryIndex],
              state.selectedCountry?.isoCode == displayCountries[countryIndex].isoCode,
              isDarkMode,
              theme,
            );
          }
        }
        
        // Regular list without header
        return _buildCountryCard(
          displayCountries[index],
          state.selectedCountry?.isoCode == displayCountries[index].isoCode,
          isDarkMode,
          theme,
        );
      },
    );
  }
  
  Widget _buildCountryCard(Country country, bool isSelected, bool isDarkMode, ThemeData theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primaryColor.withValues(alpha:isDarkMode ? 0.3 : 0.1)
            : isDarkMode
                ? Colors.grey[850]
                : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? AppColors.primaryColor
              : isDarkMode
                  ? Colors.grey[700]!
                  : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.primaryColor.withValues(alpha:0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
      ),
      child: InkWell(
        onTap: () {
          if (!isSelected) {
            context.read<BirthCountryBloc>().add(
                  BirthCountrySelected(country),
                );
            
            // Provide haptic feedback
            HapticFeedback.selectionClick();
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Flag
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: country.flagUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: country.flagUrl,
                        width: 36,
                        height: 24,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 36,
                          height: 24,
                          color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 36,
                          height: 24,
                          color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                          child: Center(
                            child: Text(
                              country.isoCode.substring(0, 2),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(
                        width: 36,
                        height: 24,
                        color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                        child: Center(
                          child: Text(
                            country.isoCode.substring(0, 2),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              
              // Country name
              Expanded(
                child: Text(
                  country.name,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? AppColors.primaryColor
                        : isDarkMode
                            ? Colors.white
                            : Colors.black87,
                  ),
                ),
              ),
              
              // Selection indicator
              if (isSelected)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
