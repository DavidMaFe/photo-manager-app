import 'package:equatable/equatable.dart';


abstract class SyncSessionEvent extends Equatable {
  const SyncSessionEvent();

  @override
  List<Object?> get props => [];
}


class SyncSessionStarted extends SyncSessionEvent {
  const SyncSessionStarted();
}


class SyncSessionCancelled extends SyncSessionEvent {
  const SyncSessionCancelled();
}


class SyncSessionRetried extends SyncSessionEvent {
  const SyncSessionRetried();
}


class SyncSessionReset extends SyncSessionEvent {
  const SyncSessionReset();
}