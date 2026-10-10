import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/core/injection_container.dart';
import 'package:photo_manager_app/core/navigation/route_names.dart';
import 'package:photo_manager_app/core/widgets/app_dialog.dart';
import 'package:photo_manager_app/features/account_security/domain/use_cases/recovery_phrase_use_cases.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// Asks the user, when it is due, whether they still have their 24 words (2 days, 2 weeks, then every 3 months).
/// Checked once per app session, when the main screens open.
class RecoveryReminderListener extends StatefulWidget {
  final Widget child;
  final RecoveryReminderUseCase? reminderUseCase;

  const RecoveryReminderListener({super.key, required this.child, this.reminderUseCase});

  /// Only one check per app session, however many times the shell is rebuilt.
  static bool checkedThisSession = false;

  @override
  State<RecoveryReminderListener> createState() => _RecoveryReminderListenerState();
}

class _RecoveryReminderListenerState extends State<RecoveryReminderListener> {
  @override
  void initState() {
    super.initState();
    if (!RecoveryReminderListener.checkedThisSession) {
      RecoveryReminderListener.checkedThisSession = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _check());
    }
  }

  Future<void> _check() async {
    final useCase = widget.reminderUseCase ?? sl<RecoveryReminderUseCase>();
    if (!await useCase.isDue() || !mounted) return;

    final l10n = AppLocalizations.of(context)!;
    final verifyNow = await AppDialog.show(
      context: context,
      icon: Symbols.key_rounded,
      title: l10n.reminderTitle,
      message: l10n.reminderMessage,
      primaryLabel: l10n.reminderVerifyNow,
      secondaryLabel: l10n.reminderLater,
      barrierDismissible: false,
    );
    if (!mounted) return;
    if (verifyNow == true) {
      // The verification moves the reminders forward when it succeeds
      context.goNamed(RouteNames.verifyRecoveryWords);
    } else {
      await useCase.postpone();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
