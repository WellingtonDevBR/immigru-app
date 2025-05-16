import 'package:get_it/get_it.dart';
import 'package:immigru/domain/repositories/onboarding_repository.dart' as old_repo;
import 'package:immigru/domain/repositories/visa_repository.dart' as old_visa_repo;
import 'package:immigru/domain/usecases/onboarding_usecases.dart' as old_usecases;
import 'package:immigru/features/onboarding/data/repositories/migration_journey_repository_impl.dart';
import 'package:immigru/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:immigru/features/onboarding/data/repositories/visa_repository_impl.dart';
import 'package:immigru/features/onboarding/domain/repositories/migration_journey_repository.dart';
import 'package:immigru/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:immigru/features/onboarding/domain/repositories/visa_repository.dart';
import 'package:immigru/features/onboarding/domain/usecases/add_migration_step_usecase.dart';
import 'package:immigru/features/onboarding/domain/usecases/check_onboarding_status_usecase.dart';
import 'package:immigru/features/onboarding/domain/usecases/complete_onboarding_usecase.dart';
import 'package:immigru/features/onboarding/domain/usecases/get_migration_steps_usecase.dart';
import 'package:immigru/features/onboarding/domain/usecases/get_onboarding_data_usecase.dart';
import 'package:immigru/features/onboarding/domain/usecases/remove_migration_step_usecase.dart';
import 'package:immigru/features/onboarding/domain/usecases/save_migration_steps_usecase.dart';
import 'package:immigru/features/onboarding/domain/usecases/save_onboarding_data_usecase.dart';
import 'package:immigru/features/onboarding/domain/usecases/update_birth_country_usecase.dart';
import 'package:immigru/features/onboarding/domain/usecases/update_current_status_usecase.dart';
import 'package:immigru/features/onboarding/domain/usecases/update_migration_step_usecase.dart';
import 'package:immigru/features/onboarding/presentation/bloc/birth_country/birth_country_bloc.dart';
import 'package:immigru/features/onboarding/presentation/bloc/current_status/current_status_bloc.dart';
import 'package:immigru/features/onboarding/presentation/bloc/migration_journey/migration_journey_bloc.dart';
import 'package:immigru/features/onboarding/presentation/bloc/onboarding/onboarding_bloc.dart';

import 'package:immigru/new_core/country/domain/usecases/get_countries_usecase.dart' as new_arch;
import 'package:immigru/new_core/di/service_locator.dart';
import 'package:immigru/new_core/logging/logger_provider.dart';
import 'package:immigru/new_core/network/edge_function_client.dart';
import 'package:immigru/shared/interfaces/logger_interface.dart';

