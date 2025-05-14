import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/core/di/injection_container.dart' as di;
import 'package:immigru/data/models/country_model.dart';
import 'package:immigru/domain/entities/onboarding_data.dart';
import 'package:immigru/domain/entities/visa.dart';
import 'package:immigru/domain/repositories/country_repository.dart';
import 'package:immigru/domain/repositories/visa_repository.dart';
import 'package:immigru/presentation/blocs/migration_steps/migration_steps_bloc.dart';
import 'package:immigru/presentation/blocs/migration_steps/migration_steps_event.dart'
    as migration_steps;
import 'package:immigru/presentation/blocs/migration_steps/migration_steps_state.dart';
import 'package:immigru/presentation/blocs/onboarding/onboarding_bloc.dart';
import 'package:immigru/presentation/blocs/onboarding/onboarding_event.dart';
import 'package:immigru/presentation/widgets/loading_indicator.dart';
import 'package:immigru/presentation/screens/onboarding/widgets/migration_journey/migration_timeline.dart';
import 'package:immigru/presentation/screens/onboarding/widgets/migration_journey/migration_step_modal.dart';
import 'package:immigru/presentation/theme/app_colors.dart';

/// Widget for the migration journey step in onboarding
class MigrationJourneyStepWidget extends StatefulWidget {
  final String birthCountry;
  final List<MigrationStep> migrationSteps;
  final Function(MigrationStep) onAddStep;
  final Function(int, MigrationStep) onUpdateStep;
  final Function(int) onRemoveStep;

  const MigrationJourneyStepWidget({
    super.key,
    required this.birthCountry,
    required this.migrationSteps,
    required this.onAddStep,
    required this.onUpdateStep,
    required this.onRemoveStep,
  });

  @override
  State<MigrationJourneyStepWidget> createState() =>
      _MigrationJourneyStepWidgetState();
}

