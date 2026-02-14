import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:photo_manager_app/config/theme/photo_manager_colors.dart';

enum DialogType {
  success,
  danger,
  warning,
  info,
  neutral,
}

class ModernDialog extends StatefulWidget {
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
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ModernDialog(
          type: type,
          icon: icon,
          title: title,
          message: message,
          cancelText: cancelText,
          confirmText: confirmText,
          onConfirm: onConfirm,
          onCancel: onCancel,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
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
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<ModernDialog> createState() => _ModernDialogState();
}

class _ModernDialogState extends State<ModernDialog> {
  Color get _accentColor {
    switch (widget.type) {
      case DialogType.success:
        return Colors.green;
      case DialogType.danger:
        return Colors.red;
      case DialogType.warning:
        return Colors.orange;
      case DialogType.info:
        return Colors.blue;
      case DialogType.neutral:
        return PhotoManagerColors.primary;
    }
  }

  LinearGradient get _headerGradient {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        _accentColor,
        _accentColor.withValues(alpha: 0.8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
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
                  _buildHeader(),
                  _buildContent(),
                  _buildActions(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        gradient: _headerGradient,
      ),
      child: Row(
        children: [
          const SizedBox(width: 20),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              widget.icon,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DefaultTextStyle(
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
              ),
              child: Text(widget.title),
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: DefaultTextStyle(
        style: TextStyle(
          color: Colors.grey.shade800,
          fontSize: 15,
          height: 1.5,
          decoration: TextDecoration.none,
        ),
        child: Text(
          widget.message,
          textAlign: TextAlign.left,
        ),
      ),
    );
  }

  Widget _buildActions() {
    // Check if we should show cancel button (only if cancelText is not empty)
    final showCancelButton = widget.cancelText.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Row(
        mainAxisAlignment: showCancelButton ? MainAxisAlignment.end : MainAxisAlignment.center,
        children: [
          if (showCancelButton) ...[
            Flexible(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                  widget.onCancel?.call();
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  widget.cancelText,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                widget.onConfirm?.call();
              },
              style: FilledButton.styleFrom(
                backgroundColor: _accentColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                widget.confirmText,
                style: const TextStyle(
                  color: Colors.white,
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
