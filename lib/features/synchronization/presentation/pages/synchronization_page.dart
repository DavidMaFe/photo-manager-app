import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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

import '../../../../core/injection_container.dart' as di;
import '../../../sync_session/presentation/bloc/sync_session_bloc.dart';
import '../../../sync_session/presentation/bloc/sync_session_event.dart';
import '../../../sync_session/presentation/pages/sync_session_process_page.dart';


class SynchronizationPage extends StatefulWidget {

  const SynchronizationPage({super.key});

  @override
  State<SynchronizationPage> createState() => _SynchronizationPageState();
}

class _SynchronizationPageState extends State<SynchronizationPage> {

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
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

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<SynchronizationBloc, SynchronizationState>(
          builder: (context, state) => _buildContent(context, state, l10n),
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
            child: BlocBuilder<SyncConfigBloc, SyncConfigState>(
              builder: (context, configState) => SynchronizationStatusCard(
                latestSync: state.sessions.isNotEmpty ? state.sessions.first : null,
                onSyncNowPressed: () => _openSyncProcess(context),
                config: _configOf(configState),
                onSettingsPressed: () => _openSettings(context),
              ),
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
                    for (var i = 0; i < state.sessions.length; i++) ...[
                      if (i > 0) const Divider(indent: 68),
                      SynchronizationListItem(session: state.sessions[i]),
                    ],
                  ],
                ),
              ),
            ),
            if (state.hasMore)
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

  void _openSyncProcess(BuildContext context) {

    final syncBloc = di.sl<SyncSessionBloc>();
    syncBloc.add(const SyncSessionReset());

    Future.delayed(const Duration(milliseconds: 50), () {
      syncBloc.add(SyncSessionStarted(context));
    });

    Navigator.of(context).push(
        MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => BlocProvider.value(
              value: syncBloc,
              child: const SyncSessionProcessPage(),
            )
        )
    );
  }
}
