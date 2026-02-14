import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/core/errors/handler/error_handler.dart';
import 'package:photo_manager_app/core/services/sync_scheduler_service.dart';
import 'package:photo_manager_app/features/sync_config/domain/entities/sync_config.dart';
import 'package:photo_manager_app/features/sync_config/domain/use_cases/get_sync_config_use_case.dart';
import 'package:photo_manager_app/features/sync_config/domain/use_cases/save_sync_config_use_case.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_event.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_state.dart';

class SyncConfigBloc extends Bloc<SyncConfigEvent, SyncConfigState> {
  final GetSyncConfigUseCase getSyncConfigUseCase;
  final SaveSyncConfigUseCase saveSyncConfigUseCase;
  final SyncSchedulerService syncSchedulerService;

  static const int minimumLoadingDuration = 800;

  /// Current configuration being edited
  SyncConfig? _currentConfig;

  SyncConfigBloc({
    required this.getSyncConfigUseCase,
    required this.saveSyncConfigUseCase,
    required this.syncSchedulerService,
  }) : super(SyncConfigInitial()) {
    on<LoadSyncConfig>(_onLoadSyncConfig);
    on<SaveSyncConfig>(_onSaveSyncConfig);
    on<ToggleAutoSync>(_onToggleAutoSync);
    on<UpdateSyncFrequency>(_onUpdateSyncFrequency);
    on<UpdateSyncTime>(_onUpdateSyncTime);
    on<UpdateSyncDayOfWeek>(_onUpdateSyncDayOfWeek);
    on<UpdateNetworkPreference>(_onUpdateNetworkPreference);
    on<UpdateBatteryPreference>(_onUpdateBatteryPreference);
    on<ToggleNotifyOnSuccess>(_onToggleNotifyOnSuccess);
    on<ToggleNotifyOnFailure>(_onToggleNotifyOnFailure);
  }

  Future<void> _onLoadSyncConfig(
    LoadSyncConfig event,
    Emitter<SyncConfigState> emit,
  ) async {
    emit(SyncConfigLoading());
    final stopwatch = Stopwatch()..start();

    try {
      final config = await getSyncConfigUseCase();
      _currentConfig = config;

      await _waitForLoading(stopwatch);
      emit(SyncConfigLoaded(config));
    } catch (e) {
      await _waitForLoading(stopwatch);
      final failure = ErrorHandler.handleError(e);
      emit(SyncConfigError(failure));
    }
  }

  Future<void> _onSaveSyncConfig(
    SaveSyncConfig event,
    Emitter<SyncConfigState> emit,
  ) async {
    if (_currentConfig == null) {
      final failure = ErrorHandler.handleError(
        Exception('No configuration to save'),
      );
      emit(SyncConfigError(failure, currentConfig: _currentConfig));
      return;
    }

    emit(SyncConfigSaving(_currentConfig!));
    final stopwatch = Stopwatch()..start();

    try {
      await saveSyncConfigUseCase(_currentConfig!);

      // Reschedule sync with new configuration
      await syncSchedulerService.rescheduleSync(_currentConfig!);

      await _waitForLoading(stopwatch);
      emit(SyncConfigSaved(_currentConfig!));
    } catch (e) {
      await _waitForLoading(stopwatch);
      final failure = ErrorHandler.handleError(e);
      emit(SyncConfigError(failure, currentConfig: _currentConfig));
    }
  }

  void _onToggleAutoSync(
    ToggleAutoSync event,
    Emitter<SyncConfigState> emit,
  ) {
    if (_currentConfig != null) {
      _currentConfig = _currentConfig!.copyWith(
        autoSyncEnabled: event.enabled,
      );
      emit(SyncConfigLoaded(_currentConfig!));
    }
  }

  void _onUpdateSyncFrequency(
    UpdateSyncFrequency event,
    Emitter<SyncConfigState> emit,
  ) {
    if (_currentConfig != null) {
      // When switching to daily, clear day of week
      // When switching to weekly, set default day if not already set
      final newDayOfWeek = event.frequency.isWeekly && _currentConfig!.syncDayOfWeek == null
          ? 1
          : _currentConfig!.syncDayOfWeek;

      _currentConfig = _currentConfig!.copyWith(
        syncFrequency: event.frequency,
        syncDayOfWeek: newDayOfWeek,
        clearDayOfWeek: event.frequency.isDaily,
      );
      emit(SyncConfigLoaded(_currentConfig!));
    }
  }

  void _onUpdateSyncTime(
    UpdateSyncTime event,
    Emitter<SyncConfigState> emit,
  ) {
    if (_currentConfig != null) {
      _currentConfig = _currentConfig!.copyWith(
        syncHour: event.time.hour,
        syncMinute: event.time.minute,
      );
      emit(SyncConfigLoaded(_currentConfig!));
    }
  }

  void _onUpdateSyncDayOfWeek(
    UpdateSyncDayOfWeek event,
    Emitter<SyncConfigState> emit,
  ) {
    if (_currentConfig != null) {
      _currentConfig = _currentConfig!.copyWith(
        syncDayOfWeek: event.dayOfWeek,
      );
      emit(SyncConfigLoaded(_currentConfig!));
    }
  }

  void _onUpdateNetworkPreference(
    UpdateNetworkPreference event,
    Emitter<SyncConfigState> emit,
  ) {
    if (_currentConfig != null) {
      _currentConfig = _currentConfig!.copyWith(
        networkPreference: event.preference,
      );
      emit(SyncConfigLoaded(_currentConfig!));
    }
  }

  void _onUpdateBatteryPreference(
    UpdateBatteryPreference event,
    Emitter<SyncConfigState> emit,
  ) {
    if (_currentConfig != null) {
      _currentConfig = _currentConfig!.copyWith(
        batteryPreference: event.preference,
      );
      emit(SyncConfigLoaded(_currentConfig!));
    }
  }

  void _onToggleNotifyOnSuccess(
    ToggleNotifyOnSuccess event,
    Emitter<SyncConfigState> emit,
  ) {
    if (_currentConfig != null) {
      _currentConfig = _currentConfig!.copyWith(
        notifyOnSuccess: event.enabled,
      );
      emit(SyncConfigLoaded(_currentConfig!));
    }
  }

  void _onToggleNotifyOnFailure(
    ToggleNotifyOnFailure event,
    Emitter<SyncConfigState> emit,
  ) {
    if (_currentConfig != null) {
      _currentConfig = _currentConfig!.copyWith(
        notifyOnFailure: event.enabled,
      );
      emit(SyncConfigLoaded(_currentConfig!));
    }
  }

  Future<void> _waitForLoading(Stopwatch stopwatch) async {
    stopwatch.stop();
    final elapsed = stopwatch.elapsedMilliseconds;
    final remaining = minimumLoadingDuration - elapsed;

    if (remaining > 0) {
      await Future.delayed(Duration(milliseconds: remaining));
    }
  }
}
