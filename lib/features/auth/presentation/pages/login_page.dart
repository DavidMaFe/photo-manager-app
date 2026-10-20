import 'dart:math' as math;

import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/features/legal/presentation/widgets/legal_info_link.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager_app/core/errors/service/error_notification_service.dart';
import 'package:photo_manager_app/core/navigation/route_names.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:photo_manager_app/features/auth/presentation/widgets/login/login_actions.dart';
import 'package:photo_manager_app/features/auth/presentation/widgets/login/login_header.dart';
import 'package:photo_manager_app/features/auth/presentation/widgets/login/login_inputs.dart';
import 'package:photo_manager_app/features/auth/presentation/widgets/login/login_second_factor_step.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';


class LoginPage extends StatefulWidget {

  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final TextEditingController _emailInputController = TextEditingController();
  final TextEditingController _passwordInputController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailInputController.dispose();
    _passwordInputController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {

      final email = _emailInputController.text.trim();
      final password = _passwordInputController.text;
      context.read<AuthBloc>().add(
        LoginRequested(email: email, password: password)
      );
    }
  }

  void _handleForgotPassword() {
    context.go(RoutePaths.requestPasswordReset);
  }

  void _handleRegister() {
    context.go(RoutePaths.register);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ErrorNotificationService.showError(
            context,
            state.failure,
            config: ErrorDisplayConfig.snackBar,
            onRetry: () => _handleLogin(),
          );
        } else if (state is AuthSecondFactorRequired) {
          final failure = state.failure;
          if (failure != null) {
            ErrorNotificationService.showError(context, failure, config: ErrorDisplayConfig.snackBar);
          } else if (state.codeResent) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.codeResent)));
            context.read<AuthBloc>().add(LoginSecondFactorResentShown());
          }
        }
      },
      // The second factor replaces the form while it lasts: going back shows the form with the email typed
      builder: (context, state) => state is AuthSecondFactorRequired
          ? LoginSecondFactorStep(state: state)
          : _buildForm(context, isLoading: state is AuthLoading),
    );
  }

  Widget _buildForm(BuildContext context, {required bool isLoading}) {
    final insets = MediaQuery.paddingOf(context);

    return Scaffold(
      backgroundColor: context.palette.surface,
      body: SingleChildScrollView(
        // 88 from the top edge, safe area included.
        padding: EdgeInsets.fromLTRB(24, math.max(88, insets.top + 24), 24, insets.bottom + 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const LoginHeader(),
              const SizedBox(height: 24),
              LoginInputs(
                emailInputController: _emailInputController,
                passwordInputController: _passwordInputController,
                onForgotPassword: _handleForgotPassword,
                onSubmitted: _handleLogin,
                enabled: !isLoading,
              ),
              const SizedBox(height: 24),
              LoginActions(
                onLogin: _handleLogin,
                onRegister: _handleRegister,
                isLoading: isLoading,
              ),
              const SizedBox(height: 8),
              const LegalInfoLink(),
            ],
          ),
        ),
      ),
    );
  }
}
