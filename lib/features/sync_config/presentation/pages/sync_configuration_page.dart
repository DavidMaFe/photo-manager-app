import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/errors/service/error_notification_service.dart';
import 'package:photo_manager_app/core/injection_container.dart';
import 'package:photo_manager_app/core/widgets/app_card.dart';
import 'package:photo_manager_app/core/widgets/empty_state.dart';
import 'package:photo_manager_app/core/widgets/secondary_top_bar.dart';
import 'package:photo_manager_app/core/widgets/section_label.dart';
import 'package:photo_manager_app/features/sync_config/domain/entities/sync_config.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_bloc.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_event.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_state.dart';
import 'package:photo_manager_app/features/sync_config/presentation/utils/next_backup.dart';
import 'package:photo_manager_app/features/sync_config/presentation/widgets/sync_configuration/auto_sync_toggle_widget.dart';
import 'package:photo_manager_app/features/sync_config/presentation/widgets/sync_configuration/battery_preference_widget.dart';
import 'package:photo_manager_app/features/sync_config/presentation/widgets/sync_configuration/day_of_week_picker_widget.dart';
import 'package:photo_manager_app/features/sync_config/presentation/widgets/sync_configuration/frequency_selector_widget.dart';
import 'package:photo_manager_app/features/sync_config/presentation/widgets/sync_configuration/network_preference_widget.dart';
import 'package:photo_manager_app/features/sync_config/presentation/widgets/sync_configuration/notification_preferences_widget.dart';
import 'package:photo_manager_app/features/sync_config/presentation/widgets/sync_configuration/save_button_widget.dart';
import 'package:photo_manager_app/features/sync_config/presentation/widgets/sync_configuration/sync_diagnostics_widget.dart';
import 'package:photo_manager_app/features/sync_config/presentation/widgets/sync_configuration/time_picker_widget.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

class SyncConfigurationPage extends StatelessWidget {
  const SyncConfigurationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SyncConfigBloc>()..add(LoadSyncConfig()),
      child: const SyncConfigurationView(),
    );
  }
}

/// Backup settings content; expects a [SyncConfigBloc] above it.
class SyncConfigurationView extends StatefulWidget {

  /// Hidden in tests: it reads the device battery and background task status.
  final bool showDiagnostics;

  const SyncConfigurationView({super.key, this.showDiagnostics = true});

  @override
  State<SyncConfigurationView> createState() => _SyncConfigurationViewState();
}

class _SyncConfigurationViewState extends State<SyncConfigurationView> {

  /// Last loaded or saved configuration, to enable "Save" only on changes.
  SyncConfig? _savedConfig;

  SyncConfig? _configOf(SyncConfigState state) {
    return switch (state) {
      SyncConfigLoaded() => state.config,
      SyncConfigSaving() => state.config,
      SyncConfigSaved() => state.config,
      SyncConfigError() => state.currentConfig,
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: SecondaryTopBar(title: l10n.backupSettings, onBack: () => context.pop()),
      body: BlocConsumer<SyncConfigBloc, SyncConfigState>(
        listener: (context, state) {
          if (state is SyncConfigError) {
            ErrorNotificationService.showError(context, state.failure);
          } else if (state is SyncConfigSaved) {
            setState(() => _savedConfig = state.config);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.configurationSaved), duration: const Duration(seconds: 2)),
            );
          }
        },
        builder: (context, state) {
          if (state is SyncConfigInitial || state is SyncConfigLoading) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          }

          final config = _configOf(state);

          if (config == null) {
            return EmptyState(
              icon: Symbols.error_rounded,
              title: l10n.configurationLoadError,
              actionLabel: l10n.retry,
              onAction: () => context.read<SyncConfigBloc>().add(LoadSyncConfig()),
            );
          }

          _savedConfig ??= config;

          return Column(
            children: [
              Expanded(child: _buildForm(context, config, l10n)),
              SaveButtonWidget(
                isSaving: state is SyncConfigSaving,
                hasChanges: config != _savedConfig,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context, SyncConfig config, AppLocalizations l10n) {
    final enabled = config.autoSyncEnabled;

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AutoSyncToggleWidget(isEnabled: enabled),
        ),
        // Everything else only applies while automatic backup is on.
        IgnorePointer(
          ignoring: !enabled,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: enabled ? 1 : 0.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionLabel(l10n.sectionWhen),
                AppCard(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FrequencySelectorWidget(frequency: config.syncFrequency),
                      if (config.isWeeklySync) ...[
                        const SizedBox(height: 12),
                        DayOfWeekPickerWidget(selectedDay: config.syncDayOfWeek),
                      ],
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 4),
                      TimePickerWidget(time: config.syncTime),
                      _NextBackupNote(config: config),
                    ],
                  ),
                ),
                SectionLabel(l10n.sectionConditions),
                AppCard(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      NetworkPreferenceWidget(preference: config.networkPreference),
                      const SizedBox(height: 16),
                      BatteryPreferenceWidget(preference: config.batteryPreference),
                    ],
                  ),
                ),
                SectionLabel(l10n.sectionAlerts),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: NotificationPreferencesWidget(
                    notifyOnSuccess: config.notifyOnSuccess,
                    notifyOnFailure: config.notifyOnFailure,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (widget.showDiagnostics) ...[
          SectionLabel(l10n.sectionDiagnostics),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SyncDiagnosticsWidget(),
          ),
        ],
      ],
    );
  }
}

/// "Next backup: Saturday 3 Oct at 03:00".
class _NextBackupNote extends StatelessWidget {
  final SyncConfig config;

  const _NextBackupNote({required this.config});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final next = nextBackupAt(config, DateTime.now());
    if (next == null) return const SizedBox.shrink();

    final locale = l10n.localeName;
    final day = DateFormat('EEEE d MMM', locale).format(next);
    final time = DateFormat.Hm(locale).format(next);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        l10n.nextBackup(l10n.weeklyAt(day, time)),
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.palette.ink2),
      ),
    );
  }
}
