import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/config/theme/app_radius.dart';
import 'package:photo_manager_app/core/errors/helper/failure_message_helper.dart';
import 'package:photo_manager_app/core/injection_container.dart';
import 'package:photo_manager_app/core/utils/file_size_formatter.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/core/widgets/app_sheet.dart';
import 'package:photo_manager_app/core/widgets/app_switch.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/download_plan.dart';
import 'package:photo_manager_app/features/downloads/domain/use_cases/save_original_to_gallery_use_case.dart';
import 'package:photo_manager_app/features/downloads/presentation/bloc/download_plan_cubit.dart';
import 'package:photo_manager_app/features/downloads/presentation/bloc/download_progress_bloc.dart';
import 'package:photo_manager_app/features/downloads/presentation/bloc/download_progress_event.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// «Save to this phone»: what a download of an album (with or without its subalbums) or of everything this phone is
/// missing would save, the files skipped because they are already here and the free space.
class DownloadSheet extends StatelessWidget {
  /// Null for every file of the account.
  final String? albumName;
  final List<String> subalbumNames;

  const DownloadSheet({super.key, this.albumName, this.subalbumNames = const []});

  static Future<void> showAlbum(BuildContext context,
      {required String folderId, required String albumName, List<String> subalbumNames = const []}) {
    return showAppSheet<void>(
      context,
      builder: (_) => BlocProvider(
        create: (_) => sl<DownloadPlanCubit>(param1: folderId)..load(),
        child: DownloadSheet(albumName: albumName, subalbumNames: subalbumNames),
      ),
    );
  }

  static Future<void> showAll(BuildContext context) {
    return showAppSheet<void>(
      context,
      builder: (_) => BlocProvider(
        create: (_) => sl<DownloadPlanCubit>(param1: null)..load(),
        child: const DownloadSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;

    return BlocBuilder<DownloadPlanCubit, DownloadPlanState>(
      builder: (context, state) {
        final plan = state is DownloadPlanLoaded ? state.plan : null;
        final total = plan == null ? null : plan.toDownload.length + plan.alreadyOnDevice;
        final name = albumName ?? l10n.downloadSheetAllTitle;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(color: p.accentSoft, borderRadius: BorderRadius.circular(AppRadius.field)),
                  child: Icon(Symbols.download_rounded, color: p.accent, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.downloadSheetTitle,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: p.ink)),
                      Text(total == null ? name : l10n.downloadSheetSubtitle(name, total),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: p.ink2)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            switch (state) {
              DownloadPlanLoaded(:final plan) => _PlanDetails(
                  plan: plan,
                  albumName: albumName,
                  subalbumNames: subalbumNames,
                  includeSubfolders: state.includeSubfolders,
                ),
              DownloadPlanError(:final failure) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      Text(FailureMessageHelper.getMessage(context, failure),
                          textAlign: TextAlign.center, style: TextStyle(color: p.ink2)),
                      const SizedBox(height: 12),
                      AppButton.neutral(
                        label: l10n.retry,
                        size: AppButtonSize.small,
                        onPressed: () => context.read<DownloadPlanCubit>().load(),
                      ),
                    ],
                  ),
                ),
              _ => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                ),
            },
            const SizedBox(height: 18),
            AppButton.primary(
              label: plan == null || plan.isEmpty
                  ? l10n.downloadNothingMissing
                  : l10n.downloadButton(plan.toDownload.length),
              icon: Symbols.download_rounded,
              onPressed: plan == null || plan.isEmpty || !plan.fits
                  ? null
                  : () {
                      context.read<DownloadProgressBloc>().add(DownloadRequested(plan, album: albumName));
                      Navigator.of(context).pop();
                    },
            ),
            const SizedBox(height: 8),
            AppButton.text(label: l10n.cancel, onPressed: () => Navigator.of(context).pop()),
          ],
        );
      },
    );
  }
}

class _PlanDetails extends StatelessWidget {
  final DownloadPlan plan;
  final String? albumName;
  final List<String> subalbumNames;
  final bool includeSubfolders;

  const _PlanDetails({
    required this.plan,
    required this.albumName,
    required this.subalbumNames,
    required this.includeSubfolders,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;
    final locale = Localizations.localeOf(context).toLanguageTag();
    String size(int bytes) => FileSizeFormatter.format(bytes, locale: locale);
    final storage = plan.storage;
    final used = storage.totalBytes == 0 ? 0.0 : 1 - storage.freeBytes / storage.totalBytes;
    final needed = storage.totalBytes == 0 ? 0.0 : plan.bytesToDownload / storage.totalBytes;
    final folder = SaveOriginalToGalleryUseCase.relativePathFor(isVideo: false, album: albumName).split('/').last;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(color: p.surface2, borderRadius: BorderRadius.circular(AppRadius.card)),
          child: Column(
            children: [
              _Row(
                icon: Symbols.download_rounded,
                iconColor: p.accent,
                title: l10n.downloadToDownload(plan.toDownload.length),
                subtitle: l10n.downloadApproxSize(size(plan.bytesToDownload)),
              ),
              if (plan.alreadyOnDevice > 0) ...[
                Divider(height: 1, color: p.line, indent: 16, endIndent: 16),
                _Row(
                  icon: Symbols.download_done_rounded,
                  iconColor: p.safe,
                  title: l10n.downloadAlreadyOnDevice(plan.alreadyOnDevice),
                  subtitle: l10n.downloadSkipped,
                ),
              ],
              if (subalbumNames.isNotEmpty) ...[
                Divider(height: 1, color: p.line, indent: 16, endIndent: 16),
                _Row(
                  icon: Symbols.account_tree_rounded,
                  iconColor: p.accent,
                  title: l10n.downloadIncludeSubalbums,
                  subtitle: subalbumNames.join(', '),
                  trailing: AppSwitch(
                    value: includeSubfolders,
                    semanticLabel: l10n.downloadIncludeSubalbums,
                    onChanged: (value) => context.read<DownloadPlanCubit>().setIncludeSubfolders(value),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(l10n.downloadFreeSpace,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: p.ink2)),
            ),
            Text(l10n.downloadFreeOfTotal(size(storage.freeBytes), size(storage.totalBytes)),
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: p.ink)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: SizedBox(
            height: 8,
            child: LayoutBuilder(
              builder: (context, constraints) => Stack(
                children: [
                  Container(color: p.lineSoft),
                  Container(width: constraints.maxWidth * used.clamp(0, 1), color: p.ink3),
                  Positioned(
                    left: constraints.maxWidth * used.clamp(0, 1),
                    child: Container(
                      width: (constraints.maxWidth * needed).clamp(3, constraints.maxWidth),
                      height: 8,
                      color: plan.fits ? p.accent : p.danger,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(plan.fits ? Symbols.info_rounded : Symbols.error_rounded,
                size: 18, color: plan.fits ? p.ink2 : p.danger),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                plan.fits
                    ? l10n.downloadDestinationNote(folder)
                    : l10n.downloadNotEnoughSpaceNote(size(plan.bytesToDownload + DownloadPlan.reservedBytes)),
                style: TextStyle(fontSize: 12, height: 1.35, color: plan.fits ? p.ink2 : p.danger),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _Row({required this.icon, required this.iconColor, required this.title, required this.subtitle,
    this.trailing});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 22, color: iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: p.ink)),
                Text(subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: p.ink2)),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}
