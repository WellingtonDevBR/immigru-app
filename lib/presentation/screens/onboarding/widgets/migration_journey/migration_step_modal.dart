import 'package:flutter/material.dart';
import 'package:immigru/core/di/injection_container.dart' as di;
import 'package:immigru/data/models/country_model.dart';
import 'package:immigru/domain/entities/onboarding_data.dart';
import 'package:immigru/domain/entities/visa.dart';
import 'package:immigru/domain/repositories/visa_repository.dart';
import 'package:immigru/presentation/widgets/country_selector.dart';
import 'package:intl/intl.dart';

/// A modal dialog for adding or editing a migration step
class MigrationStepModal extends StatefulWidget {
  final List<CountryModel> countries;
  final List<Visa> visas;
  final MigrationStep? initialStep;
  final Function(MigrationStep) onSave;
  final bool isEditing;

  const MigrationStepModal({
    super.key,
    required this.countries,
    required this.visas,
    this.initialStep,
    required this.onSave,
    this.isEditing = false,
  });

  /// Show the migration step modal
  static Future<void> show({
    required BuildContext context,
    required List<CountryModel> countries,
    required List<Visa> visas,
    MigrationStep? initialStep,
    required Function(MigrationStep) onSave,
    bool isEditing = false,
  }) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MigrationStepModal(
        countries: countries,
        visas: visas,
        initialStep: initialStep,
        onSave: onSave,
        isEditing: isEditing,
      ),
    );
  }

  @override
  State<MigrationStepModal> createState() => _MigrationStepModalState();
}

class _MigrationStepModalState extends State<MigrationStepModal> {
  // Repository
  final VisaRepository _visaRepository = di.sl<VisaRepository>();

  // Form controllers
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _customVisaController = TextEditingController();
  final TextEditingController _visaSearchController = TextEditingController();

  // Class properties
  final _formKey = GlobalKey<FormState>();

  // Selected values
  CountryModel? _selectedCountry;
  Visa? _selectedVisa;
  DateTime? _arrivedDate;
  DateTime? _leftDate;

  // Form flags
  bool _isCurrentLocation = false;
  bool _isTargetDestination = false;
  bool _useCustomVisa = false;
  bool _wasSuccessful = true;
  bool _isLoadingVisas = false;

  // Dropdown visibility flags
  MigrationReason _selectedReason = MigrationReason.work;

  // Search functionality
  String _visaSearchQuery = '';
  bool _isSearchingVisa = false;

  // Filtered visas based on selected country
  List<Visa> _filteredVisas = [];

  @override
  void initState() {
    super.initState();

    if (widget.initialStep != null) {
      _initializeWithExistingStep(widget.initialStep!);
    }
  }

  void _initializeWithExistingStep(MigrationStep step) {
    _selectedCountry = widget.countries.firstWhere(
      (country) => country.id == step.countryId,
      orElse: () => widget.countries.first,
    );

    if (step.visaId != null) {
      // Try to find the visa in the provided list
      _selectedVisa = widget.visas.cast<Visa?>().firstWhere(
            (visa) => visa?.id == step.visaId,
            orElse: () => null,
          );

      // If visa not found and we have a name, create a fallback visa
      if (_selectedVisa == null && step.visaName.isNotEmpty) {
        // Only proceed if the visa name is not empty
        if (step.visaName.isNotEmpty) {
          // Create a fallback visa with the available information
          _selectedVisa = Visa(
            id: 9999, // Use a default ID since we know it's not found
            countryId: step.countryId,
            visaName: step.visaName,
            visaCode: 'CUSTOM',
            type: 'Other',
            description: 'Custom visa type',
          );
        }
      }
    } else if (step.visaName.isNotEmpty) {
      // If there's a visa name but no visa ID, treat it as a custom visa
      _useCustomVisa = true;
      _customVisaController.text = step.visaName;
    }

    _arrivedDate = step.arrivedDate;
    _leftDate = step.leftDate;
    _isCurrentLocation = step.isCurrentLocation;
    _isTargetDestination = step.isTargetDestination;
    _selectedReason = step.migrationReason ?? MigrationReason.work;
    _wasSuccessful = step.wasSuccessful;

    if (step.arrivedDate != null) {
      _yearController.text = DateFormat('yyyy').format(step.arrivedDate!);
    }

    _notesController.text = step.notes ?? '';

    _filterVisas();
  }