/// Onboarding module for dependency injection
/// Registers all onboarding feature dependencies
class OnboardingModule {
  /// Register all onboarding dependencies
  static Future<void> register(GetIt sl) async {
    // Register feature-specific logger
    if (!sl.isRegistered<LoggerInterface>(instanceName: 'onboarding_logger')) {
      sl.registerFactory<LoggerInterface>(
        () => sl<LoggerProvider>().createFeatureLogger('Onboarding'),
        instanceName: 'onboarding_logger',
      );
    }
    
    // Register repositories
    if (!sl.isRegistered<OnboardingFeatureRepository>()) {
      sl.registerLazySingleton<OnboardingFeatureRepository>(
        () => OnboardingRepositoryImpl(
          sl<EdgeFunctionClient>(),
          sl<LoggerInterface>(instanceName: 'onboarding_logger'),
        ),
      );
    }
    
    // Register Migration Journey Repository
    if (!sl.isRegistered<MigrationJourneyRepository>()) {
      sl.registerLazySingleton<MigrationJourneyRepository>(
        () => MigrationJourneyRepositoryImpl(
          sl<EdgeFunctionClient>(),
          sl<LoggerInterface>(instanceName: 'onboarding_logger'),
        ),
      );
    }
    
    // Register Visa Repository
    if (!sl.isRegistered<VisaRepository>()) {
      sl.registerLazySingleton<VisaRepository>(
        () => VisaRepositoryImpl(
          sl<EdgeFunctionClient>(),
          sl<LoggerInterface>(instanceName: 'onboarding_logger'),
        ),
      );
    }
    
    // Also register as old VisaRepository for backward compatibility
    if (!sl.isRegistered<old_visa_repo.VisaRepository>()) {
      sl.registerLazySingleton<old_visa_repo.VisaRepository>(
        () => sl<VisaRepository>() as dynamic,
      );
    }
    
    // Register with specific instance name for fallback access
    if (!sl.isRegistered<VisaRepository>(instanceName: 'domain_visa_repository')) {
      sl.registerLazySingleton<VisaRepository>(
        () => sl<VisaRepository>(),
        instanceName: 'domain_visa_repository',
      );
    }
    
    // Also register as OnboardingRepository for backward compatibility
    if (!sl.isRegistered<old_repo.OnboardingRepository>()) {
      sl.registerLazySingleton<old_repo.OnboardingRepository>(
        () => sl<OnboardingFeatureRepository>() as dynamic,
      );
    }
    
    // Register use cases
    if (!sl.isRegistered<UpdateBirthCountryUseCase>()) {
      sl.registerFactory<UpdateBirthCountryUseCase>(
        () => UpdateBirthCountryUseCase(
          sl<OnboardingFeatureRepository>(),
        ),
      );
    }
    
    if (!sl.isRegistered<GetOnboardingDataUseCase>()) {
      sl.registerFactory<GetOnboardingDataUseCase>(
        () => GetOnboardingDataUseCase(
          sl<OnboardingFeatureRepository>(),
        ),
      );
    }
    
    if (!sl.isRegistered<SaveOnboardingDataUseCase>()) {
      sl.registerFactory<SaveOnboardingDataUseCase>(
        () => SaveOnboardingDataUseCase(
          sl<OnboardingFeatureRepository>(),
        ),
      );
    }
    
    if (!sl.isRegistered<CheckOnboardingStatusUseCase>()) {
      sl.registerFactory<CheckOnboardingStatusUseCase>(
        () => CheckOnboardingStatusUseCase(
          sl<OnboardingFeatureRepository>(),
        ),
      );
    }
    
    if (!sl.isRegistered<CompleteOnboardingUseCase>()) {
      sl.registerFactory<CompleteOnboardingUseCase>(
        () => CompleteOnboardingUseCase(
          sl<OnboardingFeatureRepository>(),
        ),
      );
    }
    
    // Register Migration Journey Use Cases
    if (!sl.isRegistered<GetMigrationStepsUseCase>()) {
      sl.registerFactory<GetMigrationStepsUseCase>(
        () => GetMigrationStepsUseCase(
          sl<MigrationJourneyRepository>(),
          sl<LoggerInterface>(instanceName: 'onboarding_logger'),
        ),
      );
    }
    
    if (!sl.isRegistered<SaveMigrationStepsUseCase>()) {
      sl.registerFactory<SaveMigrationStepsUseCase>(
        () => SaveMigrationStepsUseCase(
          sl<MigrationJourneyRepository>(),
          sl<LoggerInterface>(instanceName: 'onboarding_logger'),
        ),
      );
    }
    
    if (!sl.isRegistered<AddMigrationStepUseCase>()) {
      sl.registerFactory<AddMigrationStepUseCase>(
        () => AddMigrationStepUseCase(
          sl<MigrationJourneyRepository>(),
          sl<LoggerInterface>(instanceName: 'onboarding_logger'),
        ),
      );
    }
    
    if (!sl.isRegistered<UpdateMigrationStepUseCase>()) {
      sl.registerFactory<UpdateMigrationStepUseCase>(
        () => UpdateMigrationStepUseCase(
          sl<MigrationJourneyRepository>(),
          sl<LoggerInterface>(instanceName: 'onboarding_logger'),
        ),
      );
    }
    
    if (!sl.isRegistered<RemoveMigrationStepUseCase>()) {
      sl.registerFactory<RemoveMigrationStepUseCase>(
        () => RemoveMigrationStepUseCase(
          sl<MigrationJourneyRepository>(),
          sl<LoggerInterface>(instanceName: 'onboarding_logger'),
        ),
      );
    }
    
    // Register BirthCountryBloc
    if (!sl.isRegistered<BirthCountryBloc>()) {
      sl.registerFactory<BirthCountryBloc>(
        () => BirthCountryBloc(
          getCountriesUseCase: ServiceLocator.instance<new_arch.GetCountriesUseCase>(),
          updateBirthCountryUseCase: sl<UpdateBirthCountryUseCase>(),
          logger: sl<LoggerInterface>(instanceName: 'onboarding_logger'),
        ),
      );
    }
    
    // Register UpdateCurrentStatusUseCase
    if (!sl.isRegistered<UpdateCurrentStatusUseCase>()) {
      sl.registerFactory<UpdateCurrentStatusUseCase>(
        () => UpdateCurrentStatusUseCase(
          getOnboardingDataUseCase: sl<old_usecases.GetOnboardingDataUseCase>(instanceName: 'domain_get_onboarding_data'),
          saveOnboardingDataUseCase: sl<old_usecases.SaveOnboardingDataUseCase>(instanceName: 'domain_save_onboarding_data'),
          logger: sl<LoggerInterface>(instanceName: 'onboarding_logger'),
        ),
      );
    }
    
    // Register CurrentStatusBloc
    if (!sl.isRegistered<CurrentStatusBloc>()) {
      sl.registerFactory<CurrentStatusBloc>(
        () => CurrentStatusBloc(
          repository: sl<OnboardingFeatureRepository>(),
          logger: sl<LoggerInterface>(instanceName: 'onboarding_logger'),
        ),
      );
    }
    
    // Register MigrationJourneyBloc
    if (!sl.isRegistered<MigrationJourneyBloc>()) {
      sl.registerFactory<MigrationJourneyBloc>(
        () => MigrationJourneyBloc(
          getMigrationStepsUseCase: sl<GetMigrationStepsUseCase>(),
          saveMigrationStepsUseCase: sl<SaveMigrationStepsUseCase>(),
          addMigrationStepUseCase: sl<AddMigrationStepUseCase>(),
          updateMigrationStepUseCase: sl<UpdateMigrationStepUseCase>(),
          removeMigrationStepUseCase: sl<RemoveMigrationStepUseCase>(),
          logger: sl<LoggerInterface>(instanceName: 'onboarding_logger'),
        ),
      );
    }
    
    // Register domain use cases with specific instance names
    if (!sl.isRegistered<old_usecases.GetOnboardingDataUseCase>(instanceName: 'domain_get_onboarding_data')) {
      sl.registerLazySingleton<old_usecases.GetOnboardingDataUseCase>(
        () => old_usecases.GetOnboardingDataUseCase(sl<old_repo.OnboardingRepository>()),
        instanceName: 'domain_get_onboarding_data',
      );
    }
    
    if (!sl.isRegistered<old_usecases.SaveOnboardingDataUseCase>(instanceName: 'domain_save_onboarding_data')) {
      sl.registerLazySingleton<old_usecases.SaveOnboardingDataUseCase>(
        () => old_usecases.SaveOnboardingDataUseCase(sl<old_repo.OnboardingRepository>()),
        instanceName: 'domain_save_onboarding_data',
      );
    }
    
    // Register regular use cases without instance names for direct injection
    if (!sl.isRegistered<old_usecases.GetOnboardingDataUseCase>()) {
      sl.registerLazySingleton<old_usecases.GetOnboardingDataUseCase>(
        () => old_usecases.GetOnboardingDataUseCase(sl<old_repo.OnboardingRepository>()),
      );
    }
    
    if (!sl.isRegistered<old_usecases.SaveOnboardingDataUseCase>()) {
      sl.registerLazySingleton<old_usecases.SaveOnboardingDataUseCase>(
        () => old_usecases.SaveOnboardingDataUseCase(sl<old_repo.OnboardingRepository>()),
      );
    }
    
    // Register OnboardingBloc
    if (!sl.isRegistered<OnboardingBloc>()) {
      sl.registerFactory<OnboardingBloc>(() => OnboardingBloc(
            repository: sl<OnboardingFeatureRepository>(),
            logger: sl<LoggerInterface>(instanceName: 'onboarding_logger'),
          ));
    }
  }
}
