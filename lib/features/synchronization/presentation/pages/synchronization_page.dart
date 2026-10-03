import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/core/errors/widget/error_display.dart';
import 'package:photo_manager_app/core/navigation/route_names.dart';
import 'package:photo_manager_app/core/widgets/app_card.dart';
import 'package:photo_manager_app/core/widgets/screen_header.dart';
import 'package:photo_manager_app/features/sync_config/domain/entities/sync_config.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_bloc.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_event.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_state.dart';
import 'package:photo_manager_app/features/synchronization/presentation/bloc/synchronization_bloc.dart';
import 'package:photo_manager_app/features/synchronization/presentation/bloc/synchronization_event.dart';
import 'package:photo_manager_app/features/synchronization/presentation/bloc/synchronization_state.dart';
import 'package:photo_manager_app/features/synchronization/presentation/widgets/synchronization_list_item.dart';
import 'package:photo_manager_app/features/synchronization/presentation/widgets/synchronization_status_card.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/errors/service/error_notification_service.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/core/widgets/permission/background_task_permission_helper.dart';
import 'package:photo_manager_app/features/sync_session/presentation/bloc/sync_session_bloc.dart';
import 'package:photo_manager_app/features/sync_session/presentation/bloc/sync_session_event.dart';
import 'package:photo_manager_app/features/sync_session/presentation/bloc/sync_session_state.dart';
import 'package:photo_manager_app/features/sync_session/presentation/widgets/dialogs/cancel_sync_confirmation_dialog.dart';
import 'package:photo_manager_app/features/synchronization/presentation/utils/backup_time_estimator.dart';


/// "Backup" tab: status card (with the running backup) and activity.
class SynchronizationPage extends StatefulWidget {

  /// Activity rows shown before "See all".
  static const int activityPreviewCount = 5;

  /// Whether the OS lets the backup run in the background (injectable for tests).
  final Future<bool> Function() backgroundCheck;

  /// Clock for the time-left estimate (injectable for tests).
  final DateTime Function() clock;

  const SynchronizationPage({
    super.key,
    this.backgroundCheck = BackgroundTaskPermissionHelper.isBackgroundTaskEnabled,
    this.clock = DateTime.now,
  });

  @override
  State<SynchronizationPage> createState() => _SynchronizationPageState();
}

class _SynchronizationPageState extends State<SynchronizationPage> {

  final ScrollController _scrollController = ScrollController();
  final BackupTimeEstimator _estimator = BackupTimeEstimator();