  Future<void> _filterVisas() async {
    if (_selectedCountry != null) {
      try {
        // Show loading indicator
        setState(() {
          _isLoadingVisas = true;
          _filteredVisas = [];
        });

        // Fetch visas for the selected country using the repository
        final countryVisas =
            await _visaRepository.getVisasForCountry(_selectedCountry!.id);

        setState(() {
          _filteredVisas = countryVisas;
          _isLoadingVisas = false;

          // Clear selected visa if it doesn't belong to the selected country
          if (_selectedVisa != null &&
              _selectedVisa!.countryId != _selectedCountry!.id) {
            _selectedVisa = null;
          }

          // If no visas are available for the selected country, use fallback options
          if (_filteredVisas.isEmpty) {
            _filteredVisas =
                _visaRepository.getFallbackVisaOptions(_selectedCountry!.id);

            // Show a message to the user
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Using general visa types for this country'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        });
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoadingVisas = false;
            // Use fallback visa options when API fails
            _filteredVisas =
                _visaRepository.getFallbackVisaOptions(_selectedCountry!.id);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load visas: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } else {
      setState(() {
        _filteredVisas = [];
        _selectedVisa = null;
      });
    }
  }

  @override
  void dispose() {
    _yearController.dispose();
    _notesController.dispose();
    _visaSearchController.dispose();
    _customVisaController.dispose();
    super.dispose();
  }

  void _saveStep() {
    // Make country selection mandatory
    if (_selectedCountry == null) {
      _showValidationError('Please select a country');
      return;
    }

    // Make arrival date mandatory
    if (_arrivedDate == null) {
      _showValidationError('Please select an arrival date');
      return;
    }

    // Validate arrival date is not in the future
    if (_arrivedDate!.isAfter(DateTime.now())) {
      _showValidationError('Arrival date cannot be in the future');
      return;
    }

    // Validate departure date is after arrival date (only if provided)
    if (_leftDate != null && _leftDate!.isBefore(_arrivedDate!)) {
      _showValidationError('Departure date must be after arrival date');
      return;
    }

    // Make visa selection mandatory
    if (!_useCustomVisa && _selectedVisa == null) {
      _showValidationError('Please select a visa type');
      return;
    }

    // Validate custom visa name if using custom visa
    if (_useCustomVisa && _customVisaController.text.trim().isEmpty) {
      _showValidationError('Please enter a visa name');
      return;
    }

    // Log detailed information about the form state

    if (_formKey.currentState!.validate()) {
      // Log visa information before creating the step

      if (_useCustomVisa) {
      } else if (_selectedVisa != null) {
      } else {}

      // Create the migration step
      final int? visaId = _useCustomVisa ? null : _selectedVisa?.id;
      final String visaName = _useCustomVisa
          ? _customVisaController.text.trim()
          : _selectedVisa?.visaName ?? '';

      final MigrationStep step = MigrationStep(
        id: widget.initialStep?.id,
        order: widget.initialStep?.order,
        countryId: _selectedCountry!.id,
        countryName: _selectedCountry!.name,
        visaId: visaId,
        visaName: visaName,
        arrivedDate: _arrivedDate,
        leftDate: _isCurrentLocation ? null : _leftDate,
        isCurrentLocation: _isCurrentLocation,
        isTargetDestination: _isTargetDestination,
        notes: _notesController.text.trim().isNotEmpty
            ? _sanitizeNotes(_notesController.text.trim())
            : null,
        migrationReason: _selectedReason,
        wasSuccessful: _wasSuccessful,
      );
      widget.onSave(step); // ✅ Save it before closing
      Navigator.of(context).pop();
    }
  }

  void _showValidationError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline,
                color: Theme.of(context).colorScheme.error),
            const SizedBox(width: 8),
            const Text('Validation Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Sanitize notes to prevent XSS attacks and other security issues
  String _sanitizeNotes(String input) {
    // Log original input for debugging

    // Remove potentially dangerous HTML/script tags
    String sanitized = input
        .replaceAll(
            RegExp(r'<script[^>]*>.*?</script>',
                caseSensitive: false, dotAll: true),
            '')
        .replaceAll(RegExp(r'<[^>]*>'), '') // Remove any HTML tags
        .replaceAll(RegExp(r'javascript:', caseSensitive: false), '')
        .replaceAll(RegExp(r'on\w+\s*=', caseSensitive: false), '')
        .replaceAll(RegExp(r'\\x[0-9a-fA-F]{2}'), '') // Remove hex escapes
        .replaceAll(RegExp(r'\\u[0-9a-fA-F]{4}'), ''); // Remove unicode escapes

    // Limit the length of notes to prevent excessive data
    if (sanitized.length > 500) {
      sanitized = sanitized.substring(0, 500);
    }

    return sanitized;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return SizedBox(
      height: mediaQuery.size.height * 0.9,
      child: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Modal header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.isEditing
                            ? 'Edit Travel History'
                            : 'Add Travel History',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add countries that are part of your story',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Form content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Country selection
                      _buildCountrySection(),
                      const SizedBox(height: 24),

                      // Visa selection
                      _buildVisaSection(),
                      const SizedBox(height: 24),

                      // Year field
                      _buildYearField(),
                      const SizedBox(height: 24),

                      // Migration reason
                      _buildMigrationReasonSection(),
                      const SizedBox(height: 24),

                      // Additional options
                      _buildAdditionalOptions(),
                      const SizedBox(height: 24),

                      // Notes field
                      _buildNotesField(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),

            // Action buttons
            Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: 20 + mediaQuery.padding.bottom,
                top: 12,
              ),
              decoration: BoxDecoration(
                color: theme.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: theme.primaryColor),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountrySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Country',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),

        // Custom compact implementation for the migration step modal
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _selectedCountry != null
              ? ListTile(
                  title: Text(_selectedCountry!.name),
                  subtitle: Text(_selectedCountry!.nationality),
                  leading: const Icon(Icons.flag),
                  trailing: const Icon(Icons.arrow_drop_down),
                  onTap: () => _showCountrySelectionDialog(context),
                )
              : ListTile(
                  title: const Text('Select a country'),
                  trailing: const Icon(Icons.arrow_drop_down),
                  onTap: () => _showCountrySelectionDialog(context),
                ),
        ),
      ],
    );
  }

  // Show a dialog with the CountrySelector
  void _showCountrySelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Country',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: CountrySelector(
                  countries: widget.countries,
                  selectedCountry: _selectedCountry,
                  onCountrySelected: (country) {
                    setState(() {
                      _selectedCountry = country as CountryModel;
                      // Reset visa selection when country changes
                      _selectedVisa = null;
                      // Filter visas for the selected country
                      _filterVisas();
                    });
                    Navigator.of(context).pop(); // Close dialog after selection
                  },
                  isCompact: true,
                  searchHint: 'Search for a country',
                  showPopularCountries: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVisaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Visa Type',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),

        // Custom visa checkbox
        Row(
          children: [
            Checkbox(
              value: _useCustomVisa,
              onChanged: (value) {
                setState(() {
                  _useCustomVisa = value ?? false;
                  if (_useCustomVisa) {
                    _selectedVisa = null;
                  } else {
                    _customVisaController.clear();
                  }
                });
              },
            ),
            const Text('Use custom visa name'),
          ],
        ),

        // Custom visa field or visa dropdown
        if (_useCustomVisa)
          TextField(
            controller: _customVisaController,
            decoration: InputDecoration(
              hintText: 'Enter visa name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          )
        else if (_selectedCountry != null)
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              title: Text(_selectedVisa?.visaName ?? 'Select a visa'),
              subtitle: _selectedVisa?.type != null
                  ? Text(_selectedVisa!.type)
                  : null,
              trailing: const Icon(Icons.arrow_drop_down),
              onTap: () => _showVisaSelectionDialog(context),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade100,
            ),
            child: const Text(
              'Please select a country first',
              style: TextStyle(color: Colors.grey),
            ),
          ),
      ],
    );
  }

  // Show a dialog with visa selection options
  void _showVisaSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          width: MediaQuery.of(context).size.width * 0.9,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select Visa Type',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Search field
                TextField(
                  controller: _visaSearchController,
                  decoration: InputDecoration(
                    hintText: 'Search visas...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _visaSearchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _visaSearchController.clear();
                                _visaSearchQuery = '';
                                _isSearchingVisa = false;
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _visaSearchQuery = value.toLowerCase();
                      _isSearchingVisa = value.isNotEmpty;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Visa list
                Expanded(
                  child: _isLoadingVisas
                      ? const Center(child: CircularProgressIndicator())
                      : _filteredVisas.isEmpty
                          ? const Center(
                              child:
                                  Text('No visas available for this country'))
                          : ListView.builder(
                              itemCount: _filteredVisas.where((visa) {
                                return _isSearchingVisa
                                    ? visa.visaName
                                        .toLowerCase()
                                        .contains(_visaSearchQuery)
                                    : true;
                              }).length,
                              itemBuilder: (context, index) {
                                final filteredVisaList =
                                    _filteredVisas.where((visa) {
                                  return _isSearchingVisa
                                      ? visa.visaName
                                          .toLowerCase()
                                          .contains(_visaSearchQuery)
                                      : true;
                                }).toList();

                                final visa = filteredVisaList[index];
                                final isSelected = _selectedVisa?.id == visa.id;

                                return ListTile(
                                  title: Text(visa.visaName),
                                  subtitle: Text(visa.type),
                                  selected: isSelected,
                                  tileColor: isSelected
                                      ? Theme.of(context)
                                          .primaryColor
                                          .withValues(alpha: 0.1)
                                      : null,
                                  onTap: () {
                                    setState(() {
                                      _selectedVisa = visa;
                                    });
                                    Navigator.of(context)
                                        .pop(); // Close dialog after selection
                                  },
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildYearField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Arrival Date Field
        const Text(
          'Date of Migration (Arrival)',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showMonthYearPicker(context, isArrival: true),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _arrivedDate != null
                        ? DateFormat('MMMM yyyy').format(_arrivedDate!)
                        : 'Select arrival date',
                    style: TextStyle(
                      color: _arrivedDate != null
                          ? Colors.black87
                          : Colors.black54,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ),

        // Only show departure date field if not current location
        if (!_isCurrentLocation) ...[
          const SizedBox(height: 16),
          const Text(
            'Date of Departure (Optional)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _showMonthYearPicker(context, isArrival: false),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _leftDate != null
                          ? DateFormat('MMMM yyyy').format(_leftDate!)
                          : 'Select departure date (optional)',
                      style: TextStyle(
                        color:
                            _leftDate != null ? Colors.black87 : Colors.black54,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _showMonthYearPicker(BuildContext context,
      {bool isArrival = true}) async {
    final initialDate = isArrival
        ? (_arrivedDate ?? DateTime.now())
        : (_leftDate ?? DateTime.now());
    final firstDate = DateTime(1950);
    final lastDate = DateTime.now();

    // If this is for departure date, ensure the first date is after arrival date
    final effectiveFirstDate = !isArrival && _arrivedDate != null
        ? (_arrivedDate!.isAfter(firstDate) ? _arrivedDate! : firstDate)
        : firstDate;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: effectiveFirstDate,
      lastDate: lastDate,
      initialDatePickerMode: DatePickerMode.year,
    );

    if (pickedDate != null) {
      setState(() {
        if (isArrival) {
          _arrivedDate = pickedDate;
          // If departure date exists and is before the new arrival date, clear it
          if (_leftDate != null && _leftDate!.isBefore(pickedDate)) {
            _leftDate = null;
          }
        } else {
          _leftDate = pickedDate;
        }
      });
    }
  }

  Widget _buildMigrationReasonSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reason for Migration',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<MigrationReason>(
              value: _selectedReason,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down),
              items: MigrationReason.values.map((reason) {
                return DropdownMenuItem<MigrationReason>(
                  value: reason,
                  child: Text(_getMigrationReasonText(reason)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedReason = value;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  String _getMigrationReasonText(MigrationReason reason) {
    switch (reason) {
      case MigrationReason.work:
        return 'Work';
      case MigrationReason.study:
        return 'Study';
      case MigrationReason.family:
        return 'Family';
      case MigrationReason.refugee:
        return 'Refugee/Safety';
      case MigrationReason.lifestyle:
        return 'Lifestyle';
      case MigrationReason.retirement:
        return 'Retirement';
      case MigrationReason.investment:
        return 'Investment';
      case MigrationReason.other:
        return 'Other';
    }
  }

  Widget _buildAdditionalOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Additional Information',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),

        // Current location checkbox
        CheckboxListTile(
          title: const Text('This is my current location'),
          value: _isCurrentLocation,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: (value) {
            setState(() {
              _isCurrentLocation = value ?? false;
            });
          },
        ),

        // Target destination checkbox
        CheckboxListTile(
          title: const Text('This is my target destination'),
          value: _isTargetDestination,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: (value) {
            setState(() {
              _isTargetDestination = value ?? false;
            });
          },
        ),

        // Was successful checkbox
        CheckboxListTile(
          title: const Text('This migration was successful'),
          value: _wasSuccessful,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: (value) {
            setState(() {
              _wasSuccessful = value ?? true;
            });
          },
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notes (Optional)',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          decoration: InputDecoration(
            hintText: 'Add any additional notes about this migration step',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          maxLines: 3,
        ),
      ],
    );
  }
}
