import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/errors/exceptions/api_exception.dart';
import 'package:photo_manager_app/features/legal/data/data_sources/legal_remote_data_source.dart';
import 'package:photo_manager_app/features/legal/data/repositories/bundled_legal_document_repository.dart';
import 'package:photo_manager_app/features/legal/data/repositories/legal_acceptance_data_repository.dart';
import 'package:photo_manager_app/features/legal/domain/entities/legal_document.dart';
import 'package:photo_manager_app/features/legal/domain/entities/legal_versions.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockLegalRemoteDataSource extends Mock implements LegalRemoteDataSource {}

class FakeUri extends Fake implements Uri {}

void main() {
  setUpAll(() => registerFallbackValue(FakeUri()));

  group('BundledLegalDocumentRepository', () {
    const repository = BundledLegalDocumentRepository();

    String allText(LegalDocument document) => [
          document.title,
          for (final section in document.sections) ...[
            section.heading ?? '',
            for (final block in section.blocks)
              ...switch (block) {
                LegalParagraph(:final text) => [text],
                LegalBullets(:final items) => items,
              },
          ],
        ].join('\n');

    test('should have every document in Spanish and in English, with content', () {
      for (final type in LegalDocumentType.values) {
        for (final language in ['es', 'en']) {
          final document = repository.document(type, language);
          expect(document.type, type);
          expect(document.title, isNotEmpty);
          expect(document.sections, isNotEmpty, reason: '$type $language');
        }
      }
    });

    test('should give the English text for any language other than Spanish', () {
      expect(repository.document(LegalDocumentType.terms, 'fr').title, 'Terms of use');
      expect(repository.document(LegalDocumentType.terms, 'es').title, 'Términos y condiciones de uso');
    });

    test('should version the terms and the privacy policy with the versions sent to the server', () {
      for (final language in ['es', 'en']) {
        expect(repository.document(LegalDocumentType.terms, language).version, LegalVersions.terms);
        expect(repository.document(LegalDocumentType.privacy, language).version, LegalVersions.privacy);
        expect(repository.document(LegalDocumentType.protection, language).version, isNull);
      }
    });

    test('should state the disclaimer and that locked files are not deleted in the terms', () {
      final es = allText(repository.document(LegalDocumentType.terms, 'es'));
      final en = allText(repository.document(LegalDocumentType.terms, 'en'));

      expect(es, contains('no somos responsables'));
      expect(es, contains('Los archivos bloqueados no se borran'));
      expect(en, contains('we are not liable'));
      expect(en, contains('Locked files are not deleted'));
    });

    test('should explain the three situations of a forgotten password', () {
      final es = repository.document(LegalDocumentType.forgotPassword, 'es');

      expect(es.sections.map((section) => section.heading).whereType<String>().where((h) => h.startsWith(RegExp(r'[123]\.'))),
          hasLength(3));
    });

    test('should name the processors and the right to complain in the privacy policy', () {
      for (final language in ['es', 'en']) {
        final text = allText(repository.document(LegalDocumentType.privacy, language));
        expect(text, contains('Cloudflare R2'));
        expect(text, contains('Backblaze B2'));
        expect(text, contains('Gmail'));
        expect(text, contains('www.aepd.es'));
      }
    });
  });

  group('LegalRemoteDataSource', () {
    late MockHttpClient client;
    late LegalRemoteDataSourceImpl dataSource;

    setUp(() {
      client = MockHttpClient();
      dataSource = LegalRemoteDataSourceImpl(client: client, baseUrl: 'http://server');
    });

    test('should POST the accepted versions', () async {
      when(() => client.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
          .thenAnswer((_) async => http.Response('', 200));

      await dataSource.acceptLegalTerms(termsVersion: '1.0', privacyVersion: '1.1');

      final captured = verify(() => client.post(captureAny(), headers: any(named: 'headers'),
          body: captureAny(named: 'body'))).captured;
      expect((captured[0] as Uri).toString(), 'http://server/api/profile/terms/');
      expect(jsonDecode(captured[1] as String), {'termsVersion': '1.0', 'privacyVersion': '1.1'});
    });

    test('should throw ApiException with the error of the backend', () async {
      when(() => client.post(any(), headers: any(named: 'headers'), body: any(named: 'body'))).thenAnswer((_) async =>
          http.Response(jsonEncode({'code': 'LEGAL_VERSION_OUTDATED', 'message': 'Update the app', 'timestamp': 'now'}),
              400));

      await expectLater(dataSource.acceptLegalTerms(termsVersion: '0.9', privacyVersion: '1.0'),
          throwsA(isA<ApiException>().having((e) => e.errorResponse.code, 'code', 'LEGAL_VERSION_OUTDATED')));
    });

    test('should wrap connection errors', () async {
      when(() => client.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
          .thenThrow(StateError('closed'));

      await expectLater(dataSource.acceptLegalTerms(termsVersion: '1.0', privacyVersion: '1.0'), throwsException);
    });
  });

  group('LegalAcceptanceDataRepository', () {
    test('should delegate to the remote data source', () async {
      final remote = MockLegalRemoteDataSource();
      when(() => remote.acceptLegalTerms(termsVersion: '1.0', privacyVersion: '1.0')).thenAnswer((_) async {});

      await LegalAcceptanceDataRepository(remoteDataSource: remote).accept(termsVersion: '1.0', privacyVersion: '1.0');

      verify(() => remote.acceptLegalTerms(termsVersion: '1.0', privacyVersion: '1.0')).called(1);
    });
  });
}
