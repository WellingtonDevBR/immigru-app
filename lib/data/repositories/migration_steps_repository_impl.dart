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
        final String countryName = stepData['CountryName'] ?? '';
        final int? visaId = stepData['VisaId'];
        final String visaName = stepData['VisaName'] ?? '';
        
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
  Future<bool> saveMigrationSteps(List<MigrationStep> steps) async {
    try {
      final timestamp = DateTime.now().toIso8601String();
      debugPrint('[$timestamp] 🚀 REPOSITORY: MigrationStepsRepository.saveMigrationSteps called with ${steps.length} steps');
      _logger.debug('MigrationSteps', 'Starting save operation for ${steps.length} migration steps');
      
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
        if (countryId == null || countryId.toString().trim().isEmpty) {
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
      
      // Convert steps to JSON
      final stepsJson = steps.map((step) => step.toJson()).toList();
      debugPrint('[$timestamp] 📝 Converted ${stepsJson.length} steps to JSON');
      
      // Save the steps via the data source
      debugPrint('[$timestamp] 🚀 REPOSITORY: Calling data source to save steps with action="save"');
      final result = await _dataSource.saveMigrationSteps(steps: stepsJson);
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
