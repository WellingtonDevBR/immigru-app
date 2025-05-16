import 'package:immigru/shared/interfaces/logger_interface.dart';
import 'package:immigru/domain/usecases/onboarding_usecases.dart';

/// Use case for updating the user's current migration status
class UpdateCurrentStatusUseCase {
  final GetOnboardingDataUseCase _getOnboardingDataUseCase;
  final SaveOnboardingDataUseCase _saveOnboardingDataUseCase;
  final LoggerInterface _logger;

  UpdateCurrentStatusUseCase({
    required GetOnboardingDataUseCase getOnboardingDataUseCase,
    required SaveOnboardingDataUseCase saveOnboardingDataUseCase,
    required LoggerInterface logger,
  })  : _getOnboardingDataUseCase = getOnboardingDataUseCase,
        _saveOnboardingDataUseCase = saveOnboardingDataUseCase,
        _logger = logger;

  /// Update the user's current migration status
  /// 
  /// [statusId] must be one of: 'planning', 'preparing', 'moved', 'exploring', 'permanent'
  Future<bool> call(String statusId) async {
    try {
      _logger.i('Updating current status to: $statusId', tag: 'UpdateCurrentStatusUseCase');
      
      // Validate the status ID
      final validStatuses = ['planning', 'preparing', 'moved', 'exploring', 'permanent'];
      if (!validStatuses.contains(statusId)) {
        _logger.e(
          'Invalid status ID: $statusId. Must be one of: $validStatuses',
          tag: 'UpdateCurrentStatusUseCase',
        );
        return false;
      }
      
      // Get current onboarding data
      final currentData = await _getOnboardingDataUseCase();
      
      // Update only the current status field
      final updatedData = currentData.copyWith(currentStatus: statusId);
      
      // Save the updated data
      await _saveOnboardingDataUseCase(updatedData);
      
      _logger.i(
        'Successfully updated current status to: $statusId',
        tag: 'UpdateCurrentStatusUseCase',
      );
      
      return true;
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to update current status',
        tag: 'UpdateCurrentStatusUseCase',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }
}
