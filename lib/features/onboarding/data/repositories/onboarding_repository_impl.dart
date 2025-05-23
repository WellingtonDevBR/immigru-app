import 'package:immigru/features/onboarding/domain/entities/onboarding_data.dart';
import 'package:immigru/features/onboarding/domain/entities/migration_step.dart';
import 'package:immigru/features/onboarding/data/datasources/onboarding_data_source.dart';
import 'package:immigru/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:immigru/core/logging/logger_interface.dart';

/// Implementation of the OnboardingRepository for the new architecture
class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingDataSource _dataSource;
  final LoggerInterface _logger;

  OnboardingRepositoryImpl(
    this._dataSource,
    this._logger,
  );

  @override
  Future<void> saveStepData(String step, Map<String, dynamic> data) async {
    try {
      // Special handling for birth country step
      if (step == 'birthCountry') {
        // Make sure we're sending the ISO code as expected by the edge function
        final Map<String, dynamic> birthCountryData = {
          'birthCountry': data['countryId'], // Send ISO code as birthCountry
        };

        _logger.i('Saving birth country data: $birthCountryData',
            tag: 'Onboarding');
        await _dataSource.saveStepData(step, birthCountryData);
      }
      // Special handling for current status step
      else if (step == 'currentStatus') {
        // The edge function expects 'currentStatus', not 'statusId' or 'migrationStage'
        final Map<String, dynamic> statusData = {
          'currentStatus':
              data['currentStatus'], // Use the currentStatus parameter directly
        };

        _logger.i('Saving current status data: $statusData', tag: 'Onboarding');
        _logger.d('Sending request for step: $step and data: $statusData',
            tag: 'Onboarding');

        await _dataSource.saveStepData(step, statusData);
      }
      // Default handling for other steps
      else {
        _logger.i('Saving onboarding data for step: $step with data: $data',
            tag: 'Onboarding');
        await _dataSource.saveStepData(step, data);
      }
    } catch (e) {
      _logger.e('Error saving onboarding data: $e', tag: 'Onboarding');
      rethrow;
    }
  }

  @override
  Future<OnboardingData?> getOnboardingData() async {
    try {
      _logger.i('Getting onboarding data', tag: 'Onboarding');

      final data = await _dataSource.getOnboardingData();

      _logger.d('Received onboarding data: $data', tag: 'Onboarding');

      if (data.isEmpty) {
        return null;
      }

      // Convert the migration steps data
      final List<dynamic> rawMigrationSteps = data['migrationSteps'] ?? [];
      final List<MigrationStep> migrationSteps = rawMigrationSteps.map((step) {
        final Map<String, dynamic> stepData = step as Map<String, dynamic>;

        return MigrationStep(
          id: stepData['id'] ?? '',
          countryId: stepData['countryId'] ?? 0,
          countryCode: stepData['countryCode'] ?? '',
          countryName: stepData['countryName'] ?? '',
          visaTypeId: stepData['visaId'] ?? 0,
          visaTypeName: stepData['visaName'] ?? '',
          startDate: stepData['arrivedDate'] != null
              ? DateTime.parse(stepData['arrivedDate'])
              : null,
          endDate: stepData['leftDate'] != null
              ? DateTime.parse(stepData['leftDate'])
              : null,
          isCurrentLocation: stepData['isCurrentLocation'] ?? false,
          isTargetCountry: stepData['isTargetDestination'] ?? false,
          isBirthCountry: stepData['isBirthCountry'] ?? false,
          order: stepData['order'] ?? 0,
        );
      }).toList();

      // Convert the response to OnboardingData
      return OnboardingData(
        birthCountry: data['birthCountry'],
        currentStatus: data['currentStatus'],
        migrationSteps: migrationSteps,
        profession: data['profession'],
        languages: List<String>.from(data['languages'] ?? []),
        interests: List<String>.from(data['interests'] ?? []),
        fullName: data['fullName'],
        displayName: data['displayName'],
        bio: data['bio'],
        currentLocation: data['currentLocation'],
        destinationCity: data['destinationCity'],
        profilePhotoUrl: data['profilePhotoUrl'],
        isPrivate: data['isPrivate'] ?? false,
        selectedImmiGroves: List<String>.from(data['selectedImmiGroves'] ?? []),
        isCompleted: data['isCompleted'] ?? false,
      );
    } catch (e) {
      _logger.e('Error getting onboarding data: $e', tag: 'Onboarding');
      return null;
    }
  }

  @override
  Future<bool> isOnboardingComplete() async {
    try {
      _logger.i('Checking if onboarding is complete', tag: 'Onboarding');

      final isComplete = await _dataSource.isOnboardingComplete();

      _logger.i('Onboarding complete status: $isComplete', tag: 'Onboarding');

      return isComplete;
    } catch (e) {
      _logger.e('Error checking onboarding status: $e', tag: 'Onboarding');
      return false;
    }
  }

  @override
  Future<void> completeOnboarding() async {
    try {
      _logger.i('Marking onboarding as complete', tag: 'Onboarding');

      await _dataSource.completeOnboarding();

      _logger.i('Successfully marked onboarding as complete',
          tag: 'Onboarding');
    } catch (e) {
      _logger.e('Error completing onboarding: $e', tag: 'Onboarding');
      rethrow;
    }
  }
}
