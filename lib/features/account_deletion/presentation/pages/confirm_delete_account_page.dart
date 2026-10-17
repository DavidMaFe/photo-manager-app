import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/errors/base/failure_codes.dart';
import 'package:photo_manager_app/core/errors/service/error_notification_service.dart';
import 'package:photo_manager_app/core/navigation/route_names.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/core/widgets/app_card.dart';
import 'package:photo_manager_app/core/widgets/app_password_field.dart';
import 'package:photo_manager_app/core/widgets/app_text_field.dart';
import 'package:photo_manager_app/features/account_deletion/presentation/bloc/delete_account_bloc.dart';
import 'package:photo_manager_app/features/account_deletion/presentation/widgets/delete_account_header.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// Second step of the account deletion: the password and the confirmation word. The account is deleted at once.
class ConfirmDeleteAccountPage extends StatefulWidget {
  const ConfirmDeleteAccountPage({super.key});

  @override
  State<ConfirmDeleteAccountPage> createState() => _ConfirmDeleteAccountPageState();
}

class _ConfirmDeleteAccountPageState extends State<ConfirmDeleteAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _wordController = TextEditingController();
  bool _passwordRejected = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onChanged);
    _wordController.addListener(_onChanged);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _wordController.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  bool _wordMatches(AppLocalizations l10n) =>
      _wordController.text.trim().toUpperCase() == l10n.deleteAccountConfirmWord.toUpperCase();

  void _submit() {
    setState(() => _passwordRejected = false);
    context.read<DeleteAccountBloc>().add(DeleteAccountSubmitted(password: _passwordController.text));
  }

  void _onState(BuildContext context, DeleteAccountState state, AppLocalizations l10n) {
    if (state is DeleteAccountSuccess) {
      // The messenger of the app outlives this page, so the message is still shown on the login
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.deleteAccountDone)));
      context.read<AuthBloc>().add(AccountDeleted());
    } else if (state is DeleteAccountError) {
      if (state.failure.code == FailureCodes.incorrectPassword) {
        setState(() => _passwordRejected = true);
        _formKey.currentState?.validate();
      } else {
        ErrorNotificationService.showError(context, state.failure, config: ErrorDisplayConfig.snackBar);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;
    final word = l10n.deleteAccountConfirmWord;

    return BlocConsumer<DeleteAccountBloc, DeleteAccountState>(
      listener: (context, state) => _onState(context, state, l10n),
      builder: (context, state) {
        final loading = state is DeleteAccountLoading || state is DeleteAccountSuccess;
        final canSubmit = !loading && _passwordController.text.isNotEmpty && _wordMatches(l10n);
        return Scaffold(
          backgroundColor: p.background,
          appBar: DeleteAccountTopBar(step: 2, onBack: () => context.pop()),
          body: SafeArea(
            top: false,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          DeleteAccountHeading(
                            step: 2,
                            title: l10n.deleteAccountConfirmTitle,
                            subtitle: _subtitle(l10n, p, word),
                          ),
                          const SizedBox(height: 24),
                          AppPasswordField(
                            key: const ValueKey('delete-account-password'),
                            controller: _passwordController,
                            label: l10n.passwordLabel,
                            enabled: !loading,
                            autofillHints: const [AutofillHints.password],
                            validator: (_) => _passwordRejected ? l10n.deleteAccountWrongPassword : null,
                            onChanged: (_) {
                              if (_passwordRejected) {
                                setState(() => _passwordRejected = false);
                                _formKey.currentState?.validate();
                              }
                            },
                            showTooltip: l10n.showPassword,
                            hideTooltip: l10n.hidePassword,
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            key: const ValueKey('delete-account-word'),
                            controller: _wordController,
                            label: l10n.deleteAccountTypeWord(word),
                            hintText: word,
                            enabled: !loading,
                            textCapitalization: TextCapitalization.characters,
                            suffixIcon: _wordMatches(l10n)
                                ? Icon(Symbols.check_circle_rounded, fill: 1, color: p.danger)
                                : null,
                          ),
                          const SizedBox(height: 16),
                          AppCard(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Symbols.info_rounded, size: 20, color: p.ink2),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(l10n.deleteAccountFinalNote,
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: p.ink2)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppButton.dangerSolid(
                        key: const ValueKey('delete-account-submit'),
                        label: l10n.deleteAccountSubmit,
                        icon: Symbols.person_remove_rounded,
                        loading: loading,
                        onPressed: canSubmit ? _submit : null,
                      ),
                      const SizedBox(height: 4),
                      AppButton.text(
                        key: const ValueKey('delete-account-keep'),
                        label: l10n.deleteAccountKeep,
                        onPressed: loading ? null : () => context.goNamed(RouteNames.profile),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// The subtitle with the confirmation word in bold.
  Widget _subtitle(AppLocalizations l10n, AppPalette p, String word) {
    final text = l10n.deleteAccountConfirmSubtitle(word);
    final start = text.indexOf(word);
    if (start < 0) return Text(text);
    return Text.rich(TextSpan(children: [
      TextSpan(text: text.substring(0, start)),
      TextSpan(text: word, style: TextStyle(fontWeight: FontWeight.w800, color: p.ink)),
      TextSpan(text: text.substring(start + word.length)),
    ]));
  }
}
