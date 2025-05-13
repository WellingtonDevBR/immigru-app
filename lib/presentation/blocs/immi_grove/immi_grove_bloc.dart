import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/domain/usecases/immi_grove_usecases.dart';
import 'package:immigru/presentation/blocs/immi_grove/immi_grove_event.dart';
import 'package:immigru/presentation/blocs/immi_grove/immi_grove_state.dart';

/// BLoC for ImmiGrove operations
class ImmiGroveBloc extends Bloc<ImmiGroveEvent, ImmiGroveState> {
  final GetRecommendedImmiGrovesUseCase _getRecommendedImmiGrovesUseCase;
  final JoinImmiGroveUseCase _joinImmiGroveUseCase;
  final LeaveImmiGroveUseCase _leaveImmiGroveUseCase;
  final GetJoinedImmiGrovesUseCase _getJoinedImmiGrovesUseCase;

  ImmiGroveBloc({
    required GetRecommendedImmiGrovesUseCase getRecommendedImmiGrovesUseCase,
    required JoinImmiGroveUseCase joinImmiGroveUseCase,
    required LeaveImmiGroveUseCase leaveImmiGroveUseCase,
    required GetJoinedImmiGrovesUseCase getJoinedImmiGrovesUseCase,
  })  : _getRecommendedImmiGrovesUseCase = getRecommendedImmiGrovesUseCase,
        _joinImmiGroveUseCase = joinImmiGroveUseCase,
        _leaveImmiGroveUseCase = leaveImmiGroveUseCase,
        _getJoinedImmiGrovesUseCase = getJoinedImmiGrovesUseCase,
        super(const ImmiGroveState()) {
    on<LoadRecommendedImmiGroves>(_onLoadRecommendedImmiGroves);
    on<JoinImmiGrove>(_onJoinImmiGrove);
    on<LeaveImmiGrove>(_onLeaveImmiGrove);
    on<LoadJoinedImmiGroves>(_onLoadJoinedImmiGroves);
    on<RefreshImmiGroves>(_onRefreshImmiGroves);
  }

  /// Handle the LoadRecommendedImmiGroves event
  Future<void> _onLoadRecommendedImmiGroves(
    LoadRecommendedImmiGroves event,
    Emitter<ImmiGroveState> emit,
  ) async {
    emit(state.copyWith(
      status: ImmiGroveStatus.loading,
      isLoading: true,
    ));

    try {
      final immiGroves = await _getRecommendedImmiGrovesUseCase(limit: event.limit);
      emit(state.copyWith(
        status: ImmiGroveStatus.loaded,
        recommendedImmiGroves: immiGroves,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ImmiGroveStatus.error,
        errorMessage: e.toString(),
        isLoading: false,
      ));
    }
  }

  /// Handle the JoinImmiGrove event
  Future<void> _onJoinImmiGrove(
    JoinImmiGrove event,
    Emitter<ImmiGroveState> emit,
  ) async {
    emit(state.copyWith(
      status: ImmiGroveStatus.joining,
      isLoading: true,
    ));

    try {
      await _joinImmiGroveUseCase(event.immiGroveId);
      
      // Update the joined ImmiGroves list
      final joinedImmiGroves = await _getJoinedImmiGrovesUseCase();
      
      emit(state.copyWith(
        status: ImmiGroveStatus.joined,
        joinedImmiGroves: joinedImmiGroves,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ImmiGroveStatus.error,
        errorMessage: e.toString(),
        isLoading: false,
      ));
    }
  }

  /// Handle the LeaveImmiGrove event
  Future<void> _onLeaveImmiGrove(
    LeaveImmiGrove event,
    Emitter<ImmiGroveState> emit,
  ) async {
    emit(state.copyWith(
      status: ImmiGroveStatus.leaving,
      isLoading: true,
    ));

    try {
      await _leaveImmiGroveUseCase(event.immiGroveId);
      
      // Update the joined ImmiGroves list
      final joinedImmiGroves = await _getJoinedImmiGrovesUseCase();
      
      emit(state.copyWith(
        status: ImmiGroveStatus.left,
        joinedImmiGroves: joinedImmiGroves,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ImmiGroveStatus.error,
        errorMessage: e.toString(),
        isLoading: false,
      ));
    }
  }

  /// Handle the LoadJoinedImmiGroves event
  Future<void> _onLoadJoinedImmiGroves(
    LoadJoinedImmiGroves event,
    Emitter<ImmiGroveState> emit,
  ) async {
    emit(state.copyWith(
      status: ImmiGroveStatus.loading,
      isLoading: true,
    ));

    try {
      final immiGroves = await _getJoinedImmiGrovesUseCase();
      emit(state.copyWith(
        status: ImmiGroveStatus.loaded,
        joinedImmiGroves: immiGroves,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ImmiGroveStatus.error,
        errorMessage: e.toString(),
        isLoading: false,
      ));
    }
  }

  /// Handle the RefreshImmiGroves event
  Future<void> _onRefreshImmiGroves(
    RefreshImmiGroves event,
    Emitter<ImmiGroveState> emit,
  ) async {
    emit(state.copyWith(
      status: ImmiGroveStatus.loading,
      isLoading: true,
    ));

    try {
      // Load both recommended and joined ImmiGroves
      final recommendedFuture = _getRecommendedImmiGrovesUseCase();
      final joinedFuture = _getJoinedImmiGrovesUseCase();
      
      final recommended = await recommendedFuture;
      final joined = await joinedFuture;
      
      emit(state.copyWith(
        status: ImmiGroveStatus.loaded,
        recommendedImmiGroves: recommended,
        joinedImmiGroves: joined,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ImmiGroveStatus.error,
        errorMessage: e.toString(),
        isLoading: false,
      ));
    }
  }
}
