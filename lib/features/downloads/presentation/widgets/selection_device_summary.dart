import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/core/utils/file_size_formatter.dart';
import 'package:photo_manager_app/features/downloads/presentation/bloc/on_device_presence_cubit.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_file.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// Second line of the selection header: «48 MB · 2 on this phone». Only the size while it is not known which files
/// this phone has, and nothing when neither is known. Rebuilds the caller when that changes.
String? selectionDeviceSummary(BuildContext context, List<GalleryFile> selected) {
  final l10n = AppLocalizations.of(context)!;
  final presence = context.watch<OnDevicePresenceCubit>().state;
  final bytes = selected.fold(0, (total, file) => total + file.sizeBytes);
  final size = FileSizeFormatter.format(bytes, locale: Localizations.localeOf(context).toLanguageTag());
  if (!presence.known) return bytes > 0 ? size : null;
  final onDevice = selected.where((file) => presence.isOnDevice(file.id) ?? false).length;
  return l10n.selectionSizeOnDevice(size, onDevice);
}
