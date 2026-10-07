import 'package:photo_manager_app/features/legal/data/content/legal_content_en.dart';
import 'package:photo_manager_app/features/legal/data/content/legal_content_es.dart';
import 'package:photo_manager_app/features/legal/domain/entities/legal_document.dart';
import 'package:photo_manager_app/features/legal/domain/repositories/legal_document_repository.dart';

class BundledLegalDocumentRepository implements LegalDocumentRepository {
  const BundledLegalDocumentRepository();

  @override
  LegalDocument document(LegalDocumentType type, String languageCode) =>
      (languageCode == 'es' ? legalDocumentsEs : legalDocumentsEn)[type]!;
}
