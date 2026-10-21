import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/core/widgets/secure_screen_guard.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/features/two_factor/domain/services/two_factor_exporter.dart';
import 'package:photo_manager_app/features/two_factor/presentation/bloc/two_factor_cubit.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// The backup codes just issued, the only time they are shown: copy them, share them, and confirm they are saved.
class BackupCodesView extends StatelessWidget {
  final List<String> codes;
  final TwoFactorExporter exporter;

  const BackupCodesView({super.key, required this.codes, required this.exporter});

  String _asText(AppLocalizations l10n) => '${l10n.twoFactorShareText}\n\n${codes.join('\n')}';

  Future<void> _copy(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: _asText(l10n)));
    messenger.showSnackBar(SnackBar(content: Text(l10n.twoFactorCodesCopied)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;

    return SecureScreenGuard(
        // Secrets on screen: no screenshots, recordings or recent apps preview
        child: ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      children: [
        Text(l10n.twoFactorBackupCodesTitle, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: p.ink)),
        const SizedBox(height: 8),
        Text(l10n.twoFactorBackupCodesBody, style: TextStyle(fontSize: 15, height: 1.45, color: p.ink2)),
        const SizedBox(height: 20),
        Container(
          key: const ValueKey('two-factor-backup-codes'),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14)),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 24,
            runSpacing: 12,
            children: [
              for (final code in codes)
                SizedBox(
                  width: 120,
                  child: Text(
                    code,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: p.ink,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AppButton.secondary(
                key: const ValueKey('two-factor-copy-codes'),
                label: l10n.twoFactorCopyCodes,
                icon: Symbols.content_copy_rounded,
                onPressed: () => _copy(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton.secondary(
                key: const ValueKey('two-factor-share-codes'),
                label: l10n.twoFactorShareCodes,
                icon: Symbols.share_rounded,
                onPressed: () => exporter.shareBackupCodes(_asText(l10n)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        AppButton.primary(
          key: const ValueKey('two-factor-codes-saved'),
          label: l10n.twoFactorCodesSaved,
          onPressed: () => context.read<TwoFactorCubit>().backupCodesSaved(),
        ),
      ],
    ));
  }
}
