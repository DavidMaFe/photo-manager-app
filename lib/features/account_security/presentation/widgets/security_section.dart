import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/core/crypto/domain/recovery_phrase.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/errors/helper/failure_message_helper.dart';
import 'package:photo_manager_app/core/injection_container.dart';
import 'package:photo_manager_app/core/navigation/route_names.dart';
import 'package:photo_manager_app/core/widgets/list_row.dart';
import 'package:photo_manager_app/core/widgets/section_label.dart';
import 'package:photo_manager_app/features/account_security/domain/use_cases/recovery_phrase_use_cases.dart';
import 'package:photo_manager_app/features/account_security/presentation/pages/recovery_phrase_page.dart';
import 'package:photo_manager_app/features/account_security/presentation/widgets/password_prompt_dialog.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// Security options of the profile: the authenticator app, the 24 words, the password reset from this device and the
/// locked photos.
class SecuritySection extends StatelessWidget {
  final String email;
  final GetRecoveryWordsUseCase? getRecoveryWordsUseCase;

  const SecuritySection({super.key, required this.email, this.getRecoveryWordsUseCase});

  /// The fingerprint or PIN prompt pauses and resumes the app, and the resume rebuilds the profile (the plan is
  /// loaded again): this widget may be gone when the prompt closes. The router, the messenger and the texts are taken
  /// before it, so the words still open.
  Future<void> _showWords(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final useCase = getRecoveryWordsUseCase ?? sl<GetRecoveryWordsUseCase>();
    final language = Localizations.localeOf(context).languageCode == 'es'
        ? RecoveryPhraseLanguage.spanish
        : RecoveryPhraseLanguage.english;

    if (!await useCase.hasWords()) {
      // This device did not create the key: verifying the words keeps a copy here
      messenger.showSnackBar(SnackBar(content: Text(l10n.recoveryPhraseNotOnDevice)));
      router.goNamed(RouteNames.verifyRecoveryWords);
      return;
    }

    // The words open the photos for good: the owner proves who they are first
    String? password;
    if (await useCase.needsPassword()) {
      if (!context.mounted) return;
      final typed = await PasswordPromptDialog.show(context,
          title: l10n.recoveryWordsPasswordTitle, message: l10n.recoveryWordsPasswordBody);
      if (typed == null) return;
      password = typed.password;
    }

    final List<String>? words;
    try {
      words = await useCase(language, reason: l10n.recoveryWordsAuthReason, password: password);
    } on Failure catch (failure) {
      messenger.showSnackBar(SnackBar(content: Text(FailureMessageHelper.messageFor(l10n, failure))));
      return;
    }
    if (words == null) return;
    router.goNamed(RouteNames.recoveryWords,
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
              key: const ValueKey('security-two-factor'),
              icon: Symbols.verified_user_rounded,
              title: l10n.profileTwoFactor,
              onTap: () => context.goNamed(RouteNames.twoFactor),
            ),
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
