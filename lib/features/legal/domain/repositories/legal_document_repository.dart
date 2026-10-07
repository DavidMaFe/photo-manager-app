import 'package:photo_manager_app/features/legal/domain/entities/legal_document.dart';

/// The texts bundled in the app, so they can be read without a session or a connection.
abstract class LegalDocumentRepository {
  /// [languageCode] "es" gives the Spanish text; any other language gives the English one.
  LegalDocument document(LegalDocumentType type, String languageCode);
}
