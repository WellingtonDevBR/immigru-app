import 'package:get_it/get_it.dart';
import 'package:immigru/core/services/onboarding_service.dart';
import 'package:immigru/core/services/session_manager.dart';
import 'package:immigru/core/services/supabase_service.dart';
import 'package:immigru/core/services/theme_service.dart';
import 'package:immigru/data/datasources/supabase_data_source.dart';
import 'package:immigru/data/models/supabase_auth_context.dart';
import 'package:immigru/data/repositories/auth_repository_impl.dart';
import 'package:immigru/data/repositories/data_repository_impl.dart';
import 'package:immigru/data/repositories/supabase_auth_service.dart';
import 'package:immigru/domain/entities/auth_context.dart';
import 'package:immigru/domain/repositories/auth_repository.dart';
import 'package:immigru/domain/repositories/auth_service.dart';
import 'package:immigru/domain/repositories/data_repository.dart';
import 'package:immigru/domain/usecases/auth_usecases.dart';
import 'package:immigru/domain/usecases/data_usecases.dart';
import 'package:immigru/domain/usecases/post_usecases.dart';
import 'package:immigru/presentation/blocs/auth/auth_bloc.dart';
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

  // Register repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<SupabaseDataSource>()),
  );
  sl.registerLazySingleton<DataRepository>(
    () => DataRepositoryImpl(sl<SupabaseDataSource>()),
  );
  
  // Register data sources
  sl.registerLazySingleton<SupabaseDataSource>(
    () => SupabaseDataSourceImpl(sl<SupabaseService>()),
  );
  
  // Register services
  sl.registerLazySingleton<OnboardingService>(() => OnboardingService());
  sl.registerLazySingleton<ThemeService>(() => ThemeService());
  
  // Register Supabase service as a singleton that's immediately initialized
  final supabaseService = SupabaseService();
  await supabaseService.initialize();
  sl.registerLazySingleton<SupabaseService>(() => supabaseService);
  
  sl.registerLazySingleton<SessionManager>(
    () => SessionManager(sl<AuthService>()),
  );
  
  // Register authentication context and service
  sl.registerLazySingleton<AuthContext>(
    () => SupabaseAuthContext(sl<SupabaseService>()),
  );
  sl.registerLazySingleton<AuthService>(
    () => SupabaseAuthService(sl<SupabaseService>()),
  );
  
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
  
  // Theme management is handled directly in app.dart with AppThemeProvider
  
  // Supabase is already initialized above
}
