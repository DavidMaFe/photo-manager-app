import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager_app/core/errors/service/error_notification_service.dart';
import 'package:photo_manager_app/core/errors/widget/error_display.dart';
import 'package:photo_manager_app/core/injection_container.dart';
import 'package:photo_manager_app/core/navigation/route_names.dart';
import 'package:photo_manager_app/core/widgets/secondary_top_bar.dart';
import 'package:photo_manager_app/features/sync_session/domain/repositories/sync_device_repository.dart';
import 'package:photo_manager_app/features/devices/presentation/bloc/device_bloc.dart';
import 'package:photo_manager_app/features/devices/presentation/bloc/device_event.dart';
import 'package:photo_manager_app/features/devices/presentation/bloc/device_state.dart';
import 'package:photo_manager_app/features/devices/presentation/widgets/device_card.dart';
import 'package:photo_manager_app/features/devices/presentation/widgets/devices_empty_state.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

class DevicesPage extends StatefulWidget {

  /// UUID of the phone running the app; defaults to the sync device repository.
  final Future<String?> Function()? loadCurrentDeviceUuid;

  const DevicesPage({super.key, this.loadCurrentDeviceUuid});

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {

  String? _currentDeviceUuid;

  @override
  void initState() {
    super.initState();
    _loadCurrentDeviceUuid();
  }

  Future<void> _loadCurrentDeviceUuid() async {
    try {
      final load = widget.loadCurrentDeviceUuid ?? () => sl<SyncDeviceRepository>().getDeviceUuid();
      final uuid = await load();
      if (mounted) setState(() => _currentDeviceUuid = uuid);
    } catch (_) {
      // Without the local UUID no card is tagged as "This phone".
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: SecondaryTopBar(title: l10n.myDevices),
      body: SafeArea(
        top: false,
        bottom: false,
        child: BlocConsumer<DeviceBloc, DeviceState>(
          listener: (context, state) {
            if (state is DeviceError) {
              ErrorNotificationService.showError(
                context,
                state.failure,
                config: ErrorDisplayConfig.snackBar,
                onRetry: () {
                  context.read<DeviceBloc>().add(LoadDevices());
                },
              );
            }

            if (state is DeviceActionSuccess) {
              // Show success message briefly
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.deviceActionSuccess),
                  duration: const Duration(seconds: 2),
                ),
              );
            }

            if (state is DeviceAutoSyncEnabled) {
              // Navigate to sync configuration when auto-sync is enabled
              context.pushNamed(RouteNames.syncConfiguration);
            }
          },
          builder: (context, state) {
            if (state is DeviceLoading) {
              return const Center(child: CircularProgressIndicator(strokeWidth: 2));
            }

            if (state is DeviceError) {
              return ErrorDisplay(
                failure: state.failure,
                onRetry: () => context.read<DeviceBloc>().add(LoadDevices()),
              );
            }

            if (state is DeviceLoaded || state is DeviceActionInProgress) {
              final devices = state is DeviceLoaded
                  ? state.devices
                  : (state as DeviceActionInProgress).devices;

              final actionDeviceId = state is DeviceActionInProgress
                  ? state.actionDeviceId
                  : null;

              if (devices.isEmpty) {
                return const DevicesEmptyState();
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<DeviceBloc>().add(RefreshDevices());
                  await Future.delayed(const Duration(milliseconds: 800));
                },
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.paddingOf(context).bottom),
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    final isPerformingAction =
                        actionDeviceId != null && device.id == actionDeviceId;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DeviceCard(
                        device: device,
                        isPerformingAction: isPerformingAction,
                        isCurrentDevice: _currentDeviceUuid != null && device.uuid == _currentDeviceUuid,
                      ),
                    );
                  },
                ),
              );
            }

            // Fallback for unhandled states (should rarely occur)
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
