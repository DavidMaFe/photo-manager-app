import 'dart:async';
import 'app_events.dart';

/// Singleton event bus for broadcasting app-wide events
/// Allows different BLoCs to communicate without direct dependencies
class AppEventBus {
  static final AppEventBus _instance = AppEventBus._internal();
  factory AppEventBus() => _instance;
  AppEventBus._internal();

  final StreamController<AppEvent> _eventController =
      StreamController<AppEvent>.broadcast();

  /// Stream of all app events
  Stream<AppEvent> get events => _eventController.stream;

  /// Stream of specific event type
  Stream<T> on<T extends AppEvent>() {
    return _eventController.stream.where((event) => event is T).cast<T>();
  }

  /// Broadcast an event to all listeners
  void fire(AppEvent event) {
    if (!_eventController.isClosed) {
      _eventController.add(event);
    }
  }

  /// Close the event bus (typically called when app is disposed)
  void dispose() {
    _eventController.close();
  }
}