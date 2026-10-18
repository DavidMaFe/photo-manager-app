import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/injection_container.dart';
import 'package:photo_manager_app/core/utils/file_size_formatter.dart';
import 'package:photo_manager_app/core/widgets/list_row.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/device_storage.dart';
import 'package:photo_manager_app/features/downloads/domain/use_cases/get_device_storage_use_case.dart';
import 'package:photo_manager_app/features/downloads/presentation/bloc/on_device_presence_cubit.dart';
import 'package:photo_manager_app/features/downloads/presentation/widgets/download_sheet.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// «Save everything on this phone»: how many files this phone is missing and its free space. Opens the download
/// of everything that is missing (ROADMAP-downloads-and-account-deletion.md, Phase 2).
class SaveEverythingRow extends StatefulWidget {
  /// Free space of this device; null where the app cannot save into the gallery.
  final Future<DeviceStorage?> Function()? loadStorage;

  /// Opens the download sheet. By default, the sheet of everything that is missing.
  final void Function(BuildContext context)? onOpen;

  const SaveEverythingRow({super.key, this.loadStorage, this.onOpen});

  @override
  State<SaveEverythingRow> createState() => _SaveEverythingRowState();
}

class _SaveEverythingRowState extends State<SaveEverythingRow> {
  DeviceStorage? _storage;

  @override
  void initState() {
    super.initState();
    _loadStorage();
  }

  Future<void> _loadStorage() async {
    try {
      final storage = await (widget.loadStorage ?? () => sl<GetDeviceStorageUseCase>()())();
      if (mounted) setState(() => _storage = storage);
    } catch (_) {
      // Without the free space the row still shows what is missing
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final presence = context.watch<OnDevicePresenceCubit>().state;

    final String? subtitle;
    if (!presence.known) {
      subtitle = null;
    } else if (presence.missingCount == 0) {
      subtitle = l10n.deleteAccountSaveAllDone;
    } else if (_storage != null) {
      subtitle = l10n.deleteAccountSaveAllFree(
          presence.missingCount, FileSizeFormatter.format(_storage!.freeBytes, locale: locale));
    } else {
      subtitle = l10n.deleteAccountSaveAllDetail(
          presence.missingCount, FileSizeFormatter.format(presence.missingBytes, locale: locale));
    }
    final canDownload = presence.known && presence.missingCount > 0;

    return ListRow(
      key: const ValueKey('delete-account-save-all'),
      icon: Symbols.download_rounded,
      iconColor: p.accent,
      title: l10n.deleteAccountSaveAll,
      subtitle: subtitle,
      onTap: canDownload ? () => (widget.onOpen ?? DownloadSheet.showAll)(context) : null,
    );
  }
}
