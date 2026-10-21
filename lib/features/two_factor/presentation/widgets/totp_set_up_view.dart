import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/core/widgets/otp_field.dart';
import 'package:photo_manager_app/features/two_factor/domain/entities/totp_set_up.dart';
import 'package:photo_manager_app/features/two_factor/domain/services/two_factor_exporter.dart';
import 'package:photo_manager_app/features/two_factor/presentation/bloc/two_factor_cubit.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// Setting up the authenticator app: add the account to it (open it with the link, or type the key), then confirm
/// with one of its codes. The authenticator is usually on this same phone, so there is no QR to scan.
class TotpSetUpView extends StatefulWidget {
  static const int codeLength = 6;

  final TotpSetUp setUp;
  final bool working;
  final bool hasError;
  final TwoFactorExporter exporter;

  const TotpSetUpView({
    super.key,
    required this.setUp,
    required this.working,
    required this.hasError,
    required this.exporter,
  });

  @override
  State<TotpSetUpView> createState() => _TotpSetUpViewState();
}

class _TotpSetUpViewState extends State<TotpSetUpView> {
  final _codeController = TextEditingController();

  bool get _isCodeComplete => _codeController.text.length == TotpSetUpView.codeLength;

  @override
  void initState() {
    super.initState();
    _codeController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _openApp() async {
    final l10n = AppLocalizations.of(context)!;
    final opened = await widget.exporter.openInAuthenticator(widget.setUp.otpauthUri);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.twoFactorNoApp)));
    }
  }

  Future<void> _copyKey() async {
    final l10n = AppLocalizations.of(context)!;
    await Clipboard.setData(ClipboardData(text: widget.setUp.secret));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.twoFactorKeyCopied)));
    }
  }

  void _enable() {
    if (!_isCodeComplete || widget.working) return;
    context.read<TwoFactorCubit>().enable(_codeController.text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;
    final textStyle = TextStyle(fontSize: 15, height: 1.45, color: p.ink2);

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      children: [
        Text(l10n.twoFactorSetUpStep1, style: textStyle),
        const SizedBox(height: 16),
        AppButton.primary(
          key: const ValueKey('two-factor-open-app'),
          label: l10n.twoFactorOpenApp,
          onPressed: _openApp,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
          decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14)),
          child: Row(
            children: [
              Expanded(
                child: SelectableText(
                  widget.setUp.groupedSecret,
                  key: const ValueKey('two-factor-secret'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                    color: p.ink,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              IconButton(
                key: const ValueKey('two-factor-copy-key'),
                tooltip: l10n.twoFactorCopyKey,
                icon: const Icon(Symbols.content_copy_rounded),
                onPressed: _copyKey,
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Text(l10n.twoFactorSetUpStep2, style: textStyle),
        const SizedBox(height: 16),
        OtpField(
          length: TotpSetUpView.codeLength,
          controller: _codeController,
          hasError: widget.hasError,
          onCompleted: (_) => _enable(),
        ),
        const SizedBox(height: 24),
        AppButton.primary(
          key: const ValueKey('two-factor-confirm'),
          label: l10n.twoFactorEnable,
          loading: widget.working,
          onPressed: _isCodeComplete && !widget.working ? _enable : null,
        ),
      ],
    );
  }
}
