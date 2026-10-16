import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/config/theme/app_radius.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/core/widgets/icon_circle_button.dart';
import 'package:photo_manager_app/features/downloads/presentation/bloc/download_progress_bloc.dart';
import 'package:photo_manager_app/features/downloads/presentation/bloc/download_progress_event.dart';
import 'package:photo_manager_app/features/downloads/presentation/bloc/download_progress_state.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// Card above the navigation bar while files are saved to this phone («Saving to this phone · 48 of 111», album and
/// time left, Cancel), and once they are saved until it is closed. Nothing when there is no download.
class DownloadProgressCard extends StatelessWidget {
  const DownloadProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DownloadProgressBloc, DownloadProgressState>(
      buildWhen: (previous, current) =>
          previous.progress != current.progress ||
          previous.remaining != current.remaining ||
          previous.dismissed != current.dismissed,
      builder: (context, state) => AnimatedSize(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.bottomCenter,
        child: state.isVisible ? _Card(state: state) : const SizedBox(width: double.infinity),
      ),
    );
  }

  /// «2 min», «less than 1 min».
  static String formatRemaining(Duration remaining, AppLocalizations l10n) =>
      remaining.inSeconds < 60 ? l10n.durationLessThanMinute : l10n.durationMinutes((remaining.inSeconds / 60).round());
}

class _Card extends StatelessWidget {
  final DownloadProgressState state;

  const _Card({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;
    final progress = state.progress;
    final done = progress.saved + progress.failed;
    final running = state.isRunning;

    final title = running
        ? l10n.downloadProgressTitle(done, progress.total)
        : l10n.downloadProgressFinished(progress.saved);
    final details = [
      if (running) progress.currentAlbum ?? l10n.downloadProgressMainAlbum,
      if (running && state.remaining != null)
        l10n.downloadProgressRemaining(DownloadProgressCard.formatRemaining(state.remaining!, l10n)),
      if (progress.failed > 0) l10n.downloadProgressFailed(progress.failed),
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Material(
        color: p.surface,
        elevation: 0,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: p.lineSoft),
            boxShadow: [BoxShadow(color: p.shadowSoft, blurRadius: 18, offset: const Offset(0, 6))],
          ),
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: p.accentSoft, borderRadius: BorderRadius.circular(12)),
                    child: Icon(running ? Symbols.download_rounded : Symbols.download_done_rounded,
                        color: p.accent, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            maxLines: 2,
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: p.ink)),
                        if (details.isNotEmpty)
                          Text(details,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: p.ink2)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  running
                      ? AppButton.neutral(
                          label: l10n.cancel,
                          size: AppButtonSize.small,
                          onPressed: () => context.read<DownloadProgressBloc>().add(const DownloadCancelRequested()),
                        )
                      : IconCircleButton(
                          icon: Symbols.close_rounded,
                          tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                          onPressed: () =>
                              context.read<DownloadProgressBloc>().add(const DownloadProgressDismissed()),
                        ),
                ],
              ),
              if (running) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: LinearProgressIndicator(
                    value: progress.total == 0 ? null : done / progress.total,
                    minHeight: 6,
                    color: p.accent,
                    backgroundColor: p.accentSoft,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
