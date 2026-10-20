import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/legal/data/content/legal_content_en.dart';
import 'package:photo_manager_app/features/legal/data/content/legal_content_es.dart';
import 'package:photo_manager_app/features/legal/domain/entities/legal_document.dart';
import 'package:photo_manager_app/features/legal/domain/entities/legal_versions.dart';

import '../../tool/export_legal_pages.dart';

String _escaped(String text) =>
    text.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;').replaceAll('"', '&quot;');

void main() {
  group('export_legal_pages', () {
    for (final type in [LegalDocumentType.privacy, LegalDocumentType.terms]) {
      test('should write every heading, paragraph and item of the ${type.slug} in both languages', () {
        final es = legalDocumentsEs[type]!;
        final en = legalDocumentsEn[type]!;
        final html = page(es, en);

        for (final document in [es, en]) {
          expect(html, contains('<h1>${_escaped(document.title)}</h1>'));
          for (final section in document.sections) {
            if (section.heading != null) expect(html, contains('<h2>${_escaped(section.heading!)}</h2>'));
            for (final block in section.blocks) {
              final texts = switch (block) {
                LegalParagraph(:final text) => [text],
                LegalBullets(:final items) => items,
              };
              for (final text in texts) {
                expect(html, contains(_escaped(text)));
              }
            }
          }
        }
      });
    }

    test('should show the version and the date it came into force', () {
      final html = page(legalDocumentsEs[LegalDocumentType.terms]!, legalDocumentsEn[LegalDocumentType.terms]!);

      expect(html, contains('Versión ${LegalVersions.terms} · vigente desde el'));
      expect(html, contains('Version ${LegalVersions.terms} · in force since'));
      expect(html, contains('<section id="en" lang="en">'));
    });

    test('should escape the HTML of the texts', () {
      const document = LegalDocument(
        type: LegalDocumentType.terms,
        title: 'A & B',
        version: '1',
        sections: [LegalSection(heading: '<b>', blocks: [LegalParagraph('"x" < y')])],
      );

      final html = page(document, document);

      expect(html, contains('<h1>A &amp; B</h1>'));
      expect(html, contains('<h2>&lt;b&gt;</h2>'));
      expect(html, contains('<p>&quot;x&quot; &lt; y</p>'));
    });
  });
}
