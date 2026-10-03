import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager_app/core/services/ui_preferences_service.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

class LocalDeletionWarningDialog {
  static Future<void> show({
    required BuildContext context,
    required String message,
    required UiPreferencesService preferencesService,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    // Check if user wants to hide this dialog
    if (preferencesService.shouldHideLocalDeletionWarning) {
      return;
    }

    bool dontShowAgain = false;

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: context.palette.media.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return StatefulBuilder(
          builder: (context, setState) {
            return ScaleTransition(
              scale: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
              ),
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeIn,
                ),
                child: _LocalDeletionWarningDialogContent(
                  message: message,
                  l10n: l10n,
                  dontShowAgain: dontShowAgain,
                  onDontShowAgainChanged: (value) {
                    setState(() {
                      dontShowAgain = value;
                    });
                  },
                  onConfirm: () async {
                    if (dontShowAgain) {
                      await preferencesService.setHideLocalDeletionWarning(true);
                    }
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _LocalDeletionWarningDialogContent extends StatelessWidget {
  final String message;
  final AppLocalizations l10n;
  final bool dontShowAgain;
  final ValueChanged<bool> onDontShowAgainChanged;
  final VoidCallback onConfirm;

  const _LocalDeletionWarningDialogContent({
    required this.message,
    required this.l10n,
    required this.dontShowAgain,
    required this.onDontShowAgainChanged,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            decoration: BoxDecoration(
              color: context.palette.surface.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: context.palette.surface.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: context.palette.shadow,
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(context),
                  _buildContent(context),
                  _buildCheckbox(context),
                  _buildActions(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.palette.review,
            context.palette.review.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 20),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: context.palette.surface.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.info_outline,
              color: context.palette.onAccent,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              l10n.filesManaged,
              style: TextStyle(
                color: context.palette.onAccent,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        message,
        style: TextStyle(
          color: context.palette.ink,
          fontSize: 15,
          height: 1.5,
          decoration: TextDecoration.none,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.normal,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _buildCheckbox(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: InkWell(
        onTap: () => onDontShowAgainChanged(!dontShowAgain),
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: dontShowAgain,
                onChanged: (value) => onDontShowAgainChanged(value ?? false),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.dontShowAgain,
                style: TextStyle(
                  color: context.palette.ink2,
                  fontSize: 14,
                  decoration: TextDecoration.none,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: FilledButton(
              onPressed: onConfirm,
              style: FilledButton.styleFrom(
                backgroundColor: context.palette.review,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                l10n.ok,
                style: TextStyle(
                  color: context.palette.onAccent,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