class _MigrationJourneyStepWidgetState
    extends State<MigrationJourneyStepWidget> {
  // Repositories
  final CountryRepository _countryRepository = di.sl<CountryRepository>();
  final VisaRepository _visaRepository = di.sl<VisaRepository>();

  // BLoCs
  late final MigrationStepsBloc _migrationStepsBloc;

  // Data
  List<CountryModel> _countries = [];
  List<Visa> _visas = [];
  String _birthCountryName = '';

  // Loading states
  bool _isLoadingCountries = true;
  bool _isLoadingVisas = true;

  // UI state
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Initialize the migration steps bloc
    _migrationStepsBloc = di.sl<MigrationStepsBloc>();
    _migrationStepsBloc.add(const migration_steps.MigrationStepsLoaded());

    _loadCountries();
    _loadVisas();
    _lookupBirthCountryName();
  }

  /// Lookup the full country name from the ISO code
  Future<void> _lookupBirthCountryName() async {
    try {
      final countries = await _countryRepository.getCountries();
      final country = countries.firstWhere(
        (c) => c.isoCode.toLowerCase() == widget.birthCountry.toLowerCase(),
        orElse: () => CountryModel(
          id: -1,
          name: widget.birthCountry,
          isoCode: widget.birthCountry,
          officialName: widget.birthCountry,
          continent: '',
          region: '',
          subRegion: '',
          nationality: '',
          phoneCode: '',
          currency: '',
          currencySymbol: '',
          timezones: '',
          flagUrl: '',
          isActive: true,
          updatedAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      );

      setState(() {
        _birthCountryName = country.name;
      });
    } catch (e) {
      setState(() {
        _birthCountryName = widget.birthCountry;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCountries() async {
    try {
      final countries = await _countryRepository.getCountries();
      setState(() {
        // Convert Country entities to CountryModel objects
        _countries = countries
            .map((country) => CountryModel(
                  id: country.id,
                  name: country.name,
                  isoCode: country.isoCode,
                  officialName: country.officialName,
                  continent: country.continent,
                  region: country.region,
                  subRegion: country.subRegion,
                  nationality: country.nationality,
                  phoneCode: country.phoneCode,
                  currency: country.currency,
                  currencySymbol: country.currencySymbol,
                  timezones: country.timezones,
                  flagUrl: country.flagUrl,
                  isActive: country.isActive,
                  updatedAt: country.updatedAt,
                  createdAt: country.createdAt,
                ))
            .toList();
        _isLoadingCountries = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCountries = false;
      });
    }
  }

  Future<void> _loadVisas() async {
    try {
      final visas = await _visaRepository.getVisas();
      setState(() {
        _visas = visas;
        _isLoadingVisas = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingVisas = false;
      });
    }
  }

  void _showAddStepModal() {
    MigrationStepModal.show(
      context: context,
      countries: _countries,
      visas: _visas,
      onSave: _addStep,
      isEditing: false,
    );
  }

  /// Build the header section with illustration
  Widget _buildHeaderSection() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.map_outlined,
            color: AppColors.primaryColor,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "I've been to...",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Track your migration journey timeline',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build a modern add step button
  Widget _buildAddStepButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: _showAddStepModal,
        icon: const Icon(Icons.add),
        label: const Text('Add Migration Step'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  void _editStep(int index) {
    MigrationStepModal.show(
      context: context,
      countries: _countries,
      visas: _visas,
      initialStep: widget.migrationSteps[index],
      onSave: (step) => _updateStep(index, step),
      isEditing: true,
    );
  }

  void _addStep(MigrationStep step) {
    try {
      final timestamp = DateTime.now().toIso8601String();

      // Ensure country name is set
      if (step.countryName.isEmpty && step.countryId > 0) {
        // Try to find country name from the countries list
        final country = _countries.firstWhere(
          (c) => c.id == step.countryId,
          orElse: () => CountryModel(
            id: step.countryId,
            name: 'Unknown Country',
            isoCode: '',
            officialName: '',
            continent: '',
            region: '',
            subRegion: '',
            nationality: '',
            phoneCode: '',
            currency: '',
            currencySymbol: '',
            timezones: '',
            flagUrl: '',
            isActive: true,
            updatedAt: DateTime.now(),
            createdAt: DateTime.now(),
          ),
        );

        // Create a new step with the country name
        step = step.copyWith(countryName: country.name);
      }

      // Log the step being added for debugging
      debugPrint(
          '[$timestamp] Adding migration step for country: ${step.countryName} (ID: ${step.countryId})');

      // Add the step to the widget state through the callback
      widget.onAddStep(step);

      // Also add the step to the MigrationStepsBloc
      _migrationStepsBloc.add(migration_steps.MigrationStepAdded(step));
    } catch (e) {
      debugPrint('Error adding step: $e');
    }

    // Wait a short moment before triggering save to ensure UI is updated
    Future.delayed(const Duration(milliseconds: 500), () async {
      // Trigger save after adding a new step
      try {
        debugPrint('Triggering save after adding step');
        await _triggerSaveData();
      } catch (e) {
        debugPrint('Error saving after adding step: $e');
      }
    });

    // Show a snackbar to indicate the step was added
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added migration step for ${step.countryName}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _updateStep(int index, MigrationStep step) {
    final timestamp = DateTime.now().toIso8601String();
    try {
      // Ensure country name is preserved
      if (step.countryName.isEmpty && step.countryId > 0) {
        // Try to find country name from the countries list
        final country = _countries.firstWhere(
          (c) => c.id == step.countryId,
          orElse: () => CountryModel(
            id: step.countryId,
            name: widget.migrationSteps[index].countryName.isNotEmpty
                ? widget.migrationSteps[index].countryName
                : 'Unknown Country',
            isoCode: '',
            officialName: '',
            continent: '',
            region: '',
            subRegion: '',
            nationality: '',
            phoneCode: '',
            currency: '',
            currencySymbol: '',
            timezones: '',
            flagUrl: '',
            isActive: true,
            updatedAt: DateTime.now(),
            createdAt: DateTime.now(),
          ),
        );

        // Create a new step with the country name
        step = step.copyWith(countryName: country.name);
      }

      // Log the step being updated for debugging
      debugPrint(
          '[$timestamp] 🚀 EDIT FLOW: Starting edit operation for step $index');
      debugPrint(
          '[$timestamp] 🔄 Original country: ${widget.migrationSteps[index].countryName}');
      debugPrint('[$timestamp] 🔄 New country: ${step.countryName}');
      debugPrint(
          '[$timestamp] 🔄 Original visa: ${widget.migrationSteps[index].visaName}');
      debugPrint('[$timestamp] 🔄 New visa: ${step.visaName}');
      debugPrint(
          '[$timestamp] 🔄 Original dates: ${widget.migrationSteps[index].arrivedDate} to ${widget.migrationSteps[index].leftDate}');
      debugPrint(
          '[$timestamp] 🔄 New dates: ${step.arrivedDate} to ${step.leftDate}');

      // Force set hasChanges to true in the MigrationStepsBloc
      debugPrint('[$timestamp] 🚀 EDIT FLOW: Setting hasChanges flag to true');
      _migrationStepsBloc.add(migration_steps.MigrationStepsForceChanged());

      // Update the step in the widget state through the callback
      debugPrint('[$timestamp] 🚀 EDIT FLOW: Updating step in widget state');
      widget.onUpdateStep(index, step);

      // Also update the step in the MigrationStepsBloc
      debugPrint(
          '[$timestamp] 🚀 EDIT FLOW: Dispatching MigrationStepUpdated event');
      _migrationStepsBloc
          .add(migration_steps.MigrationStepUpdated(index, step));

      // Force a rebuild of the widget
      debugPrint('[$timestamp] 🚀 EDIT FLOW: Forcing widget rebuild');
      setState(() {});

      // Show a snackbar to indicate the step was updated
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Updated migration step for ${step.countryName}'),
          duration: const Duration(seconds: 2),
        ),
      );

      // Immediately trigger save to ensure data is sent to backend
      debugPrint(
          '[$timestamp] 🚀 EDIT FLOW: Immediately triggering save operation with action="save"');
      _triggerSaveData();
    } catch (e) {
      debugPrint('[$timestamp] ❌ Error updating step: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating step: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Helper method to trigger saving data
  Future<void> _triggerSaveData() async {
    final timestamp = DateTime.now().toIso8601String();
    debugPrint(
        '[$timestamp] 🚀 UI FLOW: _triggerSaveData called with EXPLICIT action="save"');
    await Future.delayed(Duration.zero);
    if (!context.mounted) {
      debugPrint('[$timestamp] ❌ Context not mounted, returning');
      return;
    }

    try {
      debugPrint(
          '[$timestamp] 📊 Current migration steps: ${_migrationStepsBloc.state.steps.length}');
      debugPrint(
          '[$timestamp] 📊 Has changes flag: ${_migrationStepsBloc.state.hasChanges}');

      // Log details of each migration step
      final steps = _migrationStepsBloc.state.steps;
      for (int i = 0; i < steps.length; i++) {
        final step = steps[i];
        debugPrint(
            '[$timestamp] 💾 Step $i: countryId=${step.countryId}, countryName=${step.countryName}');
        debugPrint(
            '[$timestamp] 💾   visaId=${step.visaId}, visaName=${step.visaName}');
        debugPrint(
            '[$timestamp] 💾   isCurrent=${step.isCurrentLocation}, isTarget=${step.isTargetDestination}');
        debugPrint(
            '[$timestamp] 💾   arrivedDate=${step.arrivedDate}, leftDate=${step.leftDate}');
      }

      // Force the hasChanges flag to true to ensure save happens
      debugPrint('[$timestamp] 🔄 Adding MigrationStepsForceChanged event');
      _migrationStepsBloc.add(migration_steps.MigrationStepsForceChanged());

      // First update the onboarding data with the latest migration steps
      final onboardingBloc = BlocProvider.of<OnboardingBloc>(context);
      final updatedOnboardingData = onboardingBloc.state.data.copyWith(
        migrationSteps: _migrationStepsBloc.state.steps,
      );

      // Update the onboarding data
      debugPrint(
          '[$timestamp] 📝 Updating onboarding data with latest migration steps');
      onboardingBloc.add(OnboardingDataChanged(updatedOnboardingData));

      // Wait a moment for the onboarding data to update
      debugPrint('[$timestamp] ⏳ Waiting for onboarding data to update');
      await Future.delayed(const Duration(milliseconds: 100));

      // Now save the migration steps directly
      debugPrint('[$timestamp] 💾 Adding MigrationStepsSaved event');
      _migrationStepsBloc.add(const migration_steps.MigrationStepsSaved());

      // Also trigger the onboarding save to ensure both are saved
      debugPrint('[$timestamp] 💾 Adding OnboardingSaved event');
      onboardingBloc.add(const OnboardingSaved());

      debugPrint('[$timestamp] ✅ Migration steps save process completed');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Migration steps saved successfully',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugPrint('[$timestamp] ❌ Error in _triggerSaveData: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error saving migration steps: $e',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _removeStep(int index) {
    final timestamp = DateTime.now().toIso8601String();
    final stepToRemove = widget.migrationSteps[index];

    // Show a confirmation dialog with more details about the step being removed
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Migration Step'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to remove this migration step?'),
            const SizedBox(height: 16),
            _buildStepInfoRow(
                Icons.location_on, 'Country', stepToRemove.countryName),
            if (stepToRemove.visaName.isNotEmpty)
              _buildStepInfoRow(
                  Icons.verified_user_outlined, 'Visa', stepToRemove.visaName),
            if (stepToRemove.arrivedDate != null)
              _buildStepInfoRow(Icons.calendar_today, 'Arrived',
                  '${stepToRemove.arrivedDate!.month}/${stepToRemove.arrivedDate!.year}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            onPressed: () {
              debugPrint(
                  '[$timestamp] 🗑️ Removing migration step at index $index for ${stepToRemove.countryName}');
              Navigator.of(context).pop();

              // Show a loading indicator
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Removing migration step...'),
                  duration: Duration(seconds: 1),
                ),
              );

              // Remove the step from the widget state through the callback
              widget.onRemoveStep(index);

              // Also remove the step from the MigrationStepsBloc
              debugPrint(
                  '[$timestamp] 🗑️ Dispatching MigrationStepRemoved event for index $index');
              _migrationStepsBloc
                  .add(migration_steps.MigrationStepRemoved(index));

              // Trigger save after removing a step
              Future.delayed(const Duration(milliseconds: 500), () async {
                debugPrint(
                    '[$timestamp] 🗑️ Triggering save after step removal');
                await _triggerSaveData();

                // Show success message
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Removed migration step for ${stepToRemove.countryName}'),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              });
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  /// Helper method to build information rows in the deletion confirmation dialog
  Widget _buildStepInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _migrationStepsBloc,
      child: BlocListener<MigrationStepsBloc, MigrationStepsState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.errorMessage}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        child: BlocBuilder<MigrationStepsBloc, MigrationStepsState>(
          builder: (context, migrationStepsState) {
            if (_isLoadingCountries ||
                _isLoadingVisas ||
                migrationStepsState.isLoading) {
              return const Center(
                child: LoadingIndicator(message: 'Loading migration data...'),
              );
            }

            if (_countries.isEmpty || _visas.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text(
                      'Could not load countries or visas.\nPlease try again.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isLoadingCountries = true;
                          _isLoadingVisas = true;
                        });
                        _loadCountries();
                        _loadVisas();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  
                  // Header section with "I've been to..." text
                  _buildHeaderSection(),

                  const SizedBox(height: 24),

                  // Timeline visualization
                  MigrationTimeline(
                    migrationSteps: widget.migrationSteps,
                    onEditStep: _editStep,
                    onRemoveStep: _removeStep,
                    birthCountry: _birthCountryName,
                  ),

                  const SizedBox(height: 24),

                  // Add step button
                  _buildAddStepButton(),

                  // Conditional widgets (add them here inside the Column)
                  if (widget.migrationSteps.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: Center(
                        child: Text(
                          'Add your migration steps to track your journey',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                    ),

                  if (migrationStepsState.isSaving)
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
