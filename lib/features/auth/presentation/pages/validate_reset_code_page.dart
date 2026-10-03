import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager_app/core/navigation/route_names.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:photo_manager_app/features/auth/presentation/widgets/password_reset/validate_code_actions.dart';
import 'package:photo_manager_app/features/auth/presentation/widgets/password_reset/validate_code_header.dart';
import 'package:photo_manager_app/features/auth/presentation/widgets/password_reset/validate_code_inputs.dart';
import '../../../../core/errors/service/error_notification_service.dart';
import '../../../../l10n/app_localizations.dart';


class ValidateResetCodePage extends StatefulWidget {

  final String email;

  const ValidateResetCodePage({super.key, required this.email});

  @override
  State<ValidateResetCodePage> createState() => _ValidateResetCodePageState();
}


class _ValidateResetCodePageState extends State<ValidateResetCodePage> {

  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _handleValidateCode() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        ResetCodeValidationRequested(
          email: widget.email,
          code: _codeController.text.trim()
        )
      );
    }
  }

  void _handleResendCode() {
    context.read<AuthBloc>().add(
      PasswordResetCodeResendRequested(email: widget.email)
    );
  }

  void _handleBack() {
    context.go(RoutePaths.login);
  }

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.palette.surface,
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is ResetCodeValidated) {
              Future.delayed(const Duration(milliseconds: 500), () {
                if (context.mounted) {
                  context.go(RoutePaths.resetPassword, extra: {
                    'email': state.email,
                    'code': state.code,
                  });
                }
              });
            }

            if (state is PasswordResetEmailSent) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.codeResent),
                  backgroundColor: context.palette.safe
                )
              );
            }

            if (state is AuthError) {
              ErrorNotificationService.showError(
                context,
                state.failure,
                onRetry: _handleValidateCode
              );
            }
          },

          builder: (context, state) {

            final isLoading = state is AuthLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [

                    const SizedBox(height: 40),

                    ValidateCodeHeader(email: widget.email),

                    const SizedBox(height: 40),

                    ValidateCodeInputs(
                      codeInputController: _codeController,
                      enabled: !isLoading
                    ),

                    const SizedBox(height: 32),

                    ValidateCodeActions(
                      onValidateCode: _handleValidateCode,
                      onResendCode: _handleResendCode,
                      onBack: _handleBack,
                      isLoading: isLoading
                    )
                  ],
                ),
              ),
            );
          }
        ),
      ),
    );
  }
}