import 'package:get_it/get_it.dart';
import 'package:immigru/features/welcome/presentation/bloc/welcome_bloc.dart';
import 'package:immigru/new_core/logging/logger_provider.dart';
import 'package:immigru/shared/interfaces/logger_interface.dart';

/// Welcome module for dependency injection
/// Registers all welcome feature dependencies
class WelcomeModule {
  /// Register all welcome dependencies
  static Future<void> register(GetIt sl) async {
    // Register feature-specific logger
    if (!sl.isRegistered<LoggerInterface>(instanceName: 'welcome_logger')) {
      sl.registerFactory<LoggerInterface>(
        () => sl<LoggerProvider>().createFeatureLogger('Welcome'),
        instanceName: 'welcome_logger',
      );
    }
    
    // Register BLoCs
    sl.registerFactory<WelcomeBloc>(
      () => WelcomeBloc(
        logger: sl.get<LoggerInterface>(instanceName: 'welcome_logger'),
      ),
    );
  }
}
