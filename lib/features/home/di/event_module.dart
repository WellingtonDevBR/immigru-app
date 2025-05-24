import 'package:get_it/get_it.dart';
import 'package:immigru/core/logging/unified_logger.dart';
import 'package:immigru/features/home/data/datasources/event_data_source_impl.dart';
import 'package:immigru/features/home/data/repositories/event_repository_impl.dart';
import 'package:immigru/features/home/domain/repositories/event_repository.dart';
import 'package:immigru/features/home/domain/usecases/get_events_usecase.dart';
import 'package:immigru/features/home/domain/usecases/register_for_event_usecase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Module for event-related dependencies
class EventModule {
  /// Register all event-related dependencies
  static void register(GetIt locator) {
    // Data sources
    locator.registerLazySingleton<EventDataSource>(
      () => EventDataSourceImpl(
        supabase: Supabase.instance.client,
      ),
    );

    // Repositories
    locator.registerLazySingleton<EventRepository>(
      () => EventRepositoryImpl(
        eventDataSource: locator<EventDataSource>(),
        logger: locator<UnifiedLogger>(),
      ),
    );

    // Use cases
    locator.registerLazySingleton<GetEventsUseCase>(
      () => GetEventsUseCase(locator<EventRepository>()),
    );

    locator.registerLazySingleton<RegisterForEventUseCase>(
      () => RegisterForEventUseCase(locator<EventRepository>()),
    );
  }
}
