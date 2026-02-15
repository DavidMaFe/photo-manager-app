import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager_app/core/navigation/route_names.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:photo_manager_app/features/auth/presentation/widgets/password_reset/request_reset_actions.dart';
import 'package:photo_manager_app/features/auth/presentation/widgets/password_reset/request_reset_header.dart';
import 'package:photo_manager_app/features/auth/presentation/widgets/password_reset/request_reset_inputs.dart';
import '../../../../core/errors/service/error_notification_service.dart';
import '../../../../l10n/app_localizations.dart';

class RequestPasswordResetPage extends StatefulWidget {

  const RequestPasswordResetPage({super.key});

  @override
  State<RequestPasswordResetPage> createState() => _RequestPasswordResetPageState();
}


class _RequestPasswordResetPageState extends State<RequestPasswordResetPage> {

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSendCode() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        PasswordResetRequested(email: _emailController.text.trim())
      );
    }
  }

  void _handleBackToLogin() {
    context.go(RoutePaths.login);
  }

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is PasswordResetEmailSent) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.emailSentSuccess),
                  backgroundColor: Colors.green
                )
              );
              Future.delayed(const Duration(milliseconds: 500), () {
                if (context.mounted) {
                  context.go(RoutePaths.validateResetCode, extra: state.email);
                }
              });
            }

            if (state is AuthError) {
              ErrorNotificationService.showError(
                context,
                state.failure,
                onRetry: _handleSendCode
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

                    const RequestResetHeader(),

                    const SizedBox(height: 40),

                    RequestResetInputs(
                      emailInputController: _emailController,
                      enabled: !isLoading
                    ),

                    const SizedBox(height: 32),

                    RequestResetActions(
                      onSendCode: _handleSendCode,
                      onBackToLogin: _handleBackToLogin,
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