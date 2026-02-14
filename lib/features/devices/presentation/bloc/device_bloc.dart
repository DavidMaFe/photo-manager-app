import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/core/errors/handler/error_handler.dart';
import 'package:photo_manager_app/core/events/app_event_bus.dart';
import 'package:photo_manager_app/core/events/app_events.dart';
import 'package:photo_manager_app/core/services/sync_scheduler_service.dart';
import 'package:photo_manager_app/features/devices/domain/use_cases/get_user_devices_use_case.dart';
import 'package:photo_manager_app/features/devices/domain/use_cases/rename_device_use_case.dart';
import 'package:photo_manager_app/features/devices/domain/use_cases/toggle_auto_sync_use_case.dart';
import 'package:photo_manager_app/features/devices/domain/use_cases/unlink_device_use_case.dart';
import 'package:photo_manager_app/features/devices/presentation/bloc/device_event.dart';
import 'package:photo_manager_app/features/devices/presentation/bloc/device_state.dart';
import 'package:photo_manager_app/features/sync_config/domain/repositories/sync_config_repository.dart';

class DeviceBloc extends Bloc<DeviceEvent, DeviceState> {
  final GetUserDevicesUseCase getUserDevicesUseCase;
  final RenameDeviceUseCase renameDeviceUseCase;
  final ToggleAutoSyncUseCase toggleAutoSyncUseCase;
  final UnlinkDeviceUseCase unlinkDeviceUseCase;
  final AppEventBus eventBus;
  final SyncSchedulerService syncSchedulerService;
  final SyncConfigRepository syncConfigRepository;

  static const int minimumLoadingDuration = 800;

  StreamSubscription<DeviceUpdatedEvent>? _deviceUpdateSubscription;

  DeviceBloc({
    required this.getUserDevicesUseCase,
    required this.renameDeviceUseCase,
    required this.toggleAutoSyncUseCase,
    required this.unlinkDeviceUseCase,
    required this.eventBus,
    required this.syncSchedulerService,
    required this.syncConfigRepository,
  }) : super(DeviceInitial()) {
    on<LoadDevices>(_onLoadDevices);
    on<RefreshDevices>(_onRefreshDevices);
    on<RenameDevice>(_onRenameDevice);
    on<ToggleAutoSync>(_onToggleAutoSync);
    on<UnlinkDevice>(_onUnlinkDevice);

    // Listen to device updates from other parts of the app
    _deviceUpdateSubscription = eventBus.on<DeviceUpdatedEvent>().listen((_) {
      add(RefreshDevices());
    });
  }

