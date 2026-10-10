import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/features/legal/domain/entities/legal_document.dart';
import 'package:photo_manager_app/features/legal/domain/entities/legal_versions.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// Title, version and sections of a legal document or information page.
class LegalDocumentView extends StatelessWidget {
  final LegalDocument document;

  const LegalDocumentView({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final palette = context.palette;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final version = document.version;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(document.title,
            key: const ValueKey('legal-document-title'),
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: palette.ink)),
        if (version != null) ...[
          const SizedBox(height: 6),
          Text(
            l10n.legalVersionLabel(version, DateFormat.yMMMMd(locale).format(LegalVersions.effectiveDate)),
            key: const ValueKey('legal-document-version'),
            style: TextStyle(fontSize: 13, color: palette.ink3),
          ),
        ],
        for (final section in document.sections) ...[
          const SizedBox(height: 20),
          if (section.heading != null) ...[
            Text(section.heading!, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: palette.ink)),
            const SizedBox(height: 8),
          ],
          for (final block in section.blocks) _block(block, palette),
        ],
      ],
    );
  }

  Widget _block(LegalBlock block, AppPalette palette) {
    final style = TextStyle(fontSize: 15, height: 1.45, color: palette.ink2);
    return switch (block) {
      LegalParagraph(:final text) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(text, style: style),
        ),
      LegalBullets(:final items) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final item in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('•  ', style: style),
                      Expanded(child: Text(item, style: style)),
                    ],
                  ),
                ),
            ],
          ),
        ),
    };
  }
}
