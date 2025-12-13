
import 'package:flutter/material.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_state.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';

class AuthNotifier extends ChangeNotifier {

  final AuthBloc authBloc;

  AuthNotifier(this.authBloc) {
    authBloc.stream.listen((state) {
      notifyListeners();
    });
  }

  bool get isAuthenticated {
    final result = authBloc.state is AuthSuccessful;
    return result;
  }

  bool get isLoading => authBloc.state is AuthLoading;
}