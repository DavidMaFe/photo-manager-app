import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/core/widgets/list_row.dart';
import 'package:photo_manager_app/features/two_factor/domain/entities/two_factor_status.dart';
import 'package:photo_manager_app/features/two_factor/presentation/bloc/two_factor_cubit.dart';
import 'package:photo_manager_app/features/two_factor/presentation/widgets/password_and_code_dialog.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// Whether the authenticator app is on: turn it on, or (when it is) new backup codes and turn it off.
class TwoFactorStatusView extends StatelessWidget {
  final TwoFactorStatus status;
  final bool working;

  const TwoFactorStatusView({super.key, required this.status, required this.working});

  Future<void> _disable(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<TwoFactorCubit>();
    final input = await PasswordAndCodeDialog.show(context, title: l10n.twoFactorPromptDisableTitle, destructive: true);
    if (input != null) {
      await cubit.disable(password: input.password, code: input.code);
    }
  }

  Future<void> _regenerate(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<TwoFactorCubit>();
    final input = await PasswordAndCodeDialog.show(context, title: l10n.twoFactorPromptRegenerateTitle);
    if (input != null) {
      await cubit.regenerate(password: input.password, code: input.code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;
    final enabled = status.totpEnabled;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            enabled ? l10n.twoFactorOnBody : l10n.twoFactorOffBody,
            style: TextStyle(fontSize: 15, height: 1.45, color: p.ink2),
          ),
        ),
        const SizedBox(height: 20),
        ListRowGroup(
          children: [
            ListRow(
              key: const ValueKey('two-factor-status'),
              icon: enabled ? Symbols.verified_user_rounded : Symbols.shield_rounded,
              title: l10n.twoFactorTitle,
              value: enabled ? l10n.twoFactorStatusOn : l10n.twoFactorStatusOff,
              subtitle: enabled ? l10n.twoFactorBackupCodesLeft(status.backupCodesLeft) : null,
              showChevron: false,
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (!enabled)
          AppButton.primary(
            key: const ValueKey('two-factor-enable'),
            label: l10n.twoFactorEnable,
            loading: working,
            onPressed: working ? null : () => context.read<TwoFactorCubit>().startSetUp(),
          )
        else ...[
          AppButton.secondary(
            key: const ValueKey('two-factor-regenerate'),
            label: l10n.twoFactorRegenerate,
            onPressed: working ? null : () => _regenerate(context),
          ),
          const SizedBox(height: 12),
          AppButton.danger(
            key: const ValueKey('two-factor-disable'),
            label: l10n.twoFactorDisable,
            loading: working,
            onPressed: working ? null : () => _disable(context),
          ),
        ],
      ],
    );
  }
}
