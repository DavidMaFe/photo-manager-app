import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/utils/file_size_formatter.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/features/downloads/presentation/bloc/on_device_presence_cubit.dart';
import 'package:photo_manager_app/features/downloads/presentation/widgets/download_sheet.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// Header of the gallery filter «Not on phone»: how many files and how much, and «Download all».
class NotOnDeviceSummary extends StatelessWidget {
  const NotOnDeviceSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;
    final presence = context.watch<OnDevicePresenceCubit>().state;
    if (!presence.known || presence.missingCount == 0) return const SizedBox.shrink();
    final size = FileSizeFormatter.format(presence.missingBytes, locale: Localizations.localeOf(context).toLanguageTag());

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.notOnDeviceSummary(presence.missingCount, size),
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: p.ink2),
            ),
          ),
          AppButton.primary(
            label: l10n.downloadAll,
            icon: Symbols.download_rounded,
            size: AppButtonSize.small,
            onPressed: () => DownloadSheet.showAll(context),
          ),
        ],
      ),
    );
  }
}
