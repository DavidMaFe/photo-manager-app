import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/theme/photo_manager_colors.dart';
import '../../../../core/injection_container.dart' as di;
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../sync_session/presentation/bloc/sync_session_bloc.dart';
import '../../../sync_session/presentation/bloc/sync_session_event.dart';
import '../../../sync_session/presentation/pages/sync_session_process_page.dart';


class SynchronizationPage extends StatelessWidget {

  const SynchronizationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
            },
            tooltip: 'Logout',
          )
        ],
      ),
      body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {},
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Welcome!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<AuthBloc>().add(LogoutRequested());
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16
                      )
                  ),
                )
              ],
            ),
          )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openSyncProcess(context),
        backgroundColor: PhotoManagerColors.primary,
        tooltip: 'Sincronizar',
        child: const Icon(Icons.sync, color: Colors.white),
      ),
    );
  }

  void _openSyncProcess(BuildContext context) {

    final syncBloc = di.sl<SyncSessionBloc>();
    syncBloc.add(const SyncSessionReset());

    Future.delayed(const Duration(milliseconds: 50), () {
      syncBloc.add(const SyncSessionStarted());
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