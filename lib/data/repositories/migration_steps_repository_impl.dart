import 'package:flutter/foundation.dart';
import 'package:immigru/core/services/logger_service.dart';
import 'package:immigru/data/datasources/remote/migration_steps_edge_function_data_source.dart';
import 'package:immigru/domain/entities/onboarding_data.dart';
import 'package:immigru/domain/entities/visa.dart';
import 'package:immigru/domain/repositories/migration_steps_repository.dart';

/// Implementation of the MigrationStepsRepository
class MigrationStepsRepositoryImpl implements MigrationStepsRepository {
  final MigrationStepsEdgeFunctionDataSource _dataSource;
  final LoggerService _logger;

  // Common country mappings to ensure we always have a name
  final Map<int, String> _countryMapping = {
    // Add common countries used in the app
    1: 'United States',
    2: 'Canada',
    3: 'United Kingdom',
    4: 'Australia',
    5: 'Brazil',
    6: 'Germany',
    7: 'France',
    8: 'Japan',
    9: 'China',
    10: 'India',
    // Add more as needed
  };
  
  /// Helper method to get country name by ID
  String _getCountryNameById(int countryId) {
    return _countryMapping[countryId] ?? 'Unknown Country';
  }

  // Track the last saved steps to prevent redundant API calls
  static List<MigrationStep>? _lastSavedSteps;
  static DateTime _lastSaveTime = DateTime(2000); // Initialize with old date

  MigrationStepsRepositoryImpl(this._dataSource, this._logger);

  @override
  Future<List<MigrationStep>> getMigrationSteps() async {
    try {
      _logger.debug('MigrationSteps', 'Fetching migration steps from edge function');
      
      final stepsData = await _dataSource.getMigrationSteps();
      
      // Convert the raw data to MigrationStep entities
      final steps = stepsData.map((stepData) {
        // Extract the required fields from the step data
        final int? id = stepData['Id'];
        final int countryId = stepData['CountryId'] ?? 0;
        
        // CRITICAL: Ensure country name is properly extracted and never empty
        String countryName = '';
        if (stepData['CountryName'] != null && stepData['CountryName'].toString().isNotEmpty) {
          countryName = stepData['CountryName'].toString();
        } else if (stepData['Country'] != null && stepData['Country']['Name'] != null) {
          // Try to get from nested Country object
          countryName = stepData['Country']['Name'].toString();
        } else {
          // If still empty, try to look up from a country mapping
          countryName = _getCountryNameById(countryId);
        }
        
        // Log country information for debugging
        debugPrint('Step ID: $id, CountryId: $countryId, CountryName: "$countryName"');
        
        // Handle visa information
        final int? visaId = stepData['VisaId'];
        String visaName = '';
        if (stepData['VisaName'] != null && stepData['VisaName'].toString().isNotEmpty) {
          visaName = stepData['VisaName'].toString();
        } else if (stepData['Visa'] != null && stepData['Visa']['VisaName'] != null) {
          // Try to get from nested Visa object
          visaName = stepData['Visa']['VisaName'].toString();
        }
        
        // Parse dates
        DateTime? arrivedDate;
        if (stepData['ArrivedAt'] != null) {
          try {
            arrivedDate = DateTime.parse(stepData['ArrivedAt']);
          } catch (e) {
            _logger.error('MigrationSteps', 'Failed to parse ArrivedAt date: ${stepData['ArrivedAt']}');
          }
        }
        
        DateTime? leftDate;
        if (stepData['LeftAt'] != null) {
          try {
            leftDate = DateTime.parse(stepData['LeftAt']);
          } catch (e) {
            _logger.error('MigrationSteps', 'Failed to parse LeftAt date: ${stepData['LeftAt']}');
          }
        }
        
        // Parse boolean values
        final bool isCurrentLocation = stepData['IsCurrent'] == true;
        final bool isTargetDestination = stepData['IsTarget'] == true;
        final bool wasSuccessful = stepData['WasSuccessful'] == true;
        
        // Parse notes
        final String? notes = stepData['Notes'];
        
        // Parse migration reason
        MigrationReason migrationReason = MigrationReason.work;
        if (stepData['MigrationReason'] != null) {
          final String reasonStr = stepData['MigrationReason'].toString().toLowerCase();
          switch (reasonStr) {
            case 'study':
              migrationReason = MigrationReason.study;
              break;
            case 'family':
              migrationReason = MigrationReason.family;
              break;
            case 'asylum':
            case 'refugee':
              migrationReason = MigrationReason.refugee;
              break;
            case 'retirement':
              migrationReason = MigrationReason.retirement;
              break;
            case 'investment':
              migrationReason = MigrationReason.investment;
              break;
            case 'lifestyle':
              migrationReason = MigrationReason.lifestyle;
              break;
            case 'other':
              migrationReason = MigrationReason.other;
              break;
            case 'work':
            default:
              migrationReason = MigrationReason.work;
              break;
          }
        }
        
        // Create and return the MigrationStep entity
        return MigrationStep(
          id: id,
          order: stepData['Order'] ?? 0,
          countryId: countryId,
          countryName: countryName,
          visaId: visaId,
          visaName: visaName,
          arrivedDate: arrivedDate,
          leftDate: leftDate,
          isCurrentLocation: isCurrentLocation,
          isTargetDestination: isTargetDestination,
          notes: notes,
          migrationReason: migrationReason,
          wasSuccessful: wasSuccessful,
        );
      }).toList();
      
      _logger.debug('MigrationSteps', 'Successfully fetched ${steps.length} migration steps');
      return steps;
    } catch (e, stackTrace) {
      _logger.error('MigrationSteps', 'Failed to get migration steps: $e');
      debugPrintStack(stackTrace: stackTrace, label: 'Migration Steps Get Error');
      return [];
    }
  }

