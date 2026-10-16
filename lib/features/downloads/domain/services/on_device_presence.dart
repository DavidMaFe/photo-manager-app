import 'dart:async';

import 'package:photo_manager_app/features/downloads/domain/entities/remote_media_file.dart';
import 'package:photo_manager_app/features/downloads/domain/use_cases/compute_missing_on_device_use_case.dart';

/// Which files of the account this device is missing, kept in memory for the whole app: the marks of the gallery,
/// the "Not on this phone" filter and the viewer read it without asking again. [refresh] computes it (when the app
/// starts or comes back, after a sync); downloads and "free up" update it file by file.
class OnDevicePresence {
  final ComputeMissingOnDeviceUseCase _computeMissing;
  final StreamController<void> _changes = StreamController<void>.broadcast();

  Map<String, RemoteMediaFile> _missing = {};
  bool _known = false;
  Future<void>? _refreshing;

  OnDevicePresence(this._computeMissing);

  /// Fired each time the set of missing files changes.
  Stream<void> get changes => _changes.stream;

  /// Whether it has been computed at least once.
  bool get isKnown => _known;

  /// The files this device is missing, newest first.
  List<RemoteMediaFile> get missing => List.unmodifiable(_missing.values);

  /// Null while it is not known yet. A file uploaded after the last [refresh] counts as on the device.
  bool? isOnDevice(String fileId) => _known ? !_missing.containsKey(fileId) : null;

  /// Computes it again; calls made while it runs wait for the same computation.
  Future<void> refresh() => _refreshing ??= _compute().whenComplete(() => _refreshing = null);

  Future<void> _compute() async {
    final result = await _computeMissing();
    _missing = {for (final file in result.missing) file.id: file};
    _known = true;
    _changes.add(null);
  }

  /// These files were saved into the gallery of this device.
  void markOnDevice(Iterable<String> fileIds) {
    var changed = false;
    for (final id in fileIds) {
      changed |= _missing.remove(id) != null;
    }
    if (changed) _changes.add(null);
  }

  /// These files left the gallery of this device (freed up).
  void markMissing(Iterable<RemoteMediaFile> files) {
    if (!_known) return;
    for (final file in files) {
      _missing[file.id] = file;
    }
    _changes.add(null);
  }

  /// Forgets everything (logout).
  void clear() {
    _missing = {};
    _known = false;
    _changes.add(null);
  }
}
