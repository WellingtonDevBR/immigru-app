import 'package:get_it/get_it.dart';
import 'package:immigru/features/auth/data/datasources/auth_data_source.dart';
import 'package:immigru/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:immigru/features/auth/domain/repositories/auth_repository.dart';
import 'package:immigru/features/auth/domain/usecases/login_usecase.dart';
import 'package:immigru/features/auth/domain/usecases/logout_usecase.dart';
import 'package:immigru/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:immigru/features/auth/domain/usecases/signup_usecase.dart';
import 'package:immigru/features/auth/presentation/bloc/auth_bloc.dart';

/// Auth module for dependency injection
/// Registers all auth feature dependencies
class AuthModule {
  /// Register all auth dependencies
  static Future<void> register(GetIt sl) async {
    // Register data sources
    sl.registerLazySingleton<AuthDataSource>(
      () => AuthDataSource(),
    );
    
    // Register repositories
    sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl<AuthDataSource>()),
    );
    
    // Register use cases
    sl.registerLazySingleton<LoginWithEmailUseCase>(
      () => LoginWithEmailUseCase(sl<AuthRepository>()),
    );
    
    sl.registerLazySingleton<LoginWithPhoneUseCase>(
      () => LoginWithPhoneUseCase(sl<AuthRepository>()),
    );
    
    sl.registerLazySingleton<LoginWithGoogleUseCase>(
      () => LoginWithGoogleUseCase(sl<AuthRepository>()),
    );
    
    sl.registerLazySingleton<SignUpWithEmailUseCase>(
      () => SignUpWithEmailUseCase(sl<AuthRepository>()),
    );
    
    sl.registerLazySingleton<LogoutUseCase>(
      () => LogoutUseCase(sl<AuthRepository>()),
    );
    
    sl.registerLazySingleton<CheckAuthStatusUseCase>(
      () => CheckAuthStatusUseCase(sl<AuthRepository>()),
    );
    
    sl.registerLazySingleton<ResetPasswordUseCase>(
      () => ResetPasswordUseCase(sl<AuthRepository>()),
    );
    
    // Register BLoCs
    sl.registerFactory<AuthBloc>(
      () => AuthBloc(
        loginWithEmailUseCase: sl<LoginWithEmailUseCase>(),
        loginWithPhoneUseCase: sl<LoginWithPhoneUseCase>(),
        loginWithGoogleUseCase: sl<LoginWithGoogleUseCase>(),
        signUpWithEmailUseCase: sl<SignUpWithEmailUseCase>(),
        logoutUseCase: sl<LogoutUseCase>(),
        checkAuthStatusUseCase: sl<CheckAuthStatusUseCase>(),
        resetPasswordUseCase: sl<ResetPasswordUseCase>(),
      ),
    );
  }
}
