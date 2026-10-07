import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/injection_container.dart';
import 'package:photo_manager_app/core/navigation/route_names.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/core/widgets/secondary_top_bar.dart';
import 'package:photo_manager_app/features/account_security/domain/services/recovery_phrase_exporter.dart';
import 'package:photo_manager_app/features/account_security/presentation/widgets/recovery_words_grid.dart';
import 'package:photo_manager_app/features/auth/domain/entities/user.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// Where the 24 words come from: they decide whether the user must confirm them and what happens next.
enum RecoveryPhraseFlow {
  /// Just registered: confirm 3 words, then the session starts.
  registration,

  /// New key of a locked account: confirm 3 words, then the session starts.
  newKey,

  /// "My 24 words" from the profile: just show them.
  view,
}

class RecoveryPhraseArgs {
  final List<String> words;
  final String email;
  final RecoveryPhraseFlow flow;

  /// The logged-in user, needed to start the session at the end of [RecoveryPhraseFlow.registration] and
  /// [RecoveryPhraseFlow.newKey].
  final User? user;

  const RecoveryPhraseArgs({required this.words, required this.email, required this.flow, this.user});

  bool get needsConfirmation => flow != RecoveryPhraseFlow.view;
}

/// Shows the 24 words and lets the user save them in the password manager or as a PDF.
class RecoveryPhrasePage extends StatefulWidget {
  final RecoveryPhraseArgs args;
  final RecoveryPhraseExporter? exporter;

  const RecoveryPhrasePage({super.key, required this.args, this.exporter});

  @override
  State<RecoveryPhrasePage> createState() => _RecoveryPhrasePageState();
}

class _RecoveryPhrasePageState extends State<RecoveryPhrasePage> {
  late final RecoveryPhraseExporter _exporter = widget.exporter ?? sl<RecoveryPhraseExporter>();
  bool _saving = false;
  bool _savedToPasswordManager = false;

  Future<void> _saveToPasswordManager() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _saving = true);
    final saved = await _exporter.saveToPasswordManager(
        account: l10n.recoveryPhrasePasswordManagerAccount(widget.args.email), words: widget.args.words);
    if (!mounted) return;
    setState(() {
      _saving = false;
      _savedToPasswordManager = saved;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(saved ? l10n.recoveryPhraseSavedToPasswordManager : l10n.recoveryPhraseSaveToPasswordManagerFailed),
    ));
  }

  Future<void> _sharePdf() async {
    final l10n = AppLocalizations.of(context)!;
    await _exporter.sharePdf(
      email: widget.args.email,
      words: widget.args.words,
      texts: RecoveryPhrasePdfTexts(
        title: l10n.recoveryPhrasePdfTitle,
        accountLabel: l10n.recoveryPhrasePdfAccount,
        warning: l10n.recoveryPhrasePdfWarning,
        instructions: l10n.recoveryPhrasePdfInstructions,
        fileName: 'photo-manager-recovery-key.pdf',
      ),
    );
  }

  void _continue() {
    if (widget.args.needsConfirmation) {
      context.push(RoutePaths.confirmRecoveryPhrase, extra: widget.args);
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = context.palette;
    final viewOnly = widget.args.flow == RecoveryPhraseFlow.view;

    return PopScope(
      // Before confirming, the user cannot go back: the account already exists and the words are not shown again
      canPop: viewOnly,
      child: Scaffold(
        backgroundColor: palette.surface,
        appBar: viewOnly ? SecondaryTopBar(onBack: () => context.pop(), backgroundColor: palette.surface) : null,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(viewOnly ? l10n.recoveryPhraseViewTitle : l10n.recoveryPhraseTitle,
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: palette.ink)),
                const SizedBox(height: 8),
                Text(l10n.recoveryPhraseSubtitle, style: TextStyle(fontSize: 15, color: palette.ink2)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: palette.reviewSoft, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Icon(Symbols.warning_rounded, color: palette.reviewIcon),
                      const SizedBox(width: 10),
                      Expanded(child: Text(l10n.recoveryPhraseWarning, style: TextStyle(color: palette.reviewInk))),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                RecoveryWordsGrid(words: widget.args.words),
                const SizedBox(height: 20),
                AppButton.secondary(
                  key: const ValueKey('save-password-manager'),
                  label: _savedToPasswordManager
                      ? l10n.recoveryPhraseSavedToPasswordManager
                      : l10n.recoveryPhraseSaveToPasswordManager,
                  icon: _savedToPasswordManager ? Symbols.check_rounded : Symbols.key_rounded,
                  loading: _saving,
                  onPressed: _saving ? null : _saveToPasswordManager,
                ),
                const SizedBox(height: 10),
                AppButton.secondary(
                  key: const ValueKey('download-pdf'),
                  label: l10n.recoveryPhraseDownloadPdf,
                  icon: Symbols.picture_as_pdf_rounded,
                  onPressed: _sharePdf,
                ),
                const SizedBox(height: 24),
                AppButton.primary(
                  key: const ValueKey('recovery-phrase-continue'),
                  label: viewOnly ? l10n.recoveryPhraseDone : l10n.recoveryPhraseContinue,
                  onPressed: _continue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