  @override
  Future<bool> saveMigrationSteps(List<MigrationStep> steps, {List<MigrationStep>? deletedSteps}) async {
    try {
      final timestamp = DateTime.now().toIso8601String();
      debugPrint('[$timestamp] 🚀 REPOSITORY: MigrationStepsRepository.saveMigrationSteps called with ${steps.length} steps');
      if (deletedSteps != null && deletedSteps.isNotEmpty) {
        debugPrint('[$timestamp] 🗑️ Also processing ${deletedSteps.length} deleted steps');
      }
      _logger.debug('MigrationSteps', 'Starting save operation for ${steps.length} steps');
      
      // Validate steps before saving
      for (int i = 0; i < steps.length; i++) {
        final step = steps[i];
        
        // Log each step being saved with detailed information
        debugPrint('[$timestamp] 💾 Step $i: id=${step.id}, order=${step.order}');
        debugPrint('[$timestamp] 💾   countryId=${step.countryId}, countryName=${step.countryName}');
        debugPrint('[$timestamp] 💾   visaId=${step.visaId}, visaName=${step.visaName}');
        debugPrint('[$timestamp] 💾   dates: ${step.arrivedDate?.toIso8601String()} to ${step.leftDate?.toIso8601String()}');
        debugPrint('[$timestamp] 💾   isCurrent=${step.isCurrentLocation}, isTarget=${step.isTargetDestination}');
        debugPrint('[$timestamp] 💾   wasSuccessful=${step.wasSuccessful}, reason=${step.migrationReason}');
        
        // Validate required fields
        final countryId = step.countryId;
        if (countryId.toString().trim().isEmpty) {
          debugPrint('[$timestamp] ❌ Error: Step $i is missing countryId');
          _logger.error('MigrationSteps', 'Step $i is missing countryId');
          return false;
        }
      }
      
      // Check if there are any changes compared to the last saved steps
      // But always save if it's been more than 30 seconds since the last save
      if (_lastSavedSteps != null && 
          _lastSavedSteps!.length == steps.length && 
          DateTime.now().difference(_lastSaveTime).inSeconds < 30) {
        
        bool hasChanges = false;
        for (int i = 0; i < steps.length; i++) {
          if (i >= _lastSavedSteps!.length || steps[i] != _lastSavedSteps![i]) {
            hasChanges = true;
            debugPrint('[$timestamp] 🔄 Change detected in step $i');
            break;
          }
        }
        
        if (!hasChanges) {
          debugPrint('[$timestamp] ⚠️ No changes detected since last save, skipping API call');
          _logger.debug('MigrationSteps', 'No changes detected since last save, skipping API call');
          return true;
        }
      } else {
        debugPrint('[$timestamp] 🔄 Forcing save due to time elapsed or step count change');
      }
      
      // Sort steps by arrival date if not already sorted
      steps.sort((a, b) {
        if (a.arrivedDate == null && b.arrivedDate == null) return 0;
        if (a.arrivedDate == null) return 1; // Null dates go at the end
        if (b.arrivedDate == null) return -1;
        return a.arrivedDate!.compareTo(b.arrivedDate!);
      });
      
      // Update order field based on sorted position
      for (int i = 0; i < steps.length; i++) {
        steps[i] = steps[i].copyWith(order: i + 1); // 1-based ordering
        debugPrint('[$timestamp] 🔢 Updated step ${i+1}: ${steps[i].countryName} with order=${i+1}');
      }
      
      // Convert steps to JSON
      final stepsJson = steps.map((step) => step.toJson()).toList();
      debugPrint('[$timestamp] 📝 Converted ${stepsJson.length} steps to JSON');
      
      // Convert deleted steps to JSON if any
      final deletedStepsJson = deletedSteps?.map((step) => step.toJson()).toList() ?? [];
      if (deletedStepsJson.isNotEmpty) {
        debugPrint('[$timestamp] 🗑️ Converted ${deletedStepsJson.length} deleted steps to JSON');
      }
      
      // Save the steps via the data source
      debugPrint('[$timestamp] 🚀 REPOSITORY: Calling data source to save steps with action="save"');
      final result = await _dataSource.saveMigrationSteps(
        steps: stepsJson,
        deletedSteps: deletedStepsJson,
      );
      debugPrint('[$timestamp] 🚀 REPOSITORY: Data source save result: ${result['success']}');
      
      // Update the last saved steps and timestamp after successful save
      if (result['success'] == true) {
        _lastSavedSteps = List.from(steps);
        _lastSaveTime = DateTime.now();
        
        _logger.debug('MigrationSteps', 'Successfully saved migration steps');
        debugPrint('[$timestamp] ✅ Successfully saved ${steps.length} migration steps');
        return true;
      } else {
        final errorMessage = result['message'] ?? 'Unknown error';
        debugPrint('[$timestamp] ❌ Save operation failed: $errorMessage');
        _logger.error('MigrationSteps', 'Save operation failed: $errorMessage');
        return false;
      }
    } catch (e) {
      final timestamp = DateTime.now().toIso8601String();
      debugPrint('[$timestamp] ❌ Error saving migration steps: $e');
      _logger.error('MigrationSteps', 'Error saving migration steps: $e');
      return false;
    }
  }
  
  // No unused helper methods
}
