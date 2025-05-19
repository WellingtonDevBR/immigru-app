import 'package:immigru/domain/entities/onboarding_data.dart';
import 'package:immigru/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:immigru/new_core/network/edge_function_client.dart';
import 'package:immigru/new_core/logging/logger_interface.dart';

/// Implementation of the OnboardingFeatureRepository for the new architecture
class OnboardingRepositoryImpl implements OnboardingFeatureRepository {
  final EdgeFunctionClient _edgeFunctionClient;
  final LoggerInterface _logger;

  OnboardingRepositoryImpl(
    this._edgeFunctionClient,
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
        
        _logger.i('Saving birth country data: $birthCountryData', tag: 'Onboarding');
        
        await _edgeFunctionClient.invoke<dynamic>(
          'user-profile',
          body: {
            'action': 'save',
            'step': step,
            'data': birthCountryData,
          },
        );
      } 
      // Special handling for current status step
      else if (step == 'currentStatus') {
        // The edge function expects 'currentStatus', not 'statusId' or 'migrationStage'
        final Map<String, dynamic> statusData = {
          'currentStatus': data['statusId'], // Send status ID as currentStatus
        };
        
        _logger.i('Saving current status data: $statusData', tag: 'Onboarding');
        
        // Log the request for debugging
        _logger.d('Sending request to user-profile edge function with step: $step and data: $statusData', tag: 'Onboarding');
        
        final response = await _edgeFunctionClient.invoke<dynamic>(
          'user-profile',
          body: {
            'action': 'save',
            'step': step,
            'data': statusData,
          },
        );
        
        // Log the response for debugging
        _logger.d('Response from user-profile edge function: ${response.data}', tag: 'Onboarding');
        
        if (!response.isSuccess) {
          _logger.e('Failed to save current status: ${response.message}', tag: 'Onboarding');
          throw Exception('Failed to save current status: ${response.message}');
        }
      }
      // Default handling for other steps
      else {
        await _edgeFunctionClient.invoke<dynamic>(
          'user-profile',
          body: {
            'action': 'save',
            'step': step,
            'data': data,
          },
        );
      }
    } catch (e, stackTrace) {
      _logger.e('Error saving step data', tag: 'Onboarding', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<OnboardingData?> getOnboardingData() async {
    try {
      final response = await _edgeFunctionClient.invoke<Map<String, dynamic>>(
        'user-profile',
        body: {
          'action': 'get',
        },
      );

      final data = response.data;
      if (data == null) {
        return null;
      }

      // Convert the response to OnboardingData
      return OnboardingData(
        birthCountry: data['birthCountry'],
        currentStatus: data['currentStatus'],
        migrationSteps: [], // TODO: Parse migration steps
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
    } catch (e, stackTrace) {
      _logger.e('Error getting onboarding data', tag: 'Onboarding', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  @override
  Future<bool> isOnboardingComplete() async {
    try {
      final response = await _edgeFunctionClient.invoke<Map<String, dynamic>>(
        'user-profile',
        body: {
          'action': 'checkStatus',
        },
      );

      return response.data?['isCompleted'] ?? false;
    } catch (e, stackTrace) {
      _logger.e('Error checking onboarding status', tag: 'Onboarding', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  @override
  Future<void> completeOnboarding() async {
    try {
      await _edgeFunctionClient.invoke<dynamic>(
        'user-profile',
        body: {
          'action': 'save',
          'step': 'complete',
          'data': {'isCompleted': true},
        },
      );
    } catch (e, stackTrace) {
      _logger.e('Error completing onboarding', tag: 'Onboarding', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
