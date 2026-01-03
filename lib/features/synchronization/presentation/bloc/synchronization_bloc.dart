import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/features/synchronization/domain/use_cases/get_synchronizations_use_case.dart';
import 'package:photo_manager_app/features/synchronization/presentation/bloc/synchronization_event.dart';
import 'package:photo_manager_app/features/synchronization/presentation/bloc/synchronization_state.dart';

import '../../../../core/errors/base/failures.dart';
import '../../../../core/errors/handler/error_handler.dart';
import '../../../sync_session/domain/repositories/sync_device_repository.dart';


class SynchronizationBloc extends Bloc<SynchronizationEvent, SynchronizationState> {

  final GetSynchronizationsUseCase getSynchronizationsUseCase;
  final SyncDeviceRepository syncDeviceRepository;

  String _deviceUuid = '';

  SynchronizationBloc({
    required this.getSynchronizationsUseCase,
    required this.syncDeviceRepository
  }) : super(const SynchronizationStarting()) {
    on<LoadSynchronizations>(_onLoadSynchronizations);
    on<LoadMoreSynchronizations>(_onLoadMoreSynchronizations);
    on<RefreshSynchronizations>(_onRefreshSynchronizations);
  }

  Future<void> _onLoadSynchronizations(LoadSynchronizations event, Emitter<SynchronizationState> emit) async {

    _deviceUuid = await syncDeviceRepository.getDeviceUuid();
    emit(const SynchronizationsLoading());

    try {

      final result = await getSynchronizationsUseCase(deviceUuid: _deviceUuid, page: 0);
      emit(SynchronizationsLoaded(sessions: result.sessions, hasMore: result.hasNext, currentPage: 0));

    } catch(e) {
      Failure failure = ErrorHandler.handleError(e);
      emit(SynchronizationError(failure));
    }
  }

  Future<void> _onLoadMoreSynchronizations(LoadMoreSynchronizations event, Emitter<SynchronizationState> emit) async {

    final currentState = state;
    if (currentState is! SynchronizationsLoaded) return;
    if (!currentState.hasMore) return;
    if (currentState.isLoadingMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    try {

      final nextPage = currentState.currentPage + 1;
      final result = await getSynchronizationsUseCase(deviceUuid: _deviceUuid, page: nextPage);

      final allSessions = [...currentState.sessions, ...result.sessions];

      emit(SynchronizationsLoaded(sessions: allSessions, hasMore: result.hasNext,
          currentPage: nextPage, isLoadingMore: false));

    } catch(e) {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _onRefreshSynchronizations(RefreshSynchronizations event, Emitter<SynchronizationState> emit) async {

    try {
      final result = await getSynchronizationsUseCase(deviceUuid: _deviceUuid, page: 0);
      emit(SynchronizationsLoaded(sessions: result.sessions, hasMore: result.hasNext, currentPage: 0));
    } catch(e) {
      Failure failure = ErrorHandler.handleError(e);
      emit(SynchronizationError(failure));
    }
  }
}