  bool _showAllActivity = false;
  bool _cancelRequested = false;
  bool _backgroundEnabled = false;
  Duration? _remaining;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _checkBackground();
  }

  Future<void> _checkBackground() async {
    bool enabled;
    try {
      enabled = await widget.backgroundCheck();
    } catch (_) {
      enabled = false;
    }
    if (mounted) setState(() => _backgroundEnabled = enabled);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_showAllActivity && _isBottom) {
      context.read<SynchronizationBloc>().add(const LoadMoreSynchronizations());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    return BlocListener<SyncSessionBloc, SyncSessionState>(
      listener: _onSessionStateChanged,
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<SynchronizationBloc, SynchronizationState>(
            builder: (context, state) => _buildContent(context, state, l10n),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, SynchronizationState state, AppLocalizations l10n) {

    if (state is SynchronizationError) {
      return Column(
        children: [
          ScreenHeader(title: l10n.navBackup),
          Expanded(
            child: ErrorDisplay(
              failure: state.failure,
              onRetry: () => context.read<SynchronizationBloc>().add(const LoadSynchronizations()),
            ),
          ),
        ],
      );
    }

    if (state is! SynchronizationsLoaded) {
      return Column(
        children: [
          ScreenHeader(title: l10n.navBackup),
          const Expanded(child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
        ],
      );
    }

    const preview = SynchronizationPage.activityPreviewCount;
    final canExpand = state.sessions.length > preview || state.hasMore;
    final isBackingUp = context.select((SyncSessionBloc bloc) => _liveBackupOf(bloc.state) != null);
    final visibleCount = _showAllActivity ? state.sessions.length : math.min(state.sessions.length, preview);

    return RefreshIndicator(
      onRefresh: () async {
        context.read<SynchronizationBloc>().add(const RefreshSynchronizations());
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: ScreenHeader(title: l10n.navBackup)),
          SliverToBoxAdapter(
            child: BlocBuilder<SyncSessionBloc, SyncSessionState>(
              builder: (context, sessionState) {
                final live = _liveBackupOf(sessionState);
                return Column(
                  children: [
                    BlocBuilder<SyncConfigBloc, SyncConfigState>(
                      builder: (context, configState) => SynchronizationStatusCard(
                        latestSync: state.sessions.isNotEmpty ? state.sessions.first : null,
                        onSyncNowPressed: () => _startBackup(context),
                        config: _configOf(configState),
                        onSettingsPressed: () => _openSettings(context),
                        live: live,
                        onCancelPressed: () => _confirmCancel(context),
                      ),
                    ),
                    if (live != null && _backgroundEnabled) _BackgroundInfo(text: l10n.backgroundInfo),
                  ],
                );
              },
            ),
          ),
          if (state.sessions.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                child: Semantics(
                  header: true,
                  child: Text(l10n.activity, style: Theme.of(context).textTheme.titleMedium),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: AppCard(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (var i = 0; i < visibleCount; i++) ...[
                      if (i > 0) const Divider(indent: 68),
                      SynchronizationListItem(
                        session: state.sessions[i],
                        onRetry: isBackingUp ? null : () => _startBackup(context),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (canExpand)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Center(
                    child: AppButton.text(
                      label: _showAllActivity ? l10n.seeLess : l10n.seeAll,
                      onPressed: () => setState(() => _showAllActivity = !_showAllActivity),
                    ),
                  ),
                ),
              ),
            if (_showAllActivity && state.hasMore)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: state.isLoadingMore ? const CircularProgressIndicator(strokeWidth: 2) : const SizedBox.shrink(),
                  ),
                ),
              ),
          ],
          SliverToBoxAdapter(child: SizedBox(height: 24 + MediaQuery.paddingOf(context).bottom)),
        ],
      ),
    );
  }

  SyncConfig? _configOf(SyncConfigState state) {
    return switch (state) {
      SyncConfigLoaded() => state.config,
      SyncConfigSaving() => state.config,
      SyncConfigSaved() => state.config,
      SyncConfigError() => state.currentConfig,
      _ => null,
    };
  }

  Future<void> _openSettings(BuildContext context) async {
    final configBloc = context.read<SyncConfigBloc>();
    await context.pushNamed(RouteNames.syncConfiguration);
    // The settings page has its own bloc: reload to show the saved conditions.
    configBloc.add(LoadSyncConfig());
  }

  /// Running backup shown in the status card, or `null` when idle.
  LiveBackup? _liveBackupOf(SyncSessionState state) {
    LiveBackup? live = switch (state) {
      SyncSessionStarting() => const LiveBackup(phase: LiveBackupPhase.preparing),
      SyncSessionFetchingFiles() => const LiveBackup(phase: LiveBackupPhase.scanning),
      SyncSessionUploading() => LiveBackup(
          phase: LiveBackupPhase.uploading,
          uploaded: state.uploadCount,
          total: state.totalCount,
          remaining: _remaining,
        ),
      SyncSessionCompleting() => const LiveBackup(phase: LiveBackupPhase.finishing, uploaded: 1, total: 1),
      _ => null,
    };
    if (live != null && _cancelRequested) {
      live = LiveBackup(phase: LiveBackupPhase.cancelling, uploaded: live.uploaded, total: live.total);
    }
    return live;
  }

  void _onSessionStateChanged(BuildContext context, SyncSessionState state) {
    final l10n = AppLocalizations.of(context)!;

    if (state is SyncSessionUploading) {
      _remaining = _estimator.update(uploaded: state.uploadCount, total: state.totalCount, now: widget.clock());
      return;
    }
    if (state is SyncSessionStarting || state is SyncSessionFetchingFiles || state is SyncSessionCompleting) {
      return;
    }

    // The backup finished one way or another.
    final wasCancelled = _cancelRequested;
    setState(() {
      _cancelRequested = false;
      _remaining = null;
    });
    _estimator.reset();

    if (state is SyncSessionSuccess) {
      // The history refreshes itself through SyncCompletedEvent.
      _showSnackBar(context, l10n.itemsSaved(state.result.uploadedFiles));
    } else if (state is SyncSessionCancelling) {
      context.read<SynchronizationBloc>().add(const RefreshSynchronizations());
      _showSnackBar(context, l10n.backupCancelled);
    } else if (state is SyncSessionError && !wasCancelled) {
      context.read<SynchronizationBloc>().add(const RefreshSynchronizations());
      ErrorNotificationService.showError(
        context,
        state.failure,
        config: ErrorDisplayConfig.snackBar,
        onRetry: () => _startBackup(context),
      );
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// Starts a backup in place: the status card follows its progress.
  void _startBackup(BuildContext context) {
    final syncBloc = context.read<SyncSessionBloc>();
    if (_liveBackupOf(syncBloc.state) != null) return;

    _estimator.reset();
    setState(() {
      _cancelRequested = false;
      _remaining = null;
    });
    syncBloc.add(const SyncSessionReset());

    Future.delayed(const Duration(milliseconds: 50), () {
      if (context.mounted) syncBloc.add(SyncSessionStarted(context));
    });
  }

  void _confirmCancel(BuildContext context) {
    CancelSyncConfirmationDialog.show(
      context: context,
      onConfirm: () {
        setState(() => _cancelRequested = true);
        context.read<SyncSessionBloc>().add(const SyncSessionCancelled());
      },
    );
  }
}

/// "You can leave the app" note under the running backup.
class _BackgroundInfo extends StatelessWidget {
  final String text;

  const _BackgroundInfo({required this.text});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Symbols.info_rounded, size: 18, color: p.ink3),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 13, height: 1.4, color: p.ink2)),
          ),
        ],
      ),
    );
  }
}
