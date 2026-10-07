import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/crypto/domain/recovery_phrase.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/core/widgets/app_text_field.dart';
import 'package:photo_manager_app/core/widgets/secondary_top_bar.dart';
import 'package:photo_manager_app/features/account_security/presentation/pages/recovery_phrase_page.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// Asks for 3 of the 24 words, at random positions, to check the user saved them. Then the session starts.
class ConfirmRecoveryPhrasePage extends StatefulWidget {
  static const int wordsToAsk = 3;

  final RecoveryPhraseArgs args;
  final Random? random;

  const ConfirmRecoveryPhrasePage({super.key, required this.args, this.random});

  @override
  State<ConfirmRecoveryPhrasePage> createState() => _ConfirmRecoveryPhrasePageState();
}

class _ConfirmRecoveryPhrasePageState extends State<ConfirmRecoveryPhrasePage> {
  late final List<int> _positions;
  late final List<TextEditingController> _controllers;
  bool _wrong = false;

  @override
  void initState() {
    super.initState();
    final random = widget.random ?? Random.secure();
    final positions = <int>{};
    while (positions.length < ConfirmRecoveryPhrasePage.wordsToAsk) {
      positions.add(random.nextInt(widget.args.words.length));
    }
    _positions = positions.toList()..sort();
    _controllers = List.generate(_positions.length, (_) => TextEditingController());
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _check() {
    final allMatch = List.generate(_positions.length, (i) => i).every((i) =>
        RecoveryPhrase.normalizeWord(_controllers[i].text) ==
        RecoveryPhrase.normalizeWord(widget.args.words[_positions[i]]));

    if (!allMatch) {
      setState(() => _wrong = true);
      return;
    }
    final user = widget.args.user;
    if (user != null) {
      // Starts the reminders and the session (the router leaves the onboarding flow)
      context.read<AuthBloc>().add(RecoveryPhraseConfirmed(user));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = context.palette;
    return Scaffold(
      backgroundColor: palette.surface,
      appBar: SecondaryTopBar(onBack: () => context.pop(), backgroundColor: palette.surface),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.confirmPhraseTitle, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: palette.ink)),
            const SizedBox(height: 8),
            Text(l10n.confirmPhraseSubtitle, style: TextStyle(fontSize: 15, color: palette.ink2)),
            const SizedBox(height: 20),
            for (var i = 0; i < _positions.length; i++) ...[
              AppTextField(
                key: ValueKey('confirm-word-${_positions[i]}'),
                controller: _controllers[i],
                label: l10n.confirmPhraseWordLabel(_positions[i] + 1),
                autofillHints: const [],
                onChanged: (_) => setState(() => _wrong = false),
              ),
              const SizedBox(height: 12),
            ],
            if (_wrong)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(l10n.confirmPhraseWrong, style: TextStyle(color: palette.dangerInk)),
              ),
            AppButton.primary(
              key: const ValueKey('confirm-phrase-check'),
              label: l10n.confirmPhraseCheck,
              onPressed: _check,
            ),
          ],
        ),
      ),
    );
  }
}
