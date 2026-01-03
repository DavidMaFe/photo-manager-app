import 'package:equatable/equatable.dart';
import 'package:photo_manager_app/features/synchronization/domain/entities/synchronization.dart';

import '../../../../core/errors/base/failures.dart';


abstract class SynchronizationState extends Equatable {
  const SynchronizationState();

  @override
  List<Object?> get props => [];
}


class SynchronizationStarting extends SynchronizationState {
  const SynchronizationStarting();
}


class SynchronizationsLoading extends SynchronizationState {
  const SynchronizationsLoading();
}


class SynchronizationsLoaded extends SynchronizationState {

  final List<Synchronization> sessions;
  final bool hasMore;
  final int currentPage;
  final bool isLoadingMore;

  const SynchronizationsLoaded({
    required this.sessions,
    required this.hasMore,
    required this.currentPage,
    this.isLoadingMore = false
  });

  @override
  List<Object?> get props => [sessions, hasMore, currentPage, isLoadingMore];

  SynchronizationsLoaded copyWith({
    List<Synchronization>? sessions,
    bool? hasMore,
    int? currentPage,
    bool? isLoadingMore
  }) {
    return SynchronizationsLoaded(
      sessions: sessions ?? this.sessions,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore
    );
  }
}


class SynchronizationError extends SynchronizationState {

  final Failure failure;
  const SynchronizationError(this.failure);

  @override
  List<Object?> get props => [failure];
}