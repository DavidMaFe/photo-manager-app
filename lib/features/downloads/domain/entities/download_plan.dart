import 'package:equatable/equatable.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/device_storage.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/remote_media_file.dart';

/// What a download would save: the files the device is missing, those it already has (skipped) and whether they fit.
class DownloadPlan extends Equatable {
  /// Space left free after a download, so the phone never fills up.
  static const int reservedBytes = 500 * 1024 * 1024;

  final List<RemoteMediaFile> toDownload;
  final int alreadyOnDevice;
  final DeviceStorage storage;

  const DownloadPlan({required this.toDownload, required this.alreadyOnDevice, required this.storage});

  int get bytesToDownload => toDownload.fold(0, (total, file) => total + file.sizeBytes);

  bool get isEmpty => toDownload.isEmpty;

  bool get fits => bytesToDownload + reservedBytes <= storage.freeBytes;

  @override
  List<Object?> get props => [toDownload, alreadyOnDevice, storage];
}
