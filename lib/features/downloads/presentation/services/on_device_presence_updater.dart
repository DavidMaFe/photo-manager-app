import 'dart:async';

import 'package:photo_manager_app/core/events/app_event_bus.dart';
import 'package:photo_manager_app/core/events/app_events.dart';
import 'package:photo_manager_app/features/downloads/domain/services/on_device_presence.dart';

/// Keeps [OnDevicePresence] up to date with what happens in the app: files uploaded by a sync, moved to the trash,
/// restored, deleted or freed up from this device (FileUpdatedEvent). Each event computes it again (three lists of
/// ids, about 25 ms plus the request); events close in time share the same computation.
class OnDevicePresenceUpdater {
  final OnDevicePresence _presence;
  final AppEventBus _eventBus;
  final List<StreamSubscription<AppEvent>> _subscriptions = [];

  OnDevicePresenceUpdater(this._presence, this._eventBus);

  /// Listens to the events and computes it now (after the login, or when the app opens with a session).
  void start() {
    if (_subscriptions.isEmpty) {
      _subscriptions
        ..add(_eventBus.on<SyncCompletedEvent>().listen((_) => refresh()))
        ..add(_eventBus.on<FileUpdatedEvent>().listen((_) => refresh()));
    }
    refresh();
  }

  /// Computes it again; a failure (no network) keeps the last known state.
  Future<void> refresh() async {
    try {
      await _presence.refresh();
    } catch (_) {
      // Tried again with the next event or when the app comes back
    }
  }

  Future<void> stop() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
  }
}
