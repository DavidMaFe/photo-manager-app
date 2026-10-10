import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/errors/service/error_notification_service.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:photo_manager_app/features/legal/presentation/widgets/legal_acceptance_checkbox.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// After logging in, when the terms of use and the privacy policy in force have not been accepted (accounts created
/// before them, or a new version). The session does not start until they are accepted.
class LegalAcceptancePage extends StatefulWidget {
  const LegalAcceptancePage({super.key});

  @override
  State<LegalAcceptancePage> createState() => _LegalAcceptancePageState();
}

class _LegalAcceptancePageState extends State<LegalAcceptancePage> {
  final _formKey = GlobalKey<FormState>();

  void _accept() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(LegalTermsAccepted());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = context.palette;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        final failure = state is AuthLegalAcceptanceRequired ? state.failure : null;
        if (failure != null) {
          ErrorNotificationService.showError(context, failure, config: ErrorDisplayConfig.snackBar, onRetry: _accept);
        }
      },
      builder: (context, state) {
        final working = state is AuthLegalAcceptanceRequired && state.working;
        return PopScope(
          canPop: false,
          child: Scaffold(
            backgroundColor: palette.surface,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(Symbols.gavel_rounded, size: 48, color: palette.accent),
                      const SizedBox(height: 16),
                      Text(l10n.legalAcceptanceTitle,
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: palette.ink)),
                      const SizedBox(height: 8),
                      Text(l10n.legalAcceptanceMessage, style: TextStyle(fontSize: 15, color: palette.ink2)),
                      const SizedBox(height: 20),
                      LegalAcceptanceCheckbox(enabled: !working),
                      const SizedBox(height: 20),
                      AppButton.primary(
                        key: const ValueKey('legal-accept-button'),
                        label: l10n.legalAcceptanceButton,
                        loading: working,
                        onPressed: working ? null : _accept,
                      ),
                      const SizedBox(height: 12),
                      AppButton.text(
                        key: const ValueKey('legal-logout'),
                        label: l10n.logoutButton,
                        onPressed: working ? null : () => context.read<AuthBloc>().add(LogoutRequested()),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
