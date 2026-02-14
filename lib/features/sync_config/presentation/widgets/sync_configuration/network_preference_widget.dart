import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/features/sync_config/domain/enums/network_preference.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_bloc.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_event.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

class NetworkPreferenceWidget extends StatelessWidget {
  final NetworkPreference preference;

  const NetworkPreferenceWidget({
    super.key,
    required this.preference,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.networkPreferenceTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            RadioListTile<NetworkPreference>(
              title: Text(l10n.networkPreferenceWifiOnly),
              subtitle: Text(l10n.networkPreferenceWifiOnlyDescription),
              value: NetworkPreference.wifiOnly,
              groupValue: preference,
              onChanged: (value) {
                if (value != null) {
                  context
                      .read<SyncConfigBloc>()
                      .add(UpdateNetworkPreference(value));
                }
              },
            ),
            RadioListTile<NetworkPreference>(
              title: Text(l10n.networkPreferenceAnyNetwork),
              subtitle: Text(l10n.networkPreferenceAnyNetworkDescription),
              value: NetworkPreference.anyNetwork,
              groupValue: preference,
              onChanged: (value) {
                if (value != null) {
                  context
                      .read<SyncConfigBloc>()
                      .add(UpdateNetworkPreference(value));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
