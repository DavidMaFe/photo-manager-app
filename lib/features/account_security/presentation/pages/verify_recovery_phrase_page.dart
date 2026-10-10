import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/crypto/domain/recovery_phrase.dart';
import 'package:photo_manager_app/core/errors/helper/failure_message_helper.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/core/widgets/app_text_field.dart';
import 'package:photo_manager_app/core/widgets/secondary_top_bar.dart';
import 'package:photo_manager_app/features/account_security/presentation/bloc/verify_recovery_phrase_bloc.dart';
import 'package:photo_manager_app/features/account_security/presentation/widgets/recovery_words_input.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// Checks that the user still has the 24 words (reminders and profile).
class VerifyRecoveryPhrasePage extends StatefulWidget {
  const VerifyRecoveryPhrasePage({super.key});

  @override
  State<VerifyRecoveryPhrasePage> createState() => _VerifyRecoveryPhrasePageState();
}

class _VerifyRecoveryPhrasePageState extends State<VerifyRecoveryPhrasePage> {
  final Map<int, TextEditingController> _wordControllers = {};
  final _phraseController = TextEditingController();

  @override
  void dispose() {
    for (final controller in _wordControllers.values) {
      controller.dispose();
    }
    _phraseController.dispose();
    super.dispose();
  }

  RecoveryPhraseLanguage _language() =>
      Localizations.localeOf(context).languageCode == 'es' ? RecoveryPhraseLanguage.spanish : RecoveryPhraseLanguage.english;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = context.palette;
    return BlocConsumer<VerifyRecoveryPhraseBloc, VerifyRecoveryPhraseState>(
      listener: (context, state) {
        if (state is VerifyRecoveryPhraseSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.verifyPhraseSuccess)));
          context.pop();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: palette.surface,
          appBar: SecondaryTopBar(onBack: () => context.pop(), backgroundColor: palette.surface),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.verifyPhraseTitle,
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: palette.ink)),
                const SizedBox(height: 8),
                ..._body(context, state, l10n, palette),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _body(BuildContext context, VerifyRecoveryPhraseState state, AppLocalizations l10n, AppPalette palette) {
    if (state is VerifyAskWords) {
      for (final position in state.positions) {
        _wordControllers.putIfAbsent(position, TextEditingController.new);
      }
      return [
        Text(l10n.confirmPhraseSubtitle, style: TextStyle(fontSize: 15, color: palette.ink2)),
        const SizedBox(height: 20),
        for (final position in state.positions) ...[
          AppTextField(
            key: ValueKey('verify-word-$position'),
            controller: _wordControllers[position],
            label: l10n.confirmPhraseWordLabel(position + 1),
            autofillHints: const [],
          ),
          const SizedBox(height: 12),
        ],
        if (state.wrong)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(l10n.confirmPhraseWrong, style: TextStyle(color: palette.dangerInk)),
          ),
        AppButton.primary(
          key: const ValueKey('verify-submit'),
          label: l10n.confirmPhraseCheck,
          loading: state.working,
          onPressed: state.working
              ? null
              : () => context.read<VerifyRecoveryPhraseBloc>().add(VerifyWordsSubmitted(
                  {for (final position in state.positions) position: _wordControllers[position]!.text}, _language())),
        ),
      ];
    }
    if (state is VerifyAskFullPhrase) {
      return [
        Text(l10n.verifyPhraseSubtitleFull, style: TextStyle(fontSize: 15, color: palette.ink2)),
        const SizedBox(height: 20),
        RecoveryWordsInput(controller: _phraseController, enabled: !state.working),
        const SizedBox(height: 12),
        if (state.failure != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(FailureMessageHelper.getMessage(context, state.failure!),
                style: TextStyle(color: palette.dangerInk)),
          ),
        AppButton.primary(
          key: const ValueKey('verify-submit'),
          label: l10n.confirmPhraseCheck,
          loading: state.working,
          onPressed: state.working
              ? null
              : () => context.read<VerifyRecoveryPhraseBloc>()
                  .add(VerifyFullPhraseSubmitted(RecoveryWordsInput.parse(_phraseController.text))),
        ),
      ];
    }
    return const [Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator()))];
  }
}
