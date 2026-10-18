import 'package:equatable/equatable.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/remote_media_file.dart';

/// The files of the server split by whether this device has them in its gallery.
class MissingOnDevice extends Equatable {
  final List<RemoteMediaFile> missing;
  final List<RemoteMediaFile> onDevice;

  const MissingOnDevice({required this.missing, required this.onDevice});

  int get missingBytes => missing.fold(0, (total, file) => total + file.sizeBytes);

  @override
  List<Object?> get props => [missing, onDevice];
}
