import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/core/errors/handler/error_handler.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/download_plan.dart';
import 'package:photo_manager_app/features/downloads/domain/repositories/download_queue_repository.dart';
import 'package:photo_manager_app/features/downloads/domain/services/on_device_presence.dart';
import 'package:photo_manager_app/features/downloads/domain/use_cases/cancel_download_use_case.dart';
import 'package:photo_manager_app/features/downloads/domain/use_cases/plan_download_use_case.dart';
import 'package:photo_manager_app/features/downloads/domain/use_cases/start_download_use_case.dart';
import 'package:photo_manager_app/features/downloads/presentation/bloc/download_progress_event.dart';
import 'package:photo_manager_app/features/downloads/presentation/bloc/download_progress_state.dart';

/// Progress of the download to the gallery. The files are saved by a WorkManager task, in another isolate: this
/// bloc reads the shared queue every [pollInterval] while the download runs, marks the saved files as on the device
/// and estimates the time left from the speed so far.
class DownloadProgressBloc extends Bloc<DownloadProgressEvent, DownloadProgressState> {
  static const Duration pollInterval = Duration(seconds: 1);

  final DownloadQueueRepository _queue;
  final StartDownloadUseCase _startDownload;
  final CancelDownloadUseCase _cancelDownload;
  final PlanDownloadUseCase _planDownload;
  final OnDevicePresence _presence;
  final DateTime Function() _clock;

  Timer? _timer;
  final Set<String> _markedOnDevice = {};
  ({DateTime at, int bytes})? _firstSample;

  DownloadProgressBloc({
    required DownloadQueueRepository queue,
    required StartDownloadUseCase startDownload,
    required CancelDownloadUseCase cancelDownload,
    required PlanDownloadUseCase planDownload,
    required OnDevicePresence presence,
    DateTime Function()? clock,
  })  : _queue = queue,
        _startDownload = startDownload,
        _cancelDownload = cancelDownload,
        _planDownload = planDownload,
        _presence = presence,
        _clock = clock ?? DateTime.now,
        super(const DownloadProgressState()) {
    on<DownloadProgressWatchRequested>((event, emit) => _poll(emit));
    on<DownloadProgressPolled>((event, emit) => _poll(emit));
    on<DownloadRequested>(_onRequested);
    on<DownloadFilesRequested>(_onFilesRequested);
    on<DownloadCancelRequested>(_onCancelRequested);
    on<DownloadProgressDismissed>((event, emit) => emit(state.copyWith(dismissed: true)));
  }

  Future<void> _onRequested(DownloadRequested event, Emitter<DownloadProgressState> emit) =>
      _start(event.plan, event.album, emit);

  Future<void> _onFilesRequested(DownloadFilesRequested event, Emitter<DownloadProgressState> emit) async {
    try {
      final plan = await _planDownload(fileIds: event.fileIds);
      if (plan.isEmpty) {
        emit(state.copyWith(outcome: DownloadOutcome(started: 0, requested: event.fileIds.length)));
        return;
      }
      await _start(plan, null, emit);
    } catch (e) {
      emit(state.copyWith(failure: () => ErrorHandler.handleError(e)));
    }
  }

  Future<void> _start(DownloadPlan plan, String? album, Emitter<DownloadProgressState> emit) async {
    try {
      final wasRunning = state.isRunning;
      await _startDownload(plan, album: album);
      if (!wasRunning) {
        _firstSample = null;
        _markedOnDevice.clear();
      }
      emit(state.copyWith(
          outcome: DownloadOutcome(started: plan.toDownload.length,
              requested: plan.toDownload.length + plan.alreadyOnDevice)));
      await _poll(emit, restart: true);
    } catch (e) {
      emit(state.copyWith(failure: () => ErrorHandler.handleError(e)));
    }
  }

  Future<void> _onCancelRequested(DownloadCancelRequested event, Emitter<DownloadProgressState> emit) async {
    await _cancelDownload();
    await _poll(emit);
  }

  /// [restart]: a download was just requested, so a previous failure or dismissal no longer applies.
  Future<void> _poll(Emitter<DownloadProgressState> emit, {bool restart = false}) async {
    final progress = await _queue.progress();

    final newlySaved = (await _queue.savedIds()).where(_markedOnDevice.add).toList();
    if (newlySaved.isNotEmpty) {
      _presence.markOnDevice(newlySaved);
    }

    emit(state.copyWith(
      progress: progress,
      remaining: () => _estimateRemaining(progress.bytesSaved, progress.bytesTotal),
      failure: restart ? () => null : null,
      dismissed: restart ? false : null,
    ));

    if (progress.isRunning) {
      _timer ??= Timer.periodic(pollInterval, (_) => add(const DownloadProgressPolled()));
    } else {
      _timer?.cancel();
      _timer = null;
      _firstSample = null;
    }
  }

  Duration? _estimateRemaining(int bytesSaved, int bytesTotal) {
    final now = _clock();
    final first = _firstSample ??= (at: now, bytes: bytesSaved);
    final elapsed = now.difference(first.at);
    final bytesSinceFirst = bytesSaved - first.bytes;
    if (elapsed.inSeconds < 3 || bytesSinceFirst <= 0) {
      return null;
    }
    final bytesPerSecond = bytesSinceFirst / elapsed.inMilliseconds * 1000;
    return Duration(seconds: ((bytesTotal - bytesSaved) / bytesPerSecond).ceil());
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
