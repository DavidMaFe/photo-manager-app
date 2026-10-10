import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/core/crypto/domain/recovery_phrase.dart';
import 'package:photo_manager_app/core/injection_container.dart';
import 'package:photo_manager_app/core/navigation/route_names.dart';
import 'package:photo_manager_app/core/widgets/list_row.dart';
import 'package:photo_manager_app/core/widgets/section_label.dart';
import 'package:photo_manager_app/features/account_security/domain/use_cases/recovery_phrase_use_cases.dart';
import 'package:photo_manager_app/features/account_security/presentation/pages/recovery_phrase_page.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// Security options of the profile: the 24 words, the password reset from this device and the locked photos.
class SecuritySection extends StatelessWidget {
  final String email;
  final GetRecoveryWordsUseCase? getRecoveryWordsUseCase;

  const SecuritySection({super.key, required this.email, this.getRecoveryWordsUseCase});

  Future<void> _showWords(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final language = Localizations.localeOf(context).languageCode == 'es'
        ? RecoveryPhraseLanguage.spanish
        : RecoveryPhraseLanguage.english;
    final words = await (getRecoveryWordsUseCase ?? sl<GetRecoveryWordsUseCase>())(language);
    if (!context.mounted) return;

    if (words == null) {
      // This device did not create the key: verifying the words keeps a copy here
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.recoveryPhraseNotOnDevice)));
      context.goNamed(RouteNames.verifyRecoveryWords);
      return;
    }
    context.goNamed(RouteNames.recoveryWords,
        extra: RecoveryPhraseArgs(words: words, email: email, flow: RecoveryPhraseFlow.view));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionLabel(l10n.profileSecuritySection),
        ListRowGroup(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            ListRow(
              key: const ValueKey('security-recovery-words'),
              icon: Symbols.key_rounded,
              title: l10n.profileRecoveryWords,
              onTap: () => _showWords(context),
            ),
            ListRow(
              key: const ValueKey('security-verify-words'),
              icon: Symbols.fact_check_rounded,
              title: l10n.profileVerifyWords,
              onTap: () => context.goNamed(RouteNames.verifyRecoveryWords),
            ),
            ListRow(
              key: const ValueKey('security-forgot-password'),
              icon: Symbols.lock_reset_rounded,
              title: l10n.profileForgotPassword,
              onTap: () => context.goNamed(RouteNames.forgotPassword),
            ),
            ListRow(
              key: const ValueKey('security-locked-photos'),
              icon: Symbols.lock_open_rounded,
              title: l10n.profileLockedPhotos,
              onTap: () => context.goNamed(RouteNames.lockedPhotos),
            ),
          ],
        ),
      ],
    );
  }
}
