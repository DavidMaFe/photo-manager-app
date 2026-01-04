import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/core/events/app_event_bus.dart';
import 'package:photo_manager_app/core/events/app_events.dart';
import 'package:photo_manager_app/features/synchronization/domain/use_cases/get_synchronizations_use_case.dart';
import 'package:photo_manager_app/features/synchronization/presentation/bloc/synchronization_event.dart';
import 'package:photo_manager_app/features/synchronization/presentation/bloc/synchronization_state.dart';

import '../../../../core/errors/base/failures.dart';
import '../../../../core/errors/handler/error_handler.dart';
import '../../../sync_session/domain/repositories/sync_device_repository.dart';


class SynchronizationBloc extends Bloc<SynchronizationEvent, SynchronizationState> {

  final GetSynchronizationsUseCase getSynchronizationsUseCase;
  final SyncDeviceRepository syncDeviceRepository;
  final AppEventBus eventBus;

  String _deviceUuid = '';
  StreamSubscription<SyncCompletedEvent>? _syncCompletedSubscription;

  SynchronizationBloc({
    required this.getSynchronizationsUseCase,
    required this.syncDeviceRepository,
    required this.eventBus,
  }) : super(const SynchronizationStarting()) {
    on<LoadSynchronizations>(_onLoadSynchronizations);
    on<LoadMoreSynchronizations>(_onLoadMoreSynchronizations);
    on<RefreshSynchronizations>(_onRefreshSynchronizations);

    // Listen to sync completion events and auto-refresh the sync history list
    _syncCompletedSubscription = eventBus.on<SyncCompletedEvent>().listen((_) {
      add(const RefreshSynchronizations());
    });
  }

  @override
  Future<void> close() {
    _syncCompletedSubscription?.cancel();
    return super.close();
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