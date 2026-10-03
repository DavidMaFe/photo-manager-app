import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:flutter/material.dart';


class ProfileMenuItem extends StatelessWidget {

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 8
      ),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: context.palette.surface2,
          borderRadius: BorderRadius.circular(8)
        ),
        child: Icon(
          icon,
          color: context.palette.ink2,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: context.palette.ink
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: context.palette.ink2
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: context.palette.ink3,
      ),
    );
  }
}