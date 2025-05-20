import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_recommended_immi_groves_usecase.dart';
import '../../../domain/usecases/join_immi_grove_usecase.dart';
import '../../../domain/usecases/leave_immi_grove_usecase.dart';
import '../../../domain/usecases/get_joined_immi_groves_usecase.dart';
import '../../../domain/usecases/save_selected_immi_groves_usecase.dart';
import 'immi_grove_event.dart';
import 'immi_grove_state.dart';

/// BLoC for ImmiGrove operations
class ImmiGroveBloc extends Bloc<ImmiGroveEvent, ImmiGroveState> {
  final GetRecommendedImmiGrovesUseCase _getRecommendedImmiGrovesUseCase;
  final JoinImmiGroveUseCase _joinImmiGroveUseCase;
  final LeaveImmiGroveUseCase _leaveImmiGroveUseCase;
  final GetJoinedImmiGrovesUseCase _getJoinedImmiGrovesUseCase;
  final SaveSelectedImmiGrovesUseCase _saveSelectedImmiGrovesUseCase;

  /// Creates a new ImmiGroveBloc
  ImmiGroveBloc({
    required GetRecommendedImmiGrovesUseCase getRecommendedImmiGrovesUseCase,
    required JoinImmiGroveUseCase joinImmiGroveUseCase,
    required LeaveImmiGroveUseCase leaveImmiGroveUseCase,
    required GetJoinedImmiGrovesUseCase getJoinedImmiGrovesUseCase,
    required SaveSelectedImmiGrovesUseCase saveSelectedImmiGrovesUseCase,
  })  : _getRecommendedImmiGrovesUseCase = getRecommendedImmiGrovesUseCase,
        _joinImmiGroveUseCase = joinImmiGroveUseCase,
        _leaveImmiGroveUseCase = leaveImmiGroveUseCase,
        _getJoinedImmiGrovesUseCase = getJoinedImmiGrovesUseCase,
        _saveSelectedImmiGrovesUseCase = saveSelectedImmiGrovesUseCase,
        super(const ImmiGroveState()) {
    on<LoadRecommendedImmiGroves>(_onLoadRecommendedImmiGroves);
    on<JoinImmiGrove>(_onJoinImmiGrove);
    on<LeaveImmiGrove>(_onLeaveImmiGrove);
    on<LoadJoinedImmiGroves>(_onLoadJoinedImmiGroves);
    on<RefreshImmiGroves>(_onRefreshImmiGroves);
    on<SaveSelectedImmiGroves>(_onSaveSelectedImmiGroves);
    on<ImmiGrovesPreselected>(_onImmiGrovesPreselected);
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
    try {
      // Update local state immediately for responsive UI
      final updatedSelectedIds = Set<String>.from(state.selectedImmiGroveIds)
        ..add(event.immiGroveId);
      
      emit(state.copyWith(
        selectedImmiGroveIds: updatedSelectedIds,
      ));
      
      // Call the use case to join the ImmiGrove
      await _joinImmiGroveUseCase(event.immiGroveId);
    } catch (e) {
      emit(state.copyWith(
        status: ImmiGroveStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Handle the LeaveImmiGrove event
  Future<void> _onLeaveImmiGrove(
    LeaveImmiGrove event,
    Emitter<ImmiGroveState> emit,
  ) async {
    try {
      // Update local state immediately for responsive UI
      final updatedSelectedIds = Set<String>.from(state.selectedImmiGroveIds)
        ..remove(event.immiGroveId);
      
      emit(state.copyWith(
        selectedImmiGroveIds: updatedSelectedIds,
      ));
      
      // Call the use case to leave the ImmiGrove
      await _leaveImmiGroveUseCase(event.immiGroveId);
    } catch (e) {
      emit(state.copyWith(
        status: ImmiGroveStatus.error,
        errorMessage: e.toString(),
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
      
      // Extract the IDs of joined ImmiGroves
      final joinedIds = immiGroves.map((grove) => grove.id).toSet();
      
      emit(state.copyWith(
        status: ImmiGroveStatus.loaded,
        joinedImmiGroves: immiGroves,
        selectedImmiGroveIds: joinedIds,
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
    // Load both recommended and joined ImmiGroves
    add(const LoadRecommendedImmiGroves());
    add(const LoadJoinedImmiGroves());
  }

  /// Handle the SaveSelectedImmiGroves event
  Future<void> _onSaveSelectedImmiGroves(
    SaveSelectedImmiGroves event,
    Emitter<ImmiGroveState> emit,
  ) async {
    emit(state.copyWith(
      status: ImmiGroveStatus.saving,
      isLoading: true,
    ));

    try {
      await _saveSelectedImmiGrovesUseCase(event.immiGroveIds);
      
      emit(state.copyWith(
        status: ImmiGroveStatus.saved,
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
  
  /// Handle the ImmiGrovesPreselected event
  void _onImmiGrovesPreselected(
    ImmiGrovesPreselected event,
    Emitter<ImmiGroveState> emit,
  ) {
    emit(state.copyWith(
      selectedImmiGroveIds: event.immiGroveIds,
    ));
  }
}
