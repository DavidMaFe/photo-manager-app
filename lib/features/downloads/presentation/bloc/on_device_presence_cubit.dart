import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/features/downloads/domain/services/on_device_presence.dart';

class OnDevicePresenceState extends Equatable {
  final bool known;

  /// Changes each time the set of missing files changes, so the widgets that read it rebuild.
  final int revision;
  final Set<String> _missing;

  /// Size of the files this phone is missing.
  final int missingBytes;

  const OnDevicePresenceState({
    this.known = false,
    this.revision = 0,
    Set<String> missing = const {},
    this.missingBytes = 0,
  }) : _missing = missing;

  /// Null while it is not known yet.
  bool? isOnDevice(String fileId) => known ? !_missing.contains(fileId) : null;

  int get missingCount => _missing.length;

  @override
  List<Object?> get props => [known, revision];
}

/// [OnDevicePresence] for the widgets: the ✓ of the thumbnails, the viewer and the selection header.
class OnDevicePresenceCubit extends Cubit<OnDevicePresenceState> {
  final OnDevicePresence _presence;
  StreamSubscription<void>? _subscription;

  OnDevicePresenceCubit(this._presence) : super(_stateOf(_presence, 0)) {
    _subscription = _presence.changes.listen((_) => emit(_stateOf(_presence, state.revision + 1)));
  }

  static OnDevicePresenceState _stateOf(OnDevicePresence presence, int revision) => OnDevicePresenceState(
        known: presence.isKnown,
        revision: revision,
        missing: {for (final file in presence.missing) file.id},
        missingBytes: presence.missing.fold(0, (total, file) => total + file.sizeBytes),
      );

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
