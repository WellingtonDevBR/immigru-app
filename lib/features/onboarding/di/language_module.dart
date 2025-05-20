import 'package:get_it/get_it.dart';
import 'package:immigru/features/onboarding/data/datasources/language_data_source.dart';
import 'package:immigru/features/onboarding/data/repositories/language_repository_impl.dart';
import 'package:immigru/features/onboarding/domain/repositories/language_repository.dart';
import 'package:immigru/features/onboarding/domain/usecases/get_languages_usecase.dart';
import 'package:immigru/features/onboarding/domain/usecases/get_user_languages_usecase.dart';
import 'package:immigru/features/onboarding/domain/usecases/save_user_languages_usecase.dart';
import 'package:immigru/features/onboarding/presentation/bloc/language/language_bloc.dart';
import 'package:immigru/new_core/logging/logger_interface.dart';
import 'package:immigru/new_core/network/edge_function_client.dart';

/// Register all dependencies for the language feature
void registerLanguageModule(GetIt sl) {
  // Data sources
  sl.registerLazySingleton<LanguageDataSource>(
    () => LanguageSupabaseDataSource(
      sl<EdgeFunctionClient>(),
      sl<LoggerInterface>(),
    ),
  );

  // Repositories
  sl.registerLazySingleton<LanguageRepository>(
    () => LanguageRepositoryImpl(
      sl<LanguageDataSource>(),
      sl<LoggerInterface>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(
    () => GetLanguagesUseCase(sl<LanguageRepository>()),
  );
  
  sl.registerLazySingleton(
    () => GetUserLanguagesUseCase(sl<LanguageRepository>()),
  );
  
  sl.registerLazySingleton(
    () => SaveUserLanguagesUseCase(sl<LanguageRepository>()),
  );

  // BLoCs
  sl.registerFactory(
    () => LanguageBloc(
      getLanguagesUseCase: sl<GetLanguagesUseCase>(),
      getUserLanguagesUseCase: sl<GetUserLanguagesUseCase>(),
      saveUserLanguagesUseCase: sl<SaveUserLanguagesUseCase>(),
      logger: sl<LoggerInterface>(),
    ),
  );
}
