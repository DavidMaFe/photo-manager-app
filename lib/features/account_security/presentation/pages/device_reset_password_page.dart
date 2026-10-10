import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/errors/service/error_notification_service.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/core/widgets/app_password_field.dart';
import 'package:photo_manager_app/core/widgets/secondary_top_bar.dart';
import 'package:photo_manager_app/features/account_security/presentation/bloc/device_reset_password_bloc.dart';
import 'package:photo_manager_app/features/auth/presentation/utils/auth_validators.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// "I forgot my password" from the profile, on a device with an open session (docs/e2ee-spec.md, section 8.5).
class DeviceResetPasswordPage extends StatefulWidget {
  const DeviceResetPasswordPage({super.key});

  @override
  State<DeviceResetPasswordPage> createState() => _DeviceResetPasswordPageState();
}

class _DeviceResetPasswordPageState extends State<DeviceResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final l10n = AppLocalizations.of(context)!;
      context.read<DeviceResetPasswordBloc>()
          .add(DeviceResetPasswordSubmitted(newPassword: _passwordController.text, reason: l10n.deviceResetReason));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = context.palette;
    return BlocConsumer<DeviceResetPasswordBloc, DeviceResetPasswordState>(
      listener: (context, state) {
        if (state is DeviceResetPasswordError) {
          ErrorNotificationService.showError(context, state.failure, config: ErrorDisplayConfig.snackBar);
        } else if (state is DeviceResetPasswordSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.deviceResetSuccess)));
          context.pop();
        }
      },
      builder: (context, state) {
        final loading = state is DeviceResetPasswordLoading;
        return Scaffold(
          backgroundColor: palette.surface,
          appBar: SecondaryTopBar(onBack: () => context.pop(), backgroundColor: palette.surface),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.deviceResetTitle,
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: palette.ink)),
                  const SizedBox(height: 8),
                  Text(l10n.deviceResetSubtitle, style: TextStyle(fontSize: 15, color: palette.ink2)),
                  const SizedBox(height: 20),
                  AppPasswordField(
                    key: const ValueKey('device-reset-password'),
                    controller: _passwordController,
                    label: l10n.newPasswordLabel,
                    enabled: !loading,
                    autofillHints: const [AutofillHints.newPassword],
                    validator: (value) => AuthValidators.newPassword(l10n, value),
                    showTooltip: l10n.showPassword,
                    hideTooltip: l10n.hidePassword,
                  ),
                  const SizedBox(height: 12),
                  AppPasswordField(
                    key: const ValueKey('device-reset-confirm'),
                    controller: _confirmController,
                    label: l10n.confirmPasswordLabel,
                    enabled: !loading,
                    autofillHints: const [AutofillHints.newPassword],
                    validator: (value) => AuthValidators.confirmation(l10n, value, _passwordController.text),
                    showTooltip: l10n.showPassword,
                    hideTooltip: l10n.hidePassword,
                  ),
                  const SizedBox(height: 20),
                  AppButton.primary(
                    key: const ValueKey('device-reset-submit'),
                    label: l10n.deviceResetSubmit,
                    loading: loading,
                    onPressed: loading ? null : _submit,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
