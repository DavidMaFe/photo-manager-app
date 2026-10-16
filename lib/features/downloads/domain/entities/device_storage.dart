import 'package:equatable/equatable.dart';

/// Free and total space of the shared storage of the device.
class DeviceStorage extends Equatable {
  final int freeBytes;
  final int totalBytes;

  const DeviceStorage({required this.freeBytes, required this.totalBytes});

  @override
  List<Object?> get props => [freeBytes, totalBytes];
}
