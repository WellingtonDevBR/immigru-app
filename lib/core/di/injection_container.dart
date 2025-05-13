import 'package:get_it/get_it.dart';
import 'package:immigru/core/services/edge_function_logger.dart';
import 'package:immigru/core/services/logger_service.dart';
import 'package:immigru/core/services/onboarding_service.dart';
import 'package:immigru/core/services/session_manager.dart';
import 'package:immigru/core/services/supabase_service.dart';
import 'package:immigru/data/datasources/supabase_data_source.dart';
import 'package:immigru/data/datasources/remote/user_profile_edge_function_data_source.dart';
import 'package:immigru/data/models/supabase_auth_context.dart';
import 'package:immigru/data/repositories/auth_repository_impl.dart';
import 'package:immigru/data/repositories/country_repository_impl.dart';
// import 'package:immigru/data/repositories/data_repository_impl.dart';
import 'package:immigru/data/repositories/interest_repository_impl.dart';
import 'package:immigru/data/repositories/language_repository_impl.dart';
import 'package:immigru/data/repositories/onboarding_repository_impl.dart';
import 'package:immigru/data/repositories/supabase_auth_service.dart';
import 'package:immigru/data/repositories/profile_repository_impl.dart';
import 'package:immigru/data/repositories/visa_repository_impl.dart';
import 'package:immigru/data/repositories/immi_grove_repository_impl.dart';
import 'package:immigru/data/datasources/remote/immi_grove_edge_function_data_source.dart';
import 'package:immigru/domain/entities/auth_context.dart';
import 'package:immigru/domain/repositories/auth_repository.dart';
import 'package:immigru/domain/repositories/auth_service.dart';
import 'package:immigru/domain/repositories/country_repository.dart';
import 'package:immigru/domain/repositories/data_repository.dart';
import 'package:immigru/domain/repositories/interest_repository.dart';
import 'package:immigru/domain/repositories/language_repository.dart';
import 'package:immigru/domain/repositories/onboarding_repository.dart';
import 'package:immigru/domain/repositories/profile_repository.dart';
import 'package:immigru/domain/repositories/visa_repository.dart';
import 'package:immigru/domain/repositories/immi_grove_repository.dart';
import 'package:immigru/domain/usecases/auth_usecases.dart';
import 'package:immigru/domain/usecases/country_usecases.dart';
import 'package:immigru/domain/usecases/data_usecases.dart';
import 'package:immigru/domain/usecases/interest_usecases.dart';
import 'package:immigru/domain/usecases/language_usecases.dart';
import 'package:immigru/domain/usecases/onboarding_usecases.dart';
import 'package:immigru/domain/usecases/post_usecases.dart';
import 'package:immigru/domain/usecases/profile_usecases.dart';
import 'package:immigru/domain/usecases/immi_grove_usecases.dart';
import 'package:immigru/presentation/blocs/auth/auth_bloc.dart';
import 'package:immigru/presentation/blocs/onboarding/onboarding_bloc.dart';
import 'package:immigru/presentation/blocs/profile/profile_bloc.dart';
import 'package:immigru/presentation/blocs/immi_grove/immi_grove_bloc.dart';
// Theme imports are handled directly in app.dart

// Service locator instance
final sl = GetIt.instance;

