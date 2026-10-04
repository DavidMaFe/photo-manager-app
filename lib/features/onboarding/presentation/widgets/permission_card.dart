import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/permissions/permission_access.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/core/widgets/app_card.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// One permission of the first-launch screen with its own action:
/// "Allow", "✓ Done" or "Settings" when it can only be granted there.
class PermissionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final PermissionAccess access;

  /// The next permission to grant gets the primary button.
  final bool recommended;
  final bool loading;
  final VoidCallback onAllow;
  final VoidCallback onOpenSettings;

  const PermissionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.access,
    required this.onAllow,
    required this.onOpenSettings,
    this.recommended = false,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final granted = access == PermissionAccess.granted;

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: granted ? p.safeSoft : p.accentSoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: granted ? p.safeInk : p.accent, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: p.ink)),
                const SizedBox(height: 2),
                Text(description, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: p.ink2)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _status(context, p),
        ],
      ),
    );
  }

  Widget _status(BuildContext context, AppPalette p) {
    final l10n = AppLocalizations.of(context)!;

    switch (access) {
      case PermissionAccess.granted:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Symbols.check_rounded, size: 18, color: p.safeInk),
            const SizedBox(width: 4),
            Text(l10n.done, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: p.safeInk)),
          ],
        );
      case PermissionAccess.blocked:
        return AppButton.neutral(label: l10n.permSettings, size: AppButtonSize.small, onPressed: onOpenSettings);
      case PermissionAccess.pending:
        return recommended
            ? AppButton.primary(label: l10n.allow, size: AppButtonSize.small, loading: loading, onPressed: onAllow)
            : AppButton.neutral(label: l10n.allow, size: AppButtonSize.small, loading: loading, onPressed: onAllow);
    }
  }
}
