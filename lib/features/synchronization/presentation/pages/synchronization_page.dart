import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/features/synchronization/presentation/bloc/synchronization_bloc.dart';
import 'package:photo_manager_app/features/synchronization/presentation/bloc/synchronization_event.dart';
import 'package:photo_manager_app/features/synchronization/presentation/bloc/synchronization_state.dart';
import 'package:photo_manager_app/features/synchronization/presentation/widgets/empty_synchronization_state.dart';
import 'package:photo_manager_app/features/synchronization/presentation/widgets/error_synchronization_state.dart';
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

    return BlocBuilder<SynchronizationBloc, SynchronizationState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.syncSessionTitle),
          ),
          body: _buildContent(context, state, l10n),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, SynchronizationState state, AppLocalizations l10n) {

    if (state is SynchronizationsLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    if (state is SynchronizationError) {
      return ErrorSynchronizationState(
        message: state.failure.messageKey,
        onRetry: () {
          context.read<SynchronizationBloc>().add(const LoadSynchronizations());
        },
      );
    }

    if (state is SynchronizationsLoaded) {

      return RefreshIndicator(
        onRefresh: () async {
          context.read<SynchronizationBloc>().add(const RefreshSynchronizations());
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: SynchronizationStatusCard(
                latestSync: state.sessions.isNotEmpty ? state.sessions.first : null,
                onSyncNowPressed: () => _openSyncProcess(context),
              ),
            ),
            if (state.sessions.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: EmptySynchronizationState(),
              )
            else ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Text(
                    l10n.syncHistoric,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111111)
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final session = state.sessions[index];
                        return SynchronizationListItem(session: session);
                      },
                    childCount: state.sessions.length
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
              const SliverToBoxAdapter(child: SizedBox(height: 16))
            ],
          ],
        ),
      );
    }
    return const Center(child: CircularProgressIndicator());
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