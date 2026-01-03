import 'package:equatable/equatable.dart';


abstract class SynchronizationEvent extends Equatable {
  const SynchronizationEvent();

  @override
  List<Object?> get props => [];
}


class LoadSynchronizations extends SynchronizationEvent {
  const LoadSynchronizations();

  @override
  List<Object?> get props => [];
}


class LoadMoreSynchronizations extends SynchronizationEvent {
  const LoadMoreSynchronizations();
}


class RefreshSynchronizations extends SynchronizationEvent {
  const RefreshSynchronizations();
}