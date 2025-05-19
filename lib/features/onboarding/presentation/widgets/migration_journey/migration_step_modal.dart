import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:immigru/features/onboarding/domain/entities/migration_step.dart';
import 'package:immigru/features/onboarding/presentation/widgets/country_selector.dart';
import 'package:immigru/features/onboarding/presentation/widgets/visa_selector.dart';
import 'package:immigru/new_core/country/domain/entities/country.dart';
import 'package:immigru/presentation/theme/app_colors.dart';
import 'package:immigru/domain/entities/visa.dart';

/// Modal for adding or editing a migration step
class MigrationStepModal {
  /// Show the modal
  static Future<void> show({
    required BuildContext context,
    MigrationStep? step,
    bool isEditing = false,
    required Function(MigrationStep) onSave,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MigrationStepModalContent(
        step: step,
        isEditing: isEditing,
        onSave: onSave,
      ),
    );
  }
}

class _MigrationStepModalContent extends StatefulWidget {
  final MigrationStep? step;
  final bool isEditing;
  final Function(MigrationStep) onSave;

  const _MigrationStepModalContent({
    this.step,
    required this.isEditing,
    required this.onSave,
  });

  @override
  State<_MigrationStepModalContent> createState() => _MigrationStepModalContentState();
}

class _MigrationStepModalContentState extends State<_MigrationStepModalContent> {
  // Form key
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  
  // Selected values
  Country? _selectedCountry;
  Visa? _selectedVisa;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isCurrentLocation = false;
  bool _isTargetCountry = false;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize values if editing
    if (widget.isEditing && widget.step != null) {
      _initializeValues();
    }
  }
  
  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }
  
  /// Initialize values from the step
  void _initializeValues() {
    final step = widget.step!;
    
    // Set dates
    _startDate = step.startDate;
    _endDate = step.endDate;
    
    if (_startDate != null) {
      _startDateController.text = DateFormat('MMM yyyy').format(_startDate!);
    }
    
    if (_endDate != null) {
      _endDateController.text = DateFormat('MMM yyyy').format(_endDate!);
    }
    
    // Set flags
    _isCurrentLocation = step.isCurrentLocation;
    _isTargetCountry = step.isTargetCountry;
    
    // Log the step data for debugging
    print('Editing step with ID: ${step.id}');
    print('Country ID: ${step.countryId}, Country Name: ${step.countryName}, Code: ${step.countryCode}');
    print('Visa ID: ${step.visaTypeId}, Visa Name: ${step.visaTypeName}');
  }
  

  

  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
    
    return Container(
      padding: EdgeInsets.only(
        bottom: mediaQuery.viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.isEditing ? 'Edit Country' : 'Add Country',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close,
                        color: isDarkMode ? Colors.white70 : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Country selector
                _buildCountrySelector(theme, isDarkMode),
                const SizedBox(height: 16),
                
                // Visa type selector
                _buildVisaTypeSelector(theme, isDarkMode),
                const SizedBox(height: 16),
                
                // Date range
                Row(
                  children: [
                    Expanded(
                      child: _buildDateField(
                        label: 'From',
                        controller: _startDateController,
                        onTap: () => _selectDate(context, isStartDate: true),
                        theme: theme,
                        isDarkMode: isDarkMode,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDateField(
                        label: 'To',
                        controller: _endDateController,
                        onTap: () => _selectDate(context, isStartDate: false),
                        theme: theme,
                        isDarkMode: isDarkMode,
                        enabled: !_isCurrentLocation,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Current location checkbox
                _buildCurrentLocationCheckbox(theme, isDarkMode),
                const SizedBox(height: 24),
                
                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(widget.isEditing ? 'Update' : 'Add'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  /// Build the country selector
  Widget _buildCountrySelector(ThemeData theme, bool isDarkMode) {
    // Debug log for country selection
    if (widget.isEditing && widget.step != null) {
      print('COUNTRY SELECTOR DEBUG:');
      print('Editing step with country code: ${widget.step!.countryCode}');
      print('Country name from step: ${widget.step!.countryName}');
      print('Country ID from step: ${widget.step!.countryId}');
      
      // CRITICAL: For countries with missing codes, set a default code based on the country name
      String countryCode = widget.step!.countryCode;
      if (countryCode.isEmpty) {
        final countryName = widget.step!.countryName.toLowerCase();
        if (countryName == 'australia') {
          countryCode = 'AU';
        } else if (countryName == 'japan') {
          countryCode = 'JP';
        } else if (countryName == 'united states') {
          countryCode = 'US';
        } else if (countryName == 'canada') {
          countryCode = 'CA';
        } else if (countryName == 'united kingdom') {
          countryCode = 'GB';
        } else if (countryName == 'brazil') {
          countryCode = 'BR';
        }
        print('Country code was empty, using derived code: $countryCode for $countryName');
      }
      
      return CountrySelector(
        // Pass the derived country code to the selector when editing
        selectedCountryCode: countryCode.isNotEmpty ? countryCode : null,
        onCountrySelected: (country) {
          print('Country selected: ${country.name} (${country.isoCode})');
          setState(() {
            _selectedCountry = country;
          });
        },
      );
    }
    
    // For new steps, just show the regular selector
    return CountrySelector(
      onCountrySelected: (country) {
        print('Country selected: ${country.name} (${country.isoCode})');
        setState(() {
          _selectedCountry = country;
        });
      },
    );
  }
  
  /// Build the visa type selector
  Widget _buildVisaTypeSelector(ThemeData theme, bool isDarkMode) {
    // Debug log for visa selection
    if (widget.isEditing && widget.step != null) {
      print('VISA SELECTOR DEBUG:');
      print('Editing step with visa ID: ${widget.step!.visaTypeId}');
      print('Visa name from step: ${widget.step!.visaTypeName}');
      
      // CRITICAL: For Australia, we know the visa IDs
      // This is a special case to handle Australia's Student Visa
      if (widget.step!.countryName.toLowerCase() == 'australia' && 
          widget.step!.visaTypeName.toLowerCase() == 'student visa') {
        print('Special case: Australia Student Visa detected');
        
        // For Australia, Student Visa has ID 102
        int visaId = 102;
        
        return VisaSelector(
          countryId: widget.step!.countryId,
          selectedVisaId: visaId,
          onVisaSelected: (visa) {
            print('Visa selected: ${visa.visaName} (ID: ${visa.id})');
            setState(() {
              _selectedVisa = visa;
            });
          },
        );
      }
    }
    
    // Only show visa selector if a country is selected
    if (_selectedCountry == null) {
      // If we're editing, try to use the country ID from the step
      if (widget.isEditing && widget.step != null) {
        print('No country selected yet, but we have a step to edit');
        print('Using country ID from step: ${widget.step!.countryId}');
        
        // CRITICAL: For Australia, we know the visa IDs
        int visaId = widget.step!.visaTypeId;
        
        // Special case for Australia's Student Visa
        if (widget.step!.countryName.toLowerCase() == 'australia' && 
            widget.step!.visaTypeName.toLowerCase() == 'student visa') {
          visaId = 102; // Student Visa ID for Australia
        }
        
        return VisaSelector(
          countryId: widget.step!.countryId,
          selectedVisaId: visaId,
          onVisaSelected: (visa) {
            print('Visa selected: ${visa.visaName} (ID: ${visa.id})');
            setState(() {
              _selectedVisa = visa;
            });
          },
        );
      }
      
      // If not editing or no step, show the placeholder
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Visa Type',
            style: theme.textTheme.titleSmall?.copyWith(
              color: isDarkMode ? Colors.white70 : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
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
                'Select a country first',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDarkMode ? Colors.white70 : Colors.grey[700],
                ),
              ),
            ),
          ),
        ],
      );
    }
    
    // CRITICAL: For Australia, we know the visa IDs
    int visaId = widget.isEditing && widget.step != null ? widget.step!.visaTypeId : 0;
    
    // Special case for Australia's Student Visa
    if (widget.isEditing && widget.step != null && 
        widget.step!.countryName.toLowerCase() == 'australia' && 
        widget.step!.visaTypeName.toLowerCase() == 'student visa') {
      visaId = 102; // Student Visa ID for Australia
    }
    
    return VisaSelector(
      countryId: _selectedCountry!.id,
      // Pass the visa ID directly when editing
      selectedVisaId: visaId > 0 ? visaId : null,
      onVisaSelected: (visa) {
        print('Visa selected: ${visa.visaName} (ID: ${visa.id})');
        setState(() {
          _selectedVisa = visa;
        });
      },
    );
  }
  
  // We no longer need this method as we're passing the visa ID directly to the VisaSelector
  
  /// Build a date field
  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
    required Function() onTap,
    required ThemeData theme,
    required bool isDarkMode,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            color: isDarkMode ? Colors.white70 : Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          enabled: enabled,
          onTap: enabled ? onTap : null,
          decoration: InputDecoration(
            hintText: 'Select date',
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
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            suffixIcon: Icon(
              Icons.calendar_today,
              color: enabled
                  ? (isDarkMode ? Colors.white70 : Colors.grey[700])
                  : (isDarkMode ? Colors.grey[700] : Colors.grey[400]),
              size: 20,
            ),
          ),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: enabled
                ? (isDarkMode ? Colors.white : Colors.black87)
                : (isDarkMode ? Colors.white70 : Colors.grey[600]),
          ),
          validator: (value) {
            if (label == 'From' && value!.isEmpty) {
              return 'Please select a start date';
            }
            return null;
          },
        ),
      ],
    );
  }
  
  /// Build the target country checkbox
  Widget _buildCurrentLocationCheckbox(ThemeData theme, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Target country checkbox only - we'll automatically determine current location
        // based on the most recent date
        Row(
          children: [
            Checkbox(
              value: _isTargetCountry,
              onChanged: (value) {
                setState(() {
                  _isTargetCountry = value ?? false;
                  
                  if (_isTargetCountry) {
                    // Target countries are always in the future and can't be current location
                    _isCurrentLocation = false;
                    
                    // For target countries, ensure the start date is in the future
                    final now = DateTime.now();
                    if (_startDate == null || _startDate!.isBefore(now)) {
                      // Default to 1 month in the future
                      _startDate = DateTime(now.year, now.month + 1, 1);
                      _startDateController.text = DateFormat('MMM yyyy').format(_startDate!);
                    }
                    
                    // Target countries don't have an end date
                    _endDate = null;
                    _endDateController.clear();
                    
                    print('Set as target country: $_isTargetCountry');
                  }
                });
              },
              activeColor: AppColors.primaryColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'This is my target destination',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
        ),
        
        // Add explanation text for target country
        if (_isTargetCountry)
          Padding(
            padding: const EdgeInsets.only(left: 40, top: 4),
            child: Text(
              'Target countries can only have future arrival dates',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDarkMode ? Colors.white70 : Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
  
  /// Select a date
  Future<void> _selectDate(BuildContext context, {required bool isStartDate}) async {
    final now = DateTime.now();
    DateTime initialDate;
    DateTime firstDate;
    DateTime lastDate;
    
    if (_isTargetCountry) {
      // For target countries, only allow future dates
      // Set initial date to 1 month in the future if not already set or if it's in the past
      if (isStartDate) {
        initialDate = _startDate != null && _startDate!.isAfter(now)
            ? _startDate!
            : DateTime(now.year, now.month + 1, 1);
        
        // For target countries, first date should be tomorrow
        firstDate = DateTime(now.year, now.month, now.day + 1);
        // Allow dates up to year 2100 for target countries
        lastDate = DateTime(2100);  
      } else {
        // End date for target countries shouldn't be selectable
        return;
      }
    } else {
      // For regular countries (past or current)
      initialDate = isStartDate
          ? (_startDate ?? now)
          : (_endDate ?? now);
      
      // Allow dates from 1900 up to today for past/current countries
      firstDate = DateTime(1900);
      lastDate = now;
    }
    
    // Log date selection parameters
    print('Selecting date: isStartDate=$isStartDate, isTargetCountry=$_isTargetCountry');
    print('initialDate=$initialDate, firstDate=$firstDate, lastDate=$lastDate');
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          _startDateController.text = DateFormat('MMM yyyy').format(picked);
        } else {
          _endDate = picked;
          _endDateController.text = DateFormat('MMM yyyy').format(picked);
        }
      });
    }
  }
  
  /// Save the step
  void _saveStep() {
    if (_formKey.currentState!.validate() && 
        _selectedCountry != null && 
        _selectedVisa != null) {
      
      // Provide haptic feedback
      HapticFeedback.mediumImpact();
      
      // Generate a unique ID for new steps
      final stepId = widget.step?.id ?? 'step_${DateTime.now().millisecondsSinceEpoch}';
      
      // Ensure date fields are properly set based on current/target status
      DateTime? finalStartDate = _startDate;
      DateTime? finalEndDate = _endDate;
      bool isCurrent = false;
      
      // Handle target country logic
      if (_isTargetCountry) {
        // Target countries are always in the future
        final now = DateTime.now();
        if (finalStartDate == null || finalStartDate.isBefore(now)) {
          // Default to 1 month in the future
          finalStartDate = DateTime(now.year, now.month + 1, 1);
        }
        
        // Target countries don't have an end date
        finalEndDate = null;
        
        // Target countries are never current
        isCurrent = false;
      } else {
        // For regular countries, determine if it's current based on dates
        // If there's no end date, it's a current location
        if (finalEndDate == null) {
          isCurrent = true;
        } else {
          // If end date is in the future, it's current
          isCurrent = finalEndDate.isAfter(DateTime.now());
        }
        
        // If it's marked as current but has an end date in the past, fix it
        if (isCurrent && finalEndDate != null && finalEndDate.isBefore(DateTime.now())) {
          finalEndDate = null;
        }
      }
      
      // Log the data being saved
      print('Saving step with ID: $stepId');
      print('Country: ${_selectedCountry!.name} (${_selectedCountry!.isoCode})');
      print('Visa: ${_selectedVisa!.visaName}');
      print('Dates: ${finalStartDate?.toString()} to ${finalEndDate?.toString()}');
      print('Current location: $isCurrent, Target country: $_isTargetCountry');
      
      // Create the step with all the required data
      final step = MigrationStep(
        id: stepId,
        countryId: _selectedCountry!.id,
        countryCode: _selectedCountry!.isoCode,
        countryName: _selectedCountry!.name,
        visaTypeId: _selectedVisa!.id,
        visaTypeName: _selectedVisa!.visaName,
        startDate: finalStartDate,
        endDate: finalEndDate,
        isCurrentLocation: isCurrent,
        isTargetCountry: _isTargetCountry,
        // For new steps, assign a higher order than existing steps
        order: widget.step?.order ?? (widget.isEditing ? 0 : 99),
      );
      
      // Log the final step object
      print('Final step object: $step');
      
      // Save the step
      widget.onSave(step);
      
      // Close the modal
      Navigator.of(context).pop();
    } else {
      // Show validation errors
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
