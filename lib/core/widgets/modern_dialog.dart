import 'package:flutter/material.dart';

import 'app_dialog.dart';

enum DialogType {
  success,
  danger,
  warning,
  info,
  neutral,
}

/// Envoltorio de compatibilidad sobre [AppDialog]: mantiene la API anterior
/// para no romper las llamadas existentes.
class ModernDialog extends StatelessWidget {
  final DialogType type;
  final IconData icon;
  final String title;
  final String message;
  final String cancelText;
  final String confirmText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const ModernDialog({
    super.key,
    required this.type,
    required this.icon,
    required this.title,
    required this.message,
    this.cancelText = '',
    required this.confirmText,
    this.onConfirm,
    this.onCancel,
  });

  static Future<bool?> show({
    required BuildContext context,
    required DialogType type,
    required IconData icon,
    required String title,
    required String message,
    String cancelText = '',
    required String confirmText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool barrierDismissible = true,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) => ModernDialog(
        type: type,
        icon: icon,
        title: title,
        message: message,
        cancelText: cancelText,
        confirmText: confirmText,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
    );
  }

  static AppDialogTone toneFor(DialogType type) {
    return switch (type) {
      DialogType.success => AppDialogTone.safe,
      DialogType.danger => AppDialogTone.danger,
      DialogType.warning => AppDialogTone.review,
      DialogType.info => AppDialogTone.accent,
      DialogType.neutral => AppDialogTone.accent,
    };
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      icon: icon,
      tone: toneFor(type),
      title: title,
      message: message,
      primaryLabel: confirmText,
      secondaryLabel: cancelText.isEmpty ? null : cancelText,
      destructive: type == DialogType.danger,
      onPrimary: onConfirm,
      onSecondary: onCancel,
    );
  }
}
