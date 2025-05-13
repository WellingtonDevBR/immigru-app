import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/core/di/injection_container.dart' as di;
import 'package:immigru/data/models/country_model.dart';
import 'package:immigru/domain/entities/onboarding_data.dart';
import 'package:immigru/domain/entities/visa.dart';
import 'package:immigru/domain/repositories/country_repository.dart';
import 'package:immigru/domain/repositories/visa_repository.dart';
import 'package:immigru/presentation/blocs/onboarding/onboarding_bloc.dart';
import 'package:immigru/presentation/blocs/onboarding/onboarding_event.dart';
import 'package:immigru/presentation/widgets/loading_indicator.dart';
import 'package:immigru/presentation/screens/onboarding/widgets/migration_journey/migration_journey_header.dart';
import 'package:immigru/presentation/screens/onboarding/widgets/migration_journey/migration_timeline.dart';
import 'package:immigru/presentation/screens/onboarding/widgets/migration_journey/migration_step_modal.dart';

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
  State<MigrationJourneyStepWidget> createState() => _MigrationJourneyStepWidgetState();
}

class _MigrationJourneyStepWidgetState extends State<MigrationJourneyStepWidget> {
  // Repositories
  final CountryRepository _countryRepository = di.sl<CountryRepository>();
  final VisaRepository _visaRepository = di.sl<VisaRepository>();
  
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
    _loadCountries();
    _loadVisas();
    _lookupBirthCountryName();
  }
  
  /// Lookup the full country name from the ISO code
  Future<void> _lookupBirthCountryName() async {
    try {
      print('Looking up birth country name for ISO code: ${widget.birthCountry}');
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
      
      print('Birth country name found: $_birthCountryName');
    } catch (e) {
      print('Error looking up birth country name: $e');
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
      print('Loading countries...');
      final countries = await _countryRepository.getCountries();
      setState(() {
        // Convert Country entities to CountryModel objects
        _countries = countries.map((country) => CountryModel(
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
        )).toList();
        _isLoadingCountries = false;
      });
      print('Loaded ${countries.length} countries');
    } catch (e) {
      print('Error loading countries: $e');
      setState(() {
        _isLoadingCountries = false;
      });
    }
  }
  
  Future<void> _loadVisas() async {
    try {
      print('Loading visas...');
      final visas = await _visaRepository.getVisas();
      setState(() {
        _visas = visas;
        _isLoadingVisas = false;
      });
      print('Loaded ${visas.length} visas');
    } catch (e) {
      print('Error loading visas: $e');
      setState(() {
        _isLoadingVisas = false;
      });
    }
  }
  
  void _showAddStepModal() {
    print('Showing add step modal...');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MigrationStepModal(
        countries: _countries,
        visas: _visas,
        onSave: _addStep,
      ),
    );
  }
  
  void _editStep(int index) {
    print('Editing step at index $index...');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MigrationStepModal(
        countries: _countries,
        visas: _visas,
        initialStep: widget.migrationSteps[index],
        onSave: (step) => _updateStep(index, step),
      ),
    );
  }
  
  void _addStep(MigrationStep step) {
    print('==== ADDING NEW MIGRATION STEP ====');
    print('- Country: ${step.countryName} (ID: ${step.countryId})');
    print('- Visa: ${step.visaName} (ID: ${step.visaId})');
    print('- Is Current: ${step.isCurrentLocation}');
    print('- Is Target: ${step.isTargetDestination}');
    print('- Was Successful: ${step.wasSuccessful}');
    print('- Migration Reason: ${step.migrationReason?.name}');
    print('- Notes: ${step.notes ?? 'None'}');
    
    print('Calling widget.onAddStep with step...');
    try {
      widget.onAddStep(step);
      print('widget.onAddStep executed successfully');
    } catch (e) {
      print('ERROR in widget.onAddStep: $e');
    }
    
    print('Scheduling delayed save operation...');
    // Wait a short moment before triggering save to ensure UI is updated
    Future.delayed(const Duration(milliseconds: 500), () async {
      print('Delayed save timer triggered');
      // Trigger save after adding a new step
      try {
        await _triggerSaveData();
        print('_triggerSaveData completed successfully');
      } catch (e) {
        print('ERROR in delayed _triggerSaveData: $e');
      }
    });
    print('Delayed save operation scheduled');
    
    // Show a snackbar to indicate the step was added
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added migration step for ${step.countryName}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  void _updateStep(int index, MigrationStep step) {
    print('==== UPDATING MIGRATION STEP ====');
    print('Updating step at index $index');
    print('- Country: ${step.countryName} (ID: ${step.countryId})');
    print('- Visa: ${step.visaName} (ID: ${step.visaId})');
    print('- Is Current: ${step.isCurrentLocation}');
    print('- Is Target: ${step.isTargetDestination}');
    print('- Was Successful: ${step.wasSuccessful}');
    print('- Migration Reason: ${step.migrationReason?.name}');
    print('- Notes: ${step.notes ?? 'None'}');
    
    widget.onUpdateStep(index, step);
    
    // Show a snackbar to indicate the step was updated
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Updated migration step for ${step.countryName}'),
        duration: const Duration(seconds: 2),
      ),
    );
    
    // Wait a short moment before triggering save to ensure UI is updated
    Future.delayed(const Duration(milliseconds: 500), () async {
      // Trigger save after updating a step
      await _triggerSaveData();
    });
  }
  
  // Helper method to trigger saving data
  Future<void> _triggerSaveData() async {
    print('==== TRIGGER SAVE DATA - START ====');
    // Log the current migration steps before saving
    print('==== MIGRATION STEPS BEFORE SAVE ====');
    print('Total migration steps: ${widget.migrationSteps.length}');
    
    for (int i = 0; i < widget.migrationSteps.length; i++) {
      final step = widget.migrationSteps[i];
      print('Step ${i+1}:');
      print('- Country: ${step.countryName} (ID: ${step.countryId})');
      print('- Visa: ${step.visaName} (ID: ${step.visaId})');
      print('- Is Current: ${step.isCurrentLocation}');
      print('- Is Target: ${step.isTargetDestination}');
      print('- Was Successful: ${step.wasSuccessful}');
      print('- Migration Reason: ${step.migrationReason?.name}');
      print('- Notes: ${step.notes ?? 'None'}');
    }
    
    print('Creating Future.delayed to ensure UI updates first...');
    // Use Future.delayed to ensure the UI updates first
    Future.delayed(Duration.zero, () async {
      print('Future.delayed callback executing...');
      
      if (!context.mounted) {
        print('ERROR: Context is not mounted, cannot save data');
        return;
      }
      
      print('Context is mounted, proceeding with save...');
      try {
        // Get the OnboardingBloc directly from the context
        print('Getting OnboardingBloc from context...');
        final onboardingBloc = BlocProvider.of<OnboardingBloc>(context);
        print('Got OnboardingBloc instance successfully');
        print('Triggering save after migration step change');
        print('Sending ${widget.migrationSteps.length} migration steps to be saved');
        
        // Verify that the bloc state has the correct number of steps
        print('Checking current steps in bloc state...');
        final currentSteps = onboardingBloc.state.data.migrationSteps;
        print('Current steps in bloc state: ${currentSteps.length}');
        
        // If the bloc doesn't have all the steps, update it directly
        if (currentSteps.length != widget.migrationSteps.length) {
          print('WARNING: Bloc has ${currentSteps.length} steps but widget has ${widget.migrationSteps.length} steps');
          print('Ensuring all steps are in the bloc before saving...');
          
          // Add each step to the bloc individually to ensure they're all included
          for (final step in widget.migrationSteps) {
            if (!currentSteps.any((s) => 
                s.countryId == step.countryId && 
                s.visaId == step.visaId && 
                s.arrivedDate == step.arrivedDate)) {
              print('Adding missing step for ${step.countryName} to bloc');
              onboardingBloc.add(MigrationStepAdded(step));
            }
          }
          
          // Short delay to allow bloc to update before saving
          print('Waiting for bloc to update...');
          await Future.delayed(const Duration(milliseconds: 100));
          print('Bloc update delay completed');
        }
        
        // Add the save event to the bloc
        print('Adding OnboardingSaved event to bloc...');
        onboardingBloc.add(const OnboardingSaved());
        print('OnboardingSaved event added to bloc');
        
        // Show a snackbar to indicate the save process has started
        print('Showing save in progress snackbar...');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saving ${widget.migrationSteps.length} migration steps...'),
            duration: const Duration(seconds: 2),
          ),
        );
        print('Snackbar shown successfully');
        print('==== TRIGGER SAVE DATA - END ====');
      } catch (e) {
        print('Error triggering save: $e');
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving migration steps: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  void _removeStep(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Migration Step'),
        content: const Text('Are you sure you want to remove this migration step?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onRemoveStep(index);
              
              // Trigger save after removing a step
              Future.delayed(const Duration(milliseconds: 500), () async {
                await _triggerSaveData();
              });
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    // Show loading indicator if we're still loading data
    if (_isLoadingCountries || _isLoadingVisas) {
      return const Center(
        child: LoadingIndicator(message: 'Loading migration data...'),
      );
    }
    
    // If we have no countries or visas, show an error
    if (_countries.isEmpty || _visas.isEmpty) {
      return ErrorStateWidget(
        message: 'Could not load countries or visas. Please try again.',
        onRetry: () {
          setState(() {
            _isLoadingCountries = true;
            _isLoadingVisas = true;
          });
          _loadCountries();
          _loadVisas();
        },
      );
    }
    
    return SingleChildScrollView(
      controller: _scrollController,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with birth country
            const MigrationJourneyHeader(),
            
            // Timeline of migration steps
            MigrationTimeline(
              birthCountry: widget.birthCountry,
              migrationSteps: widget.migrationSteps,
              onEditStep: _editStep,
              onRemoveStep: _removeStep,
            ),
            
            const SizedBox(height: 24),
            
            // Add step button
            ElevatedButton.icon(
              onPressed: _showAddStepModal,
              icon: const Icon(Icons.add),
              label: const Text('Add travel history'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Continue button
            ElevatedButton(
              onPressed: widget.migrationSteps.isNotEmpty
                ? () async {
                    // Ensure all steps are saved before continuing
                    await _triggerSaveData();
                  }
                : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Error state widget for displaying error messages
class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorStateWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
