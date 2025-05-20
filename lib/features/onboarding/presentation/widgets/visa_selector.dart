import 'package:flutter/material.dart';
import 'package:immigru/features/onboarding/domain/repositories/visa_repository.dart';
import 'package:immigru/features/onboarding/domain/entities/visa.dart';
import 'package:immigru/new_core/di/service_locator.dart';
import 'package:immigru/shared/theme/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:immigru/new_core/logging/log_util.dart';

/// A dropdown widget for selecting a visa type
class VisaSelector extends StatefulWidget {
  /// Country ID to load visas for
  final int countryId;

  /// Currently selected visa
  final Visa? selectedVisa;

  /// ID of the visa to select (alternative to selectedVisa)
  final int? selectedVisaId;

  /// Callback when a visa is selected
  final Function(Visa) onVisaSelected;

  /// Label for the dropdown
  final String label;

  /// Hint text when no visa is selected
  final String hint;

  /// Whether the field is required
  final bool isRequired;

  /// Constructor
  const VisaSelector({
    super.key,
    required this.countryId,
    this.selectedVisa,
    this.selectedVisaId,
    required this.onVisaSelected,
    this.label = 'Visa Type',
    this.hint = 'Select a visa type',
    this.isRequired = true,
  });

  @override
  State<VisaSelector> createState() => _VisaSelectorState();
}

class _VisaSelectorState extends State<VisaSelector> {
  // Visas data
  List<Visa> _visas = [];
  List<Visa> _filteredVisas = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Selected visa
  Visa? _selectedVisa;
  bool _showSelector = false;

  // Search controller
  late TextEditingController _searchController;

  // Repository
  late VisaRepository _visaRepository;

  @override
  void initState() {
    super.initState();
    _selectedVisa = widget.selectedVisa;
    _showSelector =
        _selectedVisa == null; // Show selector if no visa is selected
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);

    try {
      // Try to get VisaRepository from the new architecture
      _visaRepository = ServiceLocator.instance<VisaRepository>();
    } catch (e) {
      // Try to get from the old architecture with fallback
      try {
        _visaRepository = ServiceLocator.instance<VisaRepository>(
          instanceName: 'domain_visa_repository',
        );
      } catch (e) {
        _isLoading = false;
        _errorMessage = 'Repository not available';
        return;
      }
    }

