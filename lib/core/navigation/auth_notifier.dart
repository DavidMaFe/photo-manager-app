
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

  /// Just registered: the 24 words must be confirmed before the session starts.
  bool get isRecoveryPhrasePending => authBloc.state is RecoveryPhraseRequired;

  /// Logged in, but the terms of use and the privacy policy in force must be accepted first.
  bool get isLegalAcceptancePending => authBloc.state is AuthLegalAcceptanceRequired;

  /// Logged in to a locked account: the locked account page comes before the gallery.
  bool get isAccountLocked => authBloc.state is AuthAccountLocked;
}