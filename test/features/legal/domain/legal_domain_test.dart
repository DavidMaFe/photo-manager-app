import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/legal/domain/entities/legal_document.dart';
import 'package:photo_manager_app/features/legal/domain/entities/legal_versions.dart';
import 'package:photo_manager_app/features/legal/domain/repositories/legal_acceptance_repository.dart';
import 'package:photo_manager_app/features/legal/domain/use_cases/accept_legal_terms_use_case.dart';

class MockLegalAcceptanceRepository extends Mock implements LegalAcceptanceRepository {}

void main() {
  group('LegalDocumentType', () {
    test('should find each document by the slug of its page', () {
      for (final type in LegalDocumentType.values) {
        expect(LegalDocumentType.fromSlug(type.slug), type);
      }
    });

    test('should give null for an unknown slug', () {
      expect(LegalDocumentType.fromSlug('cookies'), isNull);
      expect(LegalDocumentType.fromSlug(null), isNull);
    });
  });

  group('AcceptLegalTermsUseCase', () {
    test('should accept the versions bundled in the app', () async {
      // Arrange
      final repository = MockLegalAcceptanceRepository();
      when(() => repository.accept(termsVersion: any(named: 'termsVersion'), privacyVersion: any(named: 'privacyVersion')))
          .thenAnswer((_) async {});

      // Act
      await AcceptLegalTermsUseCase(repository)();

      // Assert
      verify(() => repository.accept(termsVersion: LegalVersions.terms, privacyVersion: LegalVersions.privacy))
          .called(1);
    });
  });
}