    // Schedule the loading for after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVisas();
    });
  }

  void _onSearchChanged() {
    _filterVisas(_searchController.text);
  }

  /// Find a visa by its ID and select it
  void _findAndSelectVisaById(int visaId) {
    if (_visas.isEmpty) {
      // We'll retry when visas are loaded
      return;
    }

    try {
      // Check if we can find the visa with the matching ID
      final matchingVisas = _visas.where((v) => v.id == visaId).toList();

      if (matchingVisas.isNotEmpty) {
        final visa = matchingVisas.first;

        // Use Future.microtask to avoid setState during build
        Future.microtask(() {
          if (mounted) {
            setState(() {
              _selectedVisa = visa;
              _showSelector = false;
            });

            // Notify the parent widget
            widget.onVisaSelected(visa);
          }
        });
      } else {
        // If we can't find the visa by ID, log the issue using LogUtil
        LogUtil.w(
            'Could not find visa with ID $visaId in available visas. Available visa IDs: ${_visas.map((v) => v.id).join(', ')}',
            tag: 'VisaSelector');

        // Check if we have any visas
        if (_visas.isNotEmpty) {
          // Use the first visa as a fallback
          final visa = _visas.first;

          // Use Future.microtask to avoid setState during build
          Future.microtask(() {
            if (mounted) {
              setState(() {
                _selectedVisa = visa;
                _showSelector = true; // Show selector so user can choose
              });

              // Notify the parent widget
              widget.onVisaSelected(visa);
            }
          });
        }
      }
    } catch (e) {
      // Silently ignore errors when finding visa by ID, fallback handled above
    }
  }

  void _filterVisas(String query) {
    final searchQuery = query.toLowerCase().trim();

    if (searchQuery.isEmpty) {
      setState(() {
        _filteredVisas = _visas;
      });
    } else {
      setState(() {
        _filteredVisas = _visas
            .where((visa) =>
                visa.visaName.toLowerCase().contains(searchQuery) ||
                (visa.description?.toLowerCase() ?? '').contains(searchQuery))
            .toList();
      });
    }
  }

  @override
  void didUpdateWidget(VisaSelector oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If the country ID changed, reload visas
    if (oldWidget.countryId != widget.countryId) {
      _loadVisas();
    }

    // If the selected visa changed, update the state
    if (oldWidget.selectedVisa != widget.selectedVisa) {
      setState(() {
        _selectedVisa = widget.selectedVisa;
      });
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  /// Load visas for the selected country
  Future<void> _loadVisas() async {
    // Reset state
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _visas = [];
    });

    try {
      // Special handling for Australia (country ID 14)
      List<Visa> visas;
      if (widget.countryId == 14) {
        // Australia
        // Hardcoded visas for Australia with all required parameters
        visas = [
          Visa(
            id: 101,
            name: 'Skilled Independent Visa',
            countryId: 14,
            visaCode: 'Subclass 189',
            type: 'Permanent',
            description:
                'For skilled workers who are not sponsored by an employer.',
            pathwayToPR: true,
            allowsWork: true,
          ),
          Visa(
            id: 102,
            name: 'Skilled Nominated Visa',
            countryId: 14,
            visaCode: 'Subclass 190',
            type: 'Permanent',
            description:
                'For skilled workers who are nominated by a state or territory government.',
            pathwayToPR: true,
            allowsWork: true,
          ),
          Visa(
            id: 103,
            name: 'Student Visa',
            countryId: 14,
            visaCode: 'Subclass 500',
            type: 'Temporary',
            description: 'For international students to study in Australia.',
            pathwayToPR: false,
            allowsWork: true,
          ),
          Visa(
            id: 104,
            name: 'Working Holiday Visa',
            countryId: 14,
            visaCode: 'Subclass 417',
            type: 'Temporary',
            description:
                'For young adults who want to work and travel in Australia.',
            pathwayToPR: false,
            allowsWork: true,
          ),
          Visa(
            id: 105,
            name: 'Business Innovation and Investment Visa',
            countryId: 14,
            visaCode: 'Subclass 188',
            type: 'Temporary',
            description: 'For business owners, investors, and entrepreneurs.',
            pathwayToPR: true,
            allowsWork: true,
          ),
          Visa(
            id: 106,
            name: 'Partner Visa',
            countryId: 14,
            visaCode: 'Subclass 820/801',
            type: 'Temporary & Permanent',
            description:
                'For partners of Australian citizens or permanent residents.',
            pathwayToPR: true,
            allowsWork: true,
          ),
          Visa(
            id: 107,
            name: 'Work Visa',
            countryId: 14,
            visaCode: 'General',
            type: 'Temporary',
            description: 'General work visa for employment purposes.',
            pathwayToPR: false,
            allowsWork: true,
          ),
        ];
      } else {
        // For other countries, use the repository
        visas = await _visaRepository.getVisasForCountry(widget.countryId);
      }

      if (mounted) {
        setState(() {
          _visas = visas;
          _filteredVisas = visas;
          _isLoading = false;

          // Priority 1: Use the selectedVisaId parameter if provided
          if (widget.selectedVisaId != null) {
            _findAndSelectVisaById(widget.selectedVisaId!);
          }
          // Priority 2: Use the selectedVisa parameter if provided
          else if (widget.selectedVisa != null) {
            final stillValid =
                _visas.any((visa) => visa.id == widget.selectedVisa!.id);
            if (stillValid) {
              _selectedVisa = widget.selectedVisa;
              // No need to call onVisaSelected as it was already selected
            } else if (_visas.isNotEmpty) {
              _selectedVisa = _visas.first;
              widget.onVisaSelected(_visas.first);
            }
          }
          // Priority 3: Check if current _selectedVisa is still valid
          else if (_selectedVisa != null) {
            final stillValid =
                _visas.any((visa) => visa.id == _selectedVisa!.id);
            if (!stillValid && _visas.isNotEmpty) {
              _selectedVisa = _visas.first;
              widget.onVisaSelected(_visas.first);
            }
          }
          // Priority 4: Default to first visa if nothing else is selected
          else if (_visas.isNotEmpty) {
            _selectedVisa = _visas.first;
            widget.onVisaSelected(_visas.first);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load visa types';
        });
      }
    }
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
        // Empty state
        else if (_visas.isEmpty)
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
              child: Text(
                'No visa types available',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDarkMode ? Colors.white70 : Colors.grey[700],
                ),
              ),
            ),
          )
        // If visa is selected and not showing selector, just show the selected visa
        else if (_selectedVisa != null && !_showSelector)
          _buildSelectedVisaDisplay(theme, isDarkMode)
        // Otherwise show the visa selector with search
        else
          _buildVisaSelector(theme, isDarkMode),
      ],
    );
  }

  Widget _buildSelectedVisaDisplay(ThemeData theme, bool isDarkMode) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showSelector = !_showSelector;
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
            // Visa icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.card_membership,
                color: AppColors.primaryColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),

            // Visa name and code
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedVisa!.visaName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    _selectedVisa!.description ?? '',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDarkMode ? Colors.white70 : Colors.grey[700],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Edit icon
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

  Widget _buildVisaSelector(ThemeData theme, bool isDarkMode) {
    return Column(
      children: [
        // Search field
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search visa types',
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

        // Visa list
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[850] : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
            ),
          ),
          child: _filteredVisas.isEmpty
              ? Center(
                  child: Text(
                    'No visa types found',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDarkMode ? Colors.white70 : Colors.grey[700],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _filteredVisas.length,
                  itemBuilder: (context, index) {
                    final visa = _filteredVisas[index];
                    return _buildVisaItem(visa, isDarkMode, theme);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildVisaItem(Visa visa, bool isDarkMode, ThemeData theme) {
    final isSelected = _selectedVisa?.id == visa.id;

    return InkWell(
      onTap: () {
        // Provide haptic feedback
        HapticFeedback.selectionClick();

        setState(() {
          _selectedVisa = visa;
          _showSelector = false; // Hide the selector after selection
        });
        widget.onVisaSelected(visa);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // Visa icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryColor.withValues(alpha: 0.2)
                    : isDarkMode
                        ? Colors.grey[800]
                        : Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.card_membership,
                color: isSelected
                    ? AppColors.primaryColor
                    : isDarkMode
                        ? Colors.white70
                        : Colors.grey[700],
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Visa details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    visa.visaName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? AppColors.primaryColor
                          : isDarkMode
                              ? Colors.white
                              : Colors.black87,
                    ),
                  ),
                  Text(
                    visa.description ?? '',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? AppColors.primaryColor.withValues(alpha: 0.8)
                          : isDarkMode
                              ? Colors.white70
                              : Colors.grey[700],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
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
}
