/// The information pages and legal texts readable without logging in (ROADMAP-e2e-encryption.md, Phase 4).
enum LegalDocumentType {
  /// "How we protect your photos": end-to-end encryption and what the server sees.
  protection('protection'),

  /// "If you forget your password": the three situations and what happens in each one.
  forgotPassword('forgot-password'),

  /// "The 24 words": what they are, why they matter, how to keep them.
  recoveryWords('recovery-words'),

  terms('terms'),
  privacy('privacy');

  /// Path segment of the document page (/legal/{slug}).
  final String slug;

  const LegalDocumentType(this.slug);

  static LegalDocumentType? fromSlug(String? slug) =>
      LegalDocumentType.values.where((type) => type.slug == slug).firstOrNull;
}

/// A block of a section: a paragraph or a bulleted list.
sealed class LegalBlock {
  const LegalBlock();
}

class LegalParagraph extends LegalBlock {
  final String text;

  const LegalParagraph(this.text);
}

class LegalBullets extends LegalBlock {
  final List<String> items;

  const LegalBullets(this.items);
}

class LegalSection {
  final String? heading;
  final List<LegalBlock> blocks;

  const LegalSection({this.heading, required this.blocks});
}

class LegalDocument {
  final LegalDocumentType type;
  final String title;

  /// Version of the terms of use or the privacy policy; null for the information pages.
  final String? version;
  final List<LegalSection> sections;

  const LegalDocument({required this.type, required this.title, this.version, required this.sections});
}
