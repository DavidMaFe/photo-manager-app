import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager_app/core/navigation/route_names.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:photo_manager_app/features/auth/presentation/widgets/password_reset/reset_password_actions.dart';
import 'package:photo_manager_app/features/auth/presentation/widgets/password_reset/reset_password_header.dart';
import 'package:photo_manager_app/features/auth/presentation/widgets/password_reset/reset_password_inputs.dart';
import '../../../../core/errors/service/error_notification_service.dart';
import '../../../../l10n/app_localizations.dart';


class ResetPasswordPage extends StatefulWidget {

  final String email;
  final String code;

  const ResetPasswordPage({
    super.key,
    required this.email,
    required this.code
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}


class _ResetPasswordPageState extends State<ResetPasswordPage> {

  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleResetPassword() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        NewPasswordSubmitted(
          email: widget.email,
          code: widget.code,
          newPassword: _newPasswordController.text
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is PasswordResetSuccessful) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.passwordResetSuccess),
                  backgroundColor: Colors.green
                )
              );
              Future.delayed(const Duration(milliseconds: 1500), () {
                if (context.mounted) {
                  context.go(RoutePaths.login);
                }
              });
            }

            if (state is AuthError) {
              ErrorNotificationService.showError(
                context,
                state.failure,
                onRetry: _handleResetPassword
              );
            }
          },

          builder: (context, state) {

            final isLoading = state is AuthLoading;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [

                    SizedBox(height: 40),

                    ResetPasswordHeader(),

                    SizedBox(height: 40),

                    ResetPasswordInputs(
                      newPasswordController: _newPasswordController,
                      confirmPasswordController: _confirmPasswordController,
                      enabled: !isLoading
                    ),

                    SizedBox(height: 32),

                    ResetPasswordActions(
                      onResetPassword: _handleResetPassword,
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