import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/crypto/domain/recovery_phrase.dart';
import 'package:photo_manager_app/core/errors/base/failure_codes.dart';
import 'package:photo_manager_app/core/errors/service/error_notification_service.dart';
import 'package:photo_manager_app/core/navigation/route_names.dart';
import 'package:photo_manager_app/core/widgets/secondary_top_bar.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/registration_email_cubit.dart';
import 'package:photo_manager_app/features/auth/presentation/widgets/auth_title.dart';
import 'package:photo_manager_app/features/auth/presentation/widgets/password_reset/step_indicator.dart';
import 'package:photo_manager_app/features/auth/presentation/widgets/register/register_actions.dart';
import 'package:photo_manager_app/features/auth/presentation/widgets/register/register_inputs.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// Step 3 of the registration: the name, the password and the acceptance of the terms. The email was verified in the
/// first steps and is shown locked; its code goes with the registration, which spends it.
class RegisterDetailsStep extends StatefulWidget {
  final String email;
  final String emailCode;

  const RegisterDetailsStep({super.key, required this.email, required this.emailCode});

  @override
  State<RegisterDetailsStep> createState() => _RegisterDetailsStepState();
}

class _RegisterDetailsStepState extends State<RegisterDetailsStep> {
  final TextEditingController _nameInputController = TextEditingController();
  final TextEditingController _surnameInputController = TextEditingController();
  late final TextEditingController _emailInputController = TextEditingController(text: widget.email);
  final TextEditingController _passwordInputController = TextEditingController();
  final TextEditingController _confirmPasswordInputController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _acceptedLegalTerms = false;

  @override
  void dispose() {
    _nameInputController.dispose();
    _surnameInputController.dispose();
    _emailInputController.dispose();
    _passwordInputController.dispose();
    _confirmPasswordInputController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      final name = _nameInputController.text.trim();
      final surname = _surnameInputController.text.trim();

      context.read<AuthBloc>().add(
        RegisterRequested(
          email: widget.email,
          password: _passwordInputController.text,
          name: name,
          surname: surname.isEmpty ? null : surname,
          // The 24 recovery words are generated in the language of the app
          language: Localizations.localeOf(context).languageCode == 'es'
              ? RecoveryPhraseLanguage.spanish
              : RecoveryPhraseLanguage.english,
          acceptedLegalTerms: _acceptedLegalTerms,
          emailCode: widget.emailCode,
        ),
      );
    }
  }

  void _handleGoToLogin() => context.go(RoutePaths.login);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.palette.surface,
      appBar: SecondaryTopBar(
        onBack: context.read<RegistrationEmailCubit>().changeEmail,
        backgroundColor: context.palette.surface,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            // The code expired while the user filled this step: a new one is needed
            if (state.failure.code == FailureCodes.invalidEmailCode) {
              context.read<RegistrationEmailCubit>().codeRejected();
            }
            ErrorNotificationService.showError(
              context,
              state.failure,
              config: ErrorDisplayConfig.snackBar,
              onRetry: () => _handleRegister(),
            );
          }
          // RecoveryPhraseRequired: the router opens the page of the 24 words
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24, 8, 24, MediaQuery.paddingOf(context).bottom + 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: StepIndicator(current: 3, total: 3, semanticLabel: l10n.stepOf(3, 3)),
                  ),
                  const SizedBox(height: 16),
                  AuthTitle(title: l10n.registerHeadline, subtitle: l10n.registerSubtitle),
                  const SizedBox(height: 24),
                  RegisterInputs(
                    nameInputController: _nameInputController,
                    surnameInputController: _surnameInputController,
                    emailInputController: _emailInputController,
                    passwordInputController: _passwordInputController,
                    confirmPasswordInputController: _confirmPasswordInputController,
                    enabled: !isLoading,
                    emailLocked: true,
                  ),
                  const SizedBox(height: 20),
                  RegisterActions(
                    onRegister: _handleRegister,
                    onGoToLogin: _handleGoToLogin,
                    onLegalTermsChanged: (accepted) => _acceptedLegalTerms = accepted,
                    isLoading: isLoading,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
