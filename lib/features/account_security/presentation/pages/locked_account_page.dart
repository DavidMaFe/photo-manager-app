import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/crypto/domain/recovery_phrase.dart';
import 'package:photo_manager_app/core/errors/service/error_notification_service.dart';
import 'package:photo_manager_app/core/navigation/route_names.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/core/widgets/app_dialog.dart';
import 'package:photo_manager_app/features/account_security/presentation/bloc/locked_account_bloc.dart';
import 'package:photo_manager_app/features/account_security/presentation/pages/recovery_phrase_page.dart';
import 'package:photo_manager_app/features/account_security/presentation/widgets/password_prompt_dialog.dart';
import 'package:photo_manager_app/features/auth/domain/entities/user.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// Recover the locked photos (docs/e2ee-spec.md, section 8.6). Shown after logging in to a locked account, and from
/// the profile when some old key versions are still locked. Nothing is ever deleted.
class LockedAccountPage extends StatelessWidget {
  final User user;

  /// True right after logging in to a locked account: the gallery opens when a key becomes usable.
  final bool afterLogin;

  const LockedAccountPage({super.key, required this.user, required this.afterLogin});

  RecoveryPhraseLanguage _language(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'es' ? RecoveryPhraseLanguage.spanish : RecoveryPhraseLanguage.english;

  Future<void> _unlockWithWords(BuildContext context) async {
    final prompt = await PasswordPromptDialog.show(context, askRecoveryWords: true);
    if (prompt != null && context.mounted) {
      context.read<LockedAccountBloc>().add(UnlockWithWordsRequested(password: prompt.password, words: prompt.words));
    }
  }

  Future<void> _unlockWithDevice(BuildContext context) async {
    final prompt = await PasswordPromptDialog.show(context);
    if (prompt != null && context.mounted) {
      context.read<LockedAccountBloc>().add(UnlockWithDeviceRequested(password: prompt.password));
    }
  }

  Future<void> _newKey(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await AppDialog.show(
      context: context,
      tone: AppDialogTone.review,
      icon: Symbols.key_rounded,
      title: l10n.lockedNewKeyConfirmTitle,
      message: l10n.lockedNewKeyConfirmMessage,
      primaryLabel: l10n.continueLabel,
      secondaryLabel: l10n.cancel,
    );
    if (confirmed != true || !context.mounted) return;
    final prompt = await PasswordPromptDialog.show(context);
    if (prompt != null && context.mounted) {
      context.read<LockedAccountBloc>().add(NewKeyRequested(password: prompt.password, language: _language(context)));
    }
  }

  void _onState(BuildContext context, LockedAccountState state) {
    final l10n = AppLocalizations.of(context)!;
    if (state is LockedAccountError) {
      ErrorNotificationService.showError(context, state.failure, config: ErrorDisplayConfig.snackBar);
    } else if (state is LockedAccountUnlocked) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.lockedUnlocked)));
      if (afterLogin && state.accountUsable) {
        context.read<AuthBloc>().add(AccountUnlocked(user));
      } else {
        context.read<LockedAccountBloc>().add(LockedAccountStatusRequested());
      }
    } else if (state is LockedAccountNewKeyCreated) {
      context.go(RoutePaths.recoveryPhrase,
          extra: RecoveryPhraseArgs(words: state.words, email: user.email, flow: RecoveryPhraseFlow.newKey, user: user));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = context.palette;
    return BlocConsumer<LockedAccountBloc, LockedAccountState>(
      listener: _onState,
      builder: (context, state) {
        final status = switch (state) {
          LockedAccountLoaded(:final status) => status,
          LockedAccountError(:final status) => status,
          _ => null,
        };
        final working = state is LockedAccountLoaded && state.working;
        final canUseDevice = status?.versionsHeldOnDevice.isNotEmpty ?? false;
        final canCreateKey = status?.keys.accountLocked ?? false;

        return Scaffold(
          backgroundColor: palette.surface,
          appBar: afterLogin ? null : AppBar(backgroundColor: palette.surface),
          body: SafeArea(
            child: state is LockedAccountLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(Symbols.lock_rounded, size: 48, color: palette.reviewIcon),
                        const SizedBox(height: 16),
                        Text(l10n.lockedTitle,
                            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: palette.ink)),
                        const SizedBox(height: 8),
                        Text(l10n.lockedMessage, style: TextStyle(fontSize: 15, color: palette.ink2)),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: palette.safeSoft, borderRadius: BorderRadius.circular(12)),
                          child: Text(l10n.lockedPhotosKept, style: TextStyle(color: palette.safeInk)),
                        ),
                        const SizedBox(height: 24),
                        if (status != null && !status.hasLockedVersions && !afterLogin)
                          Text(l10n.lockedNone,
                              key: const ValueKey('locked-none'), style: TextStyle(color: palette.ink2, fontSize: 15))
                        else ...[
                          AppButton.primary(
                            key: const ValueKey('locked-use-words'),
                            label: l10n.lockedUseWords,
                            icon: Symbols.key_rounded,
                            loading: working,
                            onPressed: working ? null : () => _unlockWithWords(context),
                          ),
                          if (canUseDevice) ...[
                            const SizedBox(height: 10),
                            AppButton.secondary(
                              key: const ValueKey('locked-use-device'),
                              label: l10n.lockedUseDevice,
                              icon: Symbols.smartphone_rounded,
                              onPressed: working ? null : () => _unlockWithDevice(context),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(l10n.lockedUseDeviceSubtitle, style: TextStyle(color: palette.ink3, fontSize: 13)),
                            ),
                          ],
                          if (canCreateKey) ...[
                            const SizedBox(height: 10),
                            AppButton.neutral(
                              key: const ValueKey('locked-new-key'),
                              label: l10n.lockedNewKey,
                              onPressed: working ? null : () => _newKey(context),
                            ),
                          ],
                        ],
                        if (afterLogin) ...[
                          const SizedBox(height: 24),
                          AppButton.text(
                            key: const ValueKey('locked-logout'),
                            label: l10n.logoutButton,
                            onPressed: () => context.read<AuthBloc>().add(LogoutRequested()),
                          ),
                        ],
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}
