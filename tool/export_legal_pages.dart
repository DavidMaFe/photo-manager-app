// Writes the terms of use and the privacy policy of the app as static web pages (Spanish and English), for the
// stores, which ask for public URLs. The texts are the ones bundled in the app (lib/features/legal), so the pages never
// drift from them: run it again whenever a legal text changes.
//
//   dart run tool/export_legal_pages.dart ../../IdeaProjects/photo-manager-server/web
//
// It writes <web>/privacidad/index.html and <web>/terminos/index.html, served by nginx from the backend repository
// (docs/deploy-home-server.md).
import 'dart:io';

import 'package:photo_manager_app/features/legal/data/content/legal_content_en.dart';
import 'package:photo_manager_app/features/legal/data/content/legal_content_es.dart';
import 'package:photo_manager_app/features/legal/domain/entities/legal_document.dart';
import 'package:photo_manager_app/features/legal/domain/entities/legal_versions.dart';

const _monthsEs = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre',
    'noviembre', 'diciembre'];
const _monthsEn = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October',
    'November', 'December'];

void main(List<String> args) {
  if (args.length != 1) {
    stderr.writeln('Usage: dart run tool/export_legal_pages.dart <web directory of the backend>');
    exit(64);
  }
  for (final (type, folder) in [(LegalDocumentType.privacy, 'privacidad'), (LegalDocumentType.terms, 'terminos')]) {
    final file = File('${args.single}/$folder/index.html');
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(page(legalDocumentsEs[type]!, legalDocumentsEn[type]!));
    stdout.writeln('Written ${file.path}');
  }
}

String page(LegalDocument es, LegalDocument en) {
  final date = LegalVersions.effectiveDate;
  final dateEs = '${date.day} de ${_monthsEs[date.month - 1]} de ${date.year}';
  final dateEn = '${_monthsEn[date.month - 1]} ${date.day}, ${date.year}';
  return '''<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${_escape(es.title)} · Photo Manager</title>
  <meta name="description" content="${_escape(es.title)} de Photo Manager. ${_escape(en.title)} of Photo Manager.">
  <style>
    :root { --bg: #f5f5f7; --surface: #ffffff; --ink: #1c1c22; --ink2: #5c5c66; --line: #e4e4ea; --accent: #5d5be9; }
    @media (prefers-color-scheme: dark) {
      :root { --bg: #121216; --surface: #1d1d23; --ink: #f1f1f4; --ink2: #a7a7b2; --line: #2e2e36; --accent: #8b89ff; }
    }
    * { box-sizing: border-box; }
    body {
      margin: 0; background: var(--bg); color: var(--ink);
      font: 16px/1.6 -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
    }
    main { max-width: 720px; margin: 0 auto; padding: 24px 16px 48px; }
    header { display: flex; justify-content: space-between; align-items: center; gap: 12px; margin-bottom: 8px; }
    .brand { font-weight: 800; font-size: 20px; }
    .brand span { color: var(--accent); }
    nav a { color: var(--accent); font-weight: 700; text-decoration: none; }
    h1 { font-size: 32px; line-height: 1.15; margin: 24px 0 4px; }
    .version { font-size: 14px; color: var(--ink2); margin: 0 0 16px; }
    h2 { font-size: 18px; margin: 28px 0 8px; }
    p { margin: 0 0 12px; color: var(--ink2); }
    ul { margin: 0 0 12px; padding-left: 22px; color: var(--ink2); }
    li { margin: 4px 0; }
    hr { border: 0; border-top: 1px solid var(--line); margin: 48px 0 0; }
  </style>
</head>
<body>
<main>
  <header>
    <div class="brand">Photo<span>Manager</span></div>
    <nav><a href="#en" hreflang="en">English</a></nav>
  </header>

  <section id="es" lang="es">
${_document(es, 'Versión ${es.version} · vigente desde el $dateEs')}
  </section>

  <hr>

  <section id="en" lang="en">
${_document(en, 'Version ${en.version} · in force since $dateEn')}
  </section>
</main>
</body>
</html>
''';
}

String _document(LegalDocument document, String version) {
  final html = StringBuffer()
    ..writeln('    <h1>${_escape(document.title)}</h1>')
    ..writeln('    <p class="version">${_escape(version)}</p>');
  for (final section in document.sections) {
    if (section.heading case final heading?) html.writeln('    <h2>${_escape(heading)}</h2>');
    for (final block in section.blocks) {
      switch (block) {
        case LegalParagraph(:final text):
          html.writeln('    <p>${_escape(text)}</p>');
        case LegalBullets(:final items):
          html.writeln('    <ul>');
          for (final item in items) {
            html.writeln('      <li>${_escape(item)}</li>');
          }
          html.writeln('    </ul>');
      }
    }
  }
  return html.toString().trimRight();
}

String _escape(String text) =>
    text.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;').replaceAll('"', '&quot;');
