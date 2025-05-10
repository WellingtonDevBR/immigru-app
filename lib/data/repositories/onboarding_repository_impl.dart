import 'package:immigru/core/services/logger_service.dart';
import 'package:immigru/core/services/onboarding_service.dart';
import 'package:immigru/core/services/supabase_service.dart';
import 'package:immigru/data/models/onboarding_data_model.dart';
import 'package:immigru/domain/entities/onboarding_data.dart';
import 'package:immigru/domain/repositories/onboarding_repository.dart';

/// Implementation of the OnboardingRepository
class OnboardingRepositoryImpl implements OnboardingRepository {
  final SupabaseService _supabaseService;
  final LoggerService _logger;
  final OnboardingService _onboardingService;

  OnboardingRepositoryImpl(this._supabaseService, this._logger, this._onboardingService);

  @override
  Future<void> saveOnboardingData(OnboardingData data) async {
    try {
      final user = _supabaseService.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      final dataModel = OnboardingDataModel.fromEntity(data);
      
      await _supabaseService.client
          .from('user_profiles')
          .upsert({
            'user_id': user.id,
            'onboarding_data': dataModel.toJson(),
            'updated_at': DateTime.now().toIso8601String(),
          });

      _logger.debug('OnboardingRepository', 'Saved onboarding data for user: ${user.id}');
    } catch (e, stackTrace) {
      _logger.error(
        'OnboardingRepository',
        'Error saving onboarding data',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<OnboardingData> getOnboardingData() async {
    try {
      final user = _supabaseService.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      try {
        final data = await _supabaseService.client
            .from('user_profiles')
            .select('onboarding_data')
            .eq('user_id', user.id)
            .single();
            
        if (data['onboarding_data'] == null) {
          return OnboardingData.empty();
        }

        return OnboardingDataModel.fromJson(data['onboarding_data']);
      } catch (e) {
        _logger.debug('OnboardingRepository', 'No onboarding data found, returning empty data');
        return OnboardingData.empty();
      }
    } catch (e, stackTrace) {
      _logger.error(
        'OnboardingRepository',
        'Error retrieving onboarding data',
        error: e,
        stackTrace: stackTrace,
      );
      
      // Return empty data on error instead of crashing
      return OnboardingData.empty();
    }
  }

  @override
  Future<bool> hasCompletedOnboarding() async {
    try {
      // First check local storage for faster response
      final hasCompleted = await _onboardingService.hasCompletedOnboarding();
      if (hasCompleted) {
        return true;
      }
      
      // If not found in local storage, check the database
      final onboardingData = await getOnboardingData();
      return onboardingData.isCompleted;
    } catch (e, stackTrace) {
      _logger.error(
        'OnboardingRepository',
        'Error checking onboarding completion status',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  @override
  Future<void> completeOnboarding() async {
    try {
      final user = _supabaseService.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      // Get current onboarding data
      final onboardingData = await getOnboardingData();
      
      // Mark as completed
      final updatedData = onboardingData.copyWith(isCompleted: true);
      
      // Save to database
      await saveOnboardingData(updatedData);
      
      // Also save to local storage for faster access
      await _onboardingService.markOnboardingCompleted();
      
      _logger.debug('OnboardingRepository', 'Marked onboarding as completed for user: ${user.id}');
    } catch (e, stackTrace) {
      _logger.error(
        'OnboardingRepository',
        'Error completing onboarding',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
