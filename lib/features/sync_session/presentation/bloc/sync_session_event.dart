import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';


abstract class SyncSessionEvent extends Equatable {
  const SyncSessionEvent();

  @override
  List<Object?> get props => [];
}


class SyncSessionStarted extends SyncSessionEvent {
  final BuildContext context;

  const SyncSessionStarted(this.context);

  @override
  List<Object?> get props => [context];
}


class SyncSessionCancelled extends SyncSessionEvent {
  const SyncSessionCancelled();
}


class SyncSessionRetried extends SyncSessionEvent {
  final BuildContext context;

  const SyncSessionRetried(this.context);

  @override
  List<Object?> get props => [context];
}


class SyncSessionReset extends SyncSessionEvent {
  const SyncSessionReset();
}