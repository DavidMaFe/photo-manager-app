import 'package:equatable/equatable.dart';


abstract class SyncSessionEvent extends Equatable {
  const SyncSessionEvent();

  @override
  List<Object?> get props => [];
}


class SyncSessionStarted extends SyncSessionEvent {
  const SyncSessionStarted();

  @override
  String toString() => 'SyncSessionStarted';
}


class SyncSessionCancelled extends SyncSessionEvent {
  const SyncSessionCancelled();

  @override
  String toString() => 'SyncSessionCancelled';
}


class SyncSessionRetried extends SyncSessionEvent {
  const SyncSessionRetried();

  @override
  String toString() => 'SyncSessionRetried';
}