import 'package:flutter/material.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';

/// Title (30/w800) and subtitle (15/w500 ink2) of the auth screens.
class AuthTitle extends StatelessWidget {
  final String title;
  final String? subtitle;

  /// Rich subtitle (e.g. with the email in bold); wins over [subtitle].
  final InlineSpan? subtitleSpan;

  const AuthTitle({super.key, required this.title, this.subtitle, this.subtitleSpan});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final subtitleStyle = TextStyle(fontSize: 15, fontWeight: FontWeight.w500, height: 1.45, color: p.ink2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
        ),
        if (subtitleSpan != null || subtitle != null) ...[
          const SizedBox(height: 8),
          subtitleSpan != null
              ? Text.rich(subtitleSpan!, style: subtitleStyle)
              : Text(subtitle!, style: subtitleStyle),
        ],
      ],
    );
  }
}
