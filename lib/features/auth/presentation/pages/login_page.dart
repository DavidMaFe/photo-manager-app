
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:photo_manager_app/features/auth/presentation/widgets/login/login_actions.dart';
import 'package:photo_manager_app/features/auth/presentation/widgets/login/login_header.dart';
import 'package:photo_manager_app/features/auth/presentation/widgets/login/login_inputs.dart';


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
    print("Forgot password pressed");
  }

  void _handleRegister() {
    print("Register pressed");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
               if (state is AuthError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    )
                  );
                }
              },
              builder: (context, state) {
                final isLoading = state is AuthLoading;

                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        Center(child: LoginHeader()),
                        SizedBox(height: 40),
                        LoginInputs(
                          emailInputController: _emailInputController,
                          passwordInputController: _passwordInputController,
                          enabled: !isLoading,
                        ),
                        SizedBox(height: 48),
                        LoginActions(
                            onLogin: _handleLogin,
                            onForgotPassword: _handleForgotPassword,
                            onRegister: _handleRegister,
                            isLoading: isLoading,
                        )
                      ],
                    ),
                  )
                );
              }
            )
        )
    );
  }
}