import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/navigation/route_names.dart';
import 'package:photo_manager_app/core/widgets/app_text_field.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/registration_email_cubit.dart';
import 'package:photo_manager_app/features/auth/presentation/utils/auth_validators.dart';
import 'package:photo_manager_app/features/auth/presentation/widgets/password_reset/password_reset_layout.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// Step 1 of the registration: the email. An email that already has an account is told here, with a way to log in.
class RegisterEmailStep extends StatefulWidget {
  const RegisterEmailStep({super.key});

  @override
  State<RegisterEmailStep> createState() => _RegisterEmailStepState();
}

class _RegisterEmailStepState extends State<RegisterEmailStep> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController =
      TextEditingController(text: context.read<RegistrationEmailCubit>().state.email);

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSendCode() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<RegistrationEmailCubit>().sendCode(_emailController.text);
    }
  }

  void _handleGoToLogin() => context.go(RoutePaths.login);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = context.palette;
    final state = context.watch<RegistrationEmailCubit>().state;

    return PasswordResetLayout(
      step: 1,
      icon: Symbols.mail_rounded,
      title: l10n.registerHeadline,
      description: l10n.registerEmailBody,
      primaryLabel: l10n.sendCodeButton,
      onPrimary: _handleSendCode,
      isLoading: state.loading,
      onBack: _handleGoToLogin,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: l10n.emailLabel,
              controller: _emailController,
              hintText: l10n.emailPlaceholder,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.email],
              enabled: !state.loading,
              validator: (value) => AuthValidators.email(l10n, value),
            ),
            if (state.emailTaken) ...[
              const SizedBox(height: 12),
              Row(
                key: const ValueKey('register-email-taken'),
                children: [
                  Expanded(
                    child: Text(l10n.registerEmailTaken,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: palette.dangerInk)),
                  ),
                  TextButton(onPressed: _handleGoToLogin, child: Text(l10n.loginButton)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