Future<void> init() async {
  // Register BLoCs
  sl.registerFactory<AuthBloc>(() => AuthBloc(
    sessionManager: sl<SessionManager>(),
    sendOtpToPhoneUseCase: sl<SendOtpToPhoneUseCase>(),
    verifyPhoneOtpUseCase: sl<VerifyPhoneOtpUseCase>(),
  ));
  
  sl.registerFactory<ImmiGroveBloc>(() => ImmiGroveBloc(
    getRecommendedImmiGrovesUseCase: sl<GetRecommendedImmiGrovesUseCase>(),
    joinImmiGroveUseCase: sl<JoinImmiGroveUseCase>(),
    leaveImmiGroveUseCase: sl<LeaveImmiGroveUseCase>(),
    getJoinedImmiGrovesUseCase: sl<GetJoinedImmiGrovesUseCase>(),
  ));

  sl.registerFactory<OnboardingBloc>(() => OnboardingBloc(
    saveOnboardingDataUseCase: sl<SaveOnboardingDataUseCase>(),
    checkOnboardingStatusUseCase: sl<CheckOnboardingStatusUseCase>(),
    getOnboardingDataUseCase: sl<GetOnboardingDataUseCase>(),
    completeOnboardingUseCase: sl<CompleteOnboardingUseCase>(),
    logger: sl<LoggerService>(),
  ));

  sl.registerFactory<ProfileBloc>(() => ProfileBloc(
    getProfileUseCase: sl<GetProfileUseCase>(),
    saveProfileUseCase: sl<SaveProfileUseCase>(),
    uploadProfilePhotoUseCase: sl<UploadProfilePhotoUseCase>(),
    updatePrivacySettingsUseCase: sl<UpdatePrivacySettingsUseCase>(),
    logger: sl<LoggerService>(),
  ));

  // Register repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<SupabaseDataSource>()),
  );
  
  sl.registerLazySingleton<CountryRepository>(
    () => CountryRepositoryImpl(
      dataSource: sl<SupabaseDataSource>(),
      logger: sl<LoggerService>(),
    ),
  );
  
  // Register OnboardingRepository with CountryRepository for country code resolution
  sl.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImpl(
      sl<SupabaseService>(), 
      sl<LoggerService>(), 
      sl<OnboardingService>(),
    ),
  );
  sl.registerLazySingleton<VisaRepository>(
    () => VisaRepositoryImpl(sl<SupabaseService>()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      sl<SupabaseService>(), 
      sl<LoggerService>(), 
      sl(),  // UserProfileEdgeFunctionDataSource
      sl<OnboardingService>(),
    ),
  );
  sl.registerLazySingleton<LanguageRepository>(
    () => LanguageRepositoryImpl(sl<SupabaseService>()),
  );
  sl.registerLazySingleton<InterestRepository>(
    () => InterestRepositoryImpl(sl<SupabaseService>()),
  );
  
  // Register ImmiGrove repository
  sl.registerLazySingleton<ImmiGroveRepository>(
    () => ImmiGroveRepositoryImpl(
      edgeFunctionDataSource: sl<ImmiGroveEdgeFunctionDataSource>(),
      logger: sl<LoggerService>(),
    ),
  );
  
  // Register data sources
  sl.registerLazySingleton<SupabaseDataSource>(
    () => SupabaseDataSourceImpl(sl<SupabaseService>()),
  );
  sl.registerLazySingleton<UserProfileEdgeFunctionDataSource>(
    () => UserProfileEdgeFunctionDataSource(sl<SupabaseService>(), sl<LoggerService>()),
  );
  sl.registerLazySingleton<ImmiGroveEdgeFunctionDataSource>(
    () => ImmiGroveEdgeFunctionDataSource(
      supabaseService: sl<SupabaseService>(),
      logger: sl<LoggerService>(),
    ),
  );
  
  // Register core services first
  sl.registerLazySingleton<LoggerService>(() => LoggerService());
  
  // Register Supabase service as a singleton that's immediately initialized
  final supabaseService = SupabaseService();
  await supabaseService.initialize();
  sl.registerLazySingleton<SupabaseService>(() => supabaseService);
  
  // Register authentication context and service
  sl.registerLazySingleton<AuthContext>(
    () => SupabaseAuthContext(sl<SupabaseService>()),
  );
  sl.registerLazySingleton<AuthService>(
    () => SupabaseAuthService(sl<SupabaseService>()),
  );
  
  // Register remaining services
  sl.registerLazySingleton<EdgeFunctionLogger>(() => EdgeFunctionLogger(sl<LoggerService>()));
  sl.registerLazySingleton<OnboardingService>(() => OnboardingService());
  sl.registerLazySingleton<SessionManager>(() => SessionManager(sl<AuthService>()));
  
  
  // Register use cases
  // Auth use cases
  sl.registerLazySingleton(() => SignInWithEmailUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SignUpWithEmailUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SignOutUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => IsAuthenticatedUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SendOtpToPhoneUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => VerifyPhoneOtpUseCase(sl<AuthRepository>()));
  
  // Data use cases
  sl.registerLazySingleton(() => GetDataFromTableUseCase(sl<DataRepository>()));
  sl.registerLazySingleton(() => InsertIntoTableUseCase(sl<DataRepository>()));
  sl.registerLazySingleton(() => UpdateInTableUseCase(sl<DataRepository>()));
  sl.registerLazySingleton(() => DeleteFromTableUseCase(sl<DataRepository>()));
  
  // Post and Event use cases
  sl.registerLazySingleton(() => GetPostsUseCase(sl<DataRepository>()));
  sl.registerLazySingleton(() => CreatePostUseCase(sl<DataRepository>()));
  sl.registerLazySingleton(() => GetEventsUseCase(sl<DataRepository>()));
  sl.registerLazySingleton(() => CreateEventUseCase(sl<DataRepository>()));
  
  // Onboarding use cases
  sl.registerLazySingleton(() => GetOnboardingDataUseCase(sl<OnboardingRepository>()));
  sl.registerLazySingleton(() => SaveOnboardingDataUseCase(sl<OnboardingRepository>()));
  sl.registerLazySingleton(() => CompleteOnboardingUseCase(sl<OnboardingRepository>()));
  sl.registerLazySingleton(() => CheckOnboardingStatusUseCase(sl<OnboardingRepository>()));
  sl.registerLazySingleton(() => GetLanguagesUseCase(sl<LanguageRepository>()));
  sl.registerLazySingleton(() => SaveUserLanguagesUseCase(sl<LanguageRepository>()));
  sl.registerLazySingleton(() => GetUserLanguagesUseCase(sl<LanguageRepository>()));
  sl.registerLazySingleton(() => GetInterestsUseCase(sl<InterestRepository>()));
  sl.registerLazySingleton(() => SaveUserInterestsUseCase(sl<InterestRepository>()));
  sl.registerLazySingleton(() => GetUserInterestsUseCase(sl<InterestRepository>()));
  
  // ImmiGrove use cases
  sl.registerLazySingleton(() => GetRecommendedImmiGrovesUseCase(sl<ImmiGroveRepository>()));
  sl.registerLazySingleton(() => JoinImmiGroveUseCase(sl<ImmiGroveRepository>()));
  sl.registerLazySingleton(() => LeaveImmiGroveUseCase(sl<ImmiGroveRepository>()));
  sl.registerLazySingleton(() => GetJoinedImmiGrovesUseCase(sl<ImmiGroveRepository>()));
  
  // Profile use cases
  sl.registerLazySingleton(() => GetProfileUseCase(sl<ProfileRepository>()));
  sl.registerLazySingleton(() => SaveProfileUseCase(sl<ProfileRepository>()));
  sl.registerLazySingleton(() => UploadProfilePhotoUseCase(sl<ProfileRepository>()));
  sl.registerLazySingleton(() => UpdatePrivacySettingsUseCase(sl<ProfileRepository>()));

  // Country use cases
  sl.registerLazySingleton(() => GetCountriesUseCase(sl<CountryRepository>()));

  // Theme management is handled directly in app.dart with AppThemeProvider
  
  // Supabase is already initialized above
}
