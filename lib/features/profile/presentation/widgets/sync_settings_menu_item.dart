import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager_app/core/injection_container.dart';
import 'package:photo_manager_app/core/navigation/route_names.dart';
import 'package:photo_manager_app/features/profile/presentation/widgets/profile_menu_item.dart';
import 'package:photo_manager_app/features/sync_config/domain/entities/sync_config.dart';
import 'package:photo_manager_app/features/sync_config/domain/use_cases/get_sync_config_use_case.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

class SyncSettingsMenuItem extends StatefulWidget {
  const SyncSettingsMenuItem({super.key});

  @override
  State<SyncSettingsMenuItem> createState() => _SyncSettingsMenuItemState();
}

class _SyncSettingsMenuItemState extends State<SyncSettingsMenuItem> {
  SyncConfig? _syncConfig;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSyncConfig();
  }

  Future<void> _loadSyncConfig() async {
    try {
      final getSyncConfigUseCase = sl<GetSyncConfigUseCase>();
      final config = await getSyncConfigUseCase();
      if (mounted) {
        setState(() {
          _syncConfig = config;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _buildSubtitle(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return l10n.loadingConfiguration;
    }

    if (_syncConfig == null || !_syncConfig!.autoSyncEnabled) {
      return l10n.autoSyncDisabled;
    }

    // Build dynamic subtitle based on config
    final frequency = _syncConfig!.isWeeklySync
        ? l10n.syncFrequencyWeekly
        : l10n.syncFrequencyDaily;

    final time = _syncConfig!.syncTime.format(context);

    String dayInfo = '';
    if (_syncConfig!.isWeeklySync && _syncConfig!.syncDayOfWeek != null) {
      final dayName = _getDayName(context, _syncConfig!.syncDayOfWeek!);
      dayInfo = ' ($dayName)';
    }

    return '$frequency ${l10n.syncFrequencyAt} $time$dayInfo';
  }

  String _getDayName(BuildContext context, int day) {
    final l10n = AppLocalizations.of(context)!;
    switch (day) {
      case 1:
        return l10n.monday;
      case 2:
        return l10n.tuesday;
      case 3:
        return l10n.wednesday;
      case 4:
        return l10n.thursday;
      case 5:
        return l10n.friday;
      case 6:
        return l10n.saturday;
      case 7:
        return l10n.sunday;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ProfileMenuItem(
      icon: Icons.sync_outlined,
      title: l10n.syncSettings,
      subtitle: _buildSubtitle(context),
      onTap: () {
        context.goNamed(RouteNames.syncConfiguration);
      },
    );
  }
}
