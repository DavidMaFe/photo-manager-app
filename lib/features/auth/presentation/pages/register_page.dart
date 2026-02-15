
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager_app/core/errors/service/error_notification_service.dart';
import 'package:photo_manager_app/core/navigation/route_names.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

import '../bloc/auth_event.dart';
import '../widgets/register/register_actions.dart';
import '../widgets/register/register_header.dart';
import '../widgets/register/register_inputs.dart';

class RegisterPage extends StatefulWidget {

  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}


class _RegisterPageState extends State<RegisterPage> {

  final TextEditingController _nameInputController = TextEditingController();
  final TextEditingController _surnameInputController = TextEditingController();
  final TextEditingController _emailInputController = TextEditingController();
  final TextEditingController _passwordInputController = TextEditingController();
  final TextEditingController _confirmPasswordInputController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

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
      final email = _emailInputController.text.trim();
      final password = _passwordInputController.text;

      context.read<AuthBloc>().add(
        RegisterRequested(
          email: email,
          password: password,
          name: name,
          surname: surname.isEmpty ? null : surname,
        ),
      );
    }
  }

  void _handleGoToLogin() {
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
            if (state is AuthError) {
              ErrorNotificationService.showError(
                context,
                state.failure,
                config: ErrorDisplayConfig.snackBar,
                onRetry: () => _handleRegister()
              );
            } else if (state is RegisterSuccessful) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.accountCreated),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 3),
                  )
              );
              Future.delayed(const Duration(milliseconds: 500), () {
                if (context.mounted) {
                  context.go(RoutePaths.login);
                }
              });
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const Center(child: RegisterHeader()),
                    const SizedBox(height: 40),
                    RegisterInputs(
                      nameInputController: _nameInputController,
                      surnameInputController: _surnameInputController,
                      emailInputController: _emailInputController,
                      passwordInputController: _passwordInputController,
                      confirmPasswordInputController: _confirmPasswordInputController,
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 24),
                    RegisterActions(
                      onRegister: _handleRegister,
                      onGoToLogin: _handleGoToLogin,
                      isLoading: isLoading,
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}