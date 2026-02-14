import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager_app/core/errors/service/error_notification_service.dart';
import 'package:photo_manager_app/core/injection_container.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_bloc.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_event.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_state.dart';
import 'package:photo_manager_app/features/sync_config/presentation/widgets/sync_configuration/auto_sync_toggle_widget.dart';
import 'package:photo_manager_app/features/sync_config/presentation/widgets/sync_configuration/battery_preference_widget.dart';
import 'package:photo_manager_app/features/sync_config/presentation/widgets/sync_configuration/day_of_week_picker_widget.dart';
import 'package:photo_manager_app/features/sync_config/presentation/widgets/sync_configuration/frequency_selector_widget.dart';
import 'package:photo_manager_app/features/sync_config/presentation/widgets/sync_configuration/network_preference_widget.dart';
import 'package:photo_manager_app/features/sync_config/presentation/widgets/sync_configuration/notification_preferences_widget.dart';
import 'package:photo_manager_app/features/sync_config/presentation/widgets/sync_configuration/save_button_widget.dart';
import 'package:photo_manager_app/features/sync_config/presentation/widgets/sync_configuration/time_picker_widget.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

class SyncConfigurationPage extends StatelessWidget {
  const SyncConfigurationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SyncConfigBloc>()..add(LoadSyncConfig()),
      child: const _SyncConfigurationPageContent(),
    );
  }
}

class _SyncConfigurationPageContent extends StatelessWidget {
  const _SyncConfigurationPageContent();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.syncConfigurationTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<SyncConfigBloc, SyncConfigState>(
        listener: (context, state) {
          if (state is SyncConfigError) {
            ErrorNotificationService.showError(
              context,
              state.failure,
            );
          } else if (state is SyncConfigSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.configurationSaved),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        builder: (context, state) {
          // Handle initial state - show loading
          if (state is SyncConfigInitial || state is SyncConfigLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    l10n.loadingConfiguration,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            );
          }

          if (state is SyncConfigError && state.currentConfig == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    l10n.configurationLoadError,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      context.read<SyncConfigBloc>().add(LoadSyncConfig());
                    },
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }

          // Extract config from state
          final config = state is SyncConfigLoaded
              ? state.config
              : state is SyncConfigSaving
                  ? state.config
                  : state is SyncConfigSaved
                      ? state.config
                      : state is SyncConfigError
                          ? state.currentConfig
                          : null;

          if (config == null) {
            return const SizedBox.shrink();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                Text(
                  l10n.syncConfigurationDescription,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 24),

                // Auto-sync toggle
                AutoSyncToggleWidget(isEnabled: config.autoSyncEnabled),
                const SizedBox(height: 24),

                // Frequency selector
                FrequencySelectorWidget(frequency: config.syncFrequency),
                const SizedBox(height: 24),

                // Time picker
                TimePickerWidget(time: config.syncTime),
                const SizedBox(height: 24),

                // Day of week picker (only for weekly)
                if (config.isWeeklySync)
                  DayOfWeekPickerWidget(
                    selectedDay: config.syncDayOfWeek,
                  ),
                if (config.isWeeklySync) const SizedBox(height: 24),

                // Network preference
                NetworkPreferenceWidget(
                  preference: config.networkPreference,
                ),
                const SizedBox(height: 24),

                // Battery preference
                BatteryPreferenceWidget(
                  preference: config.batteryPreference,
                ),
                const SizedBox(height: 24),

                // Notification preferences
                NotificationPreferencesWidget(
                  notifyOnSuccess: config.notifyOnSuccess,
                  notifyOnFailure: config.notifyOnFailure,
                ),
                const SizedBox(height: 32),

                // Save button
                SaveButtonWidget(
                  isSaving: state is SyncConfigSaving,
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