  @override
  Future<void> close() {
    _deviceUpdateSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadDevices(
      LoadDevices event, Emitter<DeviceState> emit) async {
    emit(DeviceLoading());

    final stopwatch = Stopwatch()..start();

    try {
      final devices = await getUserDevicesUseCase();
      await _waitForLoading(stopwatch);
      emit(DeviceLoaded(devices));
    } catch (e) {
      await _waitForLoading(stopwatch);
      final failure = ErrorHandler.handleError(e);
      emit(DeviceError(failure));
    }
  }

  Future<void> _onRefreshDevices(
      RefreshDevices event, Emitter<DeviceState> emit) async {
    try {
      final devices = await getUserDevicesUseCase();
      emit(DeviceLoaded(devices));
    } catch (e) {
      final failure = ErrorHandler.handleError(e);
      emit(DeviceError(failure));
    }
  }

  Future<void> _onRenameDevice(
      RenameDevice event, Emitter<DeviceState> emit) async {
    // Get current devices from state
    final currentState = state;
    if (currentState is! DeviceLoaded) return;

    emit(DeviceActionInProgress(
      devices: currentState.devices,
      actionDeviceId: event.deviceId,
    ));

    final stopwatch = Stopwatch()..start();

    try {
      await renameDeviceUseCase(
        deviceId: event.deviceId,
        newName: event.newName,
      );

      // Reload devices to get updated data
      final devices = await getUserDevicesUseCase();
      await _waitForLoading(stopwatch);

      emit(DeviceActionSuccess(devices));
      emit(DeviceLoaded(devices));

      // Fire event bus notification
      eventBus.fire(const DeviceUpdatedEvent(
        updateType: DeviceUpdateType.renamed,
      ));
    } catch (e) {
      await _waitForLoading(stopwatch);
      final failure = ErrorHandler.handleError(e);
      emit(DeviceError(failure));
      // Restore previous state
      emit(DeviceLoaded(currentState.devices));
    }
  }

  Future<void> _onToggleAutoSync(
      ToggleAutoSync event, Emitter<DeviceState> emit) async {
    // Get current devices from state
    final currentState = state;
    if (currentState is! DeviceLoaded) return;

    emit(DeviceActionInProgress(
      devices: currentState.devices,
      actionDeviceId: event.deviceId,
    ));

    final stopwatch = Stopwatch()..start();

    try {
      // Toggle auto-sync on the server
      await toggleAutoSyncUseCase(
        deviceId: event.deviceId,
        enabled: event.enabled,
      );

      // Update the device in the list with new autoSync value
      final updatedDevices = currentState.devices.map((device) {
        if (device.id == event.deviceId) {
          return device.copyWith(autoSync: event.enabled);
        }
        return device;
      }).toList();

      await _waitForLoading(stopwatch);

      if (event.enabled) {
        // Auto-sync enabled: emit state to trigger navigation to sync configuration
        developer.log(
          '✅ Auto-sync enabled, navigating to sync configuration',
          name: 'DeviceBloc',
        );
        emit(DeviceAutoSyncEnabled(
          devices: updatedDevices,
          deviceId: event.deviceId,
        ));
        // Then emit loaded state
        emit(DeviceLoaded(updatedDevices));
      } else {
        // Auto-sync disabled: cancel scheduled tasks
        developer.log(
          '❌ Auto-sync disabled, canceling scheduled tasks',
          name: 'DeviceBloc',
        );

        try {
          await syncSchedulerService.cancelSync();

          // Clear sync configuration
          final currentConfig = await syncConfigRepository.getSyncConfig();
          if (currentConfig != null) {
            final disabledConfig = currentConfig.copyWith(autoSyncEnabled: false);
            await syncConfigRepository.saveSyncConfig(disabledConfig);
          }

          developer.log('✅ Sync tasks cancelled and config cleared', name: 'DeviceBloc');
        } catch (e) {
          developer.log(
            '⚠️ Failed to cancel sync tasks',
            name: 'DeviceBloc',
            error: e,
          );
          // Don't fail the whole operation if cleanup fails
        }

        emit(DeviceActionSuccess(updatedDevices));
        emit(DeviceLoaded(updatedDevices));
      }

      // Fire event bus notification
      eventBus.fire(const DeviceUpdatedEvent(
        updateType: DeviceUpdateType.autoSyncToggled,
      ));
    } catch (e) {
      await _waitForLoading(stopwatch);
      final failure = ErrorHandler.handleError(e);
      emit(DeviceError(failure));
      // Restore previous state
      emit(DeviceLoaded(currentState.devices));
    }
  }

  Future<void> _onUnlinkDevice(
      UnlinkDevice event, Emitter<DeviceState> emit) async {
    // Get current devices from state
    final currentState = state;
    if (currentState is! DeviceLoaded) return;

    emit(DeviceActionInProgress(
      devices: currentState.devices,
      actionDeviceId: event.deviceId,
    ));

    final stopwatch = Stopwatch()..start();

    try {
      await unlinkDeviceUseCase(deviceId: event.deviceId);

      // Remove the device from the list
      final updatedDevices = currentState.devices
          .where((device) => device.id != event.deviceId)
          .toList();

      await _waitForLoading(stopwatch);

      emit(DeviceActionSuccess(updatedDevices));
      emit(DeviceLoaded(updatedDevices));

      // Fire event bus notification
      eventBus.fire(DeviceUpdatedEvent(
        affectedDeviceIds: [event.deviceId],
        updateType: DeviceUpdateType.unlinked,
      ));
    } catch (e) {
      await _waitForLoading(stopwatch);
      final failure = ErrorHandler.handleError(e);
      emit(DeviceError(failure));
      // Restore previous state
      emit(DeviceLoaded(currentState.devices));
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
