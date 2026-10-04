import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/services/ui_preferences_service.dart';
import 'package:photo_manager_app/core/widgets/app_dialog.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// Warns that files removed from the cloud may still be on the phone, with a
/// "Don't show again" option.
class LocalDeletionWarningDialog {
  static Future<void> show({
    required BuildContext context,
    required String message,
    required UiPreferencesService preferencesService,
  }) async {
    if (preferencesService.shouldHideLocalDeletionWarning) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final dontShowAgain = ValueNotifier(false);

    await AppDialog.show(
      context: context,
      icon: Symbols.info_rounded,
      tone: AppDialogTone.review,
      title: l10n.filesManaged,
      message: message,
      primaryLabel: l10n.ok,
      content: ValueListenableBuilder<bool>(
        valueListenable: dontShowAgain,
        builder: (context, value, _) => CheckboxListTile(
          value: value,
          onChanged: (checked) => dontShowAgain.value = checked ?? false,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: context.palette.accent,
          title: Text(
            l10n.dontShowAgain,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.palette.ink),
          ),
        ),
      ),
    );

    if (dontShowAgain.value) {
      await preferencesService.setHideLocalDeletionWarning(true);
    }
    dontShowAgain.dispose();
  }
}
