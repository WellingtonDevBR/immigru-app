import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/features/welcome/presentation/bloc/welcome_event.dart';
import 'package:immigru/features/welcome/presentation/bloc/welcome_state.dart';
import 'package:immigru/shared/interfaces/logger_interface.dart';

/// BLoC for managing welcome screen state
class WelcomeBloc extends Bloc<WelcomeEvent, WelcomeState> {
  final LoggerInterface _logger;

  /// Creates a new welcome BLoC
  WelcomeBloc({
    required LoggerInterface logger,
  }) : _logger = logger,
       super(WelcomeState.initial()) {
    on<WelcomeInitialized>(_onInitialized);
    on<WelcomeCompleted>(_onCompleted);
  }

  /// Handles the initialized event
  Future<void> _onInitialized(
    WelcomeInitialized event,
    Emitter<WelcomeState> emit,
  ) async {
    try {
      _logger.i('Welcome screen initialized', tag: 'WelcomeBloc');
      emit(state.copyWith(isAnimating: true));
    } catch (e, stackTrace) {
      _logger.e(
        'Error initializing welcome screen',
        tag: 'WelcomeBloc',
        error: e,
        stackTrace: stackTrace,
      );
      emit(state.copyWith(
        errorMessage: 'Failed to initialize welcome screen',
      ));
    }
  }

  /// Handles the completed event
  Future<void> _onCompleted(
    WelcomeCompleted event,
    Emitter<WelcomeState> emit,
  ) async {
    try {
      _logger.i('Welcome screen completed', tag: 'WelcomeBloc');
      emit(state.copyWith(hasBeenSeen: true));
    } catch (e, stackTrace) {
      _logger.e(
        'Error completing welcome screen',
        tag: 'WelcomeBloc',
        error: e,
        stackTrace: stackTrace,
      );
      emit(state.copyWith(
        errorMessage: 'Failed to complete welcome screen',
      ));
    }
  }
}
