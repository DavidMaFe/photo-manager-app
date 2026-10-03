import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/widgets/segmented_control.dart';
import 'package:photo_manager_app/features/sync_config/domain/enums/network_preference.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_bloc.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_event.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// "Network": Wi-Fi only / Wi-Fi and data.
class NetworkPreferenceWidget extends StatelessWidget {
  final NetworkPreference preference;

  const NetworkPreferenceWidget({super.key, required this.preference});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.network, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: context.palette.ink)),
        const SizedBox(height: 8),
        SegmentedControl<NetworkPreference>(
          segments: [
            SegmentItem(value: NetworkPreference.wifiOnly, label: l10n.condWifi),
            SegmentItem(value: NetworkPreference.anyNetwork, label: l10n.condAnyNetwork),
          ],
          selected: preference,
          onChanged: (value) => context.read<SyncConfigBloc>().add(UpdateNetworkPreference(value)),
        ),
      ],
    );
  }
}
