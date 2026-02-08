import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/features/devices/domain/entities/device.dart';

abstract class DeviceState {}

class DeviceInitial extends DeviceState {}

class DeviceLoading extends DeviceState {}

class DeviceLoaded extends DeviceState {
  final List<Device> devices;

  DeviceLoaded(this.devices);
}

class DeviceError extends DeviceState {
  final Failure failure;

  DeviceError(this.failure);
}

class DeviceActionInProgress extends DeviceState {
  final List<Device> devices;
  final String actionDeviceId;

  DeviceActionInProgress({
    required this.devices,
    required this.actionDeviceId,
  });
}

class DeviceActionSuccess extends DeviceState {
  final List<Device> devices;

  DeviceActionSuccess(this.devices);
}
