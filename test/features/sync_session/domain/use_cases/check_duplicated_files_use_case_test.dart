import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/crypto/domain/key_failures.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/duplicate_files_result.dart';
import 'package:photo_manager_app/features/sync_session/domain/repositories/sync_session_repository.dart';
import 'package:photo_manager_app/features/sync_session/domain/services/dedup_hasher.dart';
import 'package:photo_manager_app/features/sync_session/domain/use_cases/check_duplicated_files_use_case.dart';

import '../../../../helpers/e2ee_test_kit.dart';

class MockSyncSessionRepository extends Mock implements SyncSessionRepository {}

void main() {
  late E2eeTestKit kit;
  late MockSyncSessionRepository repository;
  late DedupHasher hasher;
  late CheckDuplicatedFilesUseCase useCase;

  const sessionId = 'session_123';
  final hash1 = 'a' * 64;
  final hash2 = 'b' * 64;
  final hash3 = 'c' * 64;

  setUp(() async {
    kit = await E2eeTestKit.create();
    await kit.keyring.storeNewKey(1, await kit.material('the password', E2eeTestKit.cheapParams()));
    repository = MockSyncSessionRepository();
    hasher = DedupHasher(kit.engine, kit.store);
    useCase = CheckDuplicatedFilesUseCase(repository, hasher);
  });

  /// The server answers with the keyed hashes it does not have yet, as [toUpload] of the content hashes.
  Future<Map<String, String>> serverHasNot(List<String> toUpload, {int duplicates = 0}) async {
    final dedup = await hasher.hashes([hash1, hash2, hash3]);
    when(() => repository.checkDuplicates(sessionId: any(named: 'sessionId'), fileHashes: any(named: 'fileHashes')))
        .thenAnswer((invocation) async => DuplicateFilesResult(
              filesToUpload: [for (final hash in toUpload) dedup[hash]!],
              duplicatesCount: duplicates,
              totalFiles: (invocation.namedArguments[#fileHashes] as List<String>).length,
            ));
    return dedup;
  }

  group('CheckDuplicatedFilesUseCase', () {
    // ==================== HAPPY PATH TESTS ====================

    test('should send only keyed hashes to the server, never the content hashes', () async {
      final dedup = await serverHasNot([hash1, hash2]);

      await useCase(sessionId: sessionId, fileHashes: [hash1, hash2]);

      final sentHashes = verify(() => repository.checkDuplicates(
            sessionId: sessionId,
            fileHashes: captureAny(named: 'fileHashes'),
          )).captured.single as List<String>;
      expect(sentHashes, unorderedEquals([dedup[hash1], dedup[hash2]]));
      expect(sentHashes, isNot(contains(hash1)));
    });

    test('should answer with the content hashes of the files to upload', () async {
      await serverHasNot([hash3], duplicates: 2);

      final result = await useCase(sessionId: sessionId, fileHashes: [hash1, hash2, hash3]);

      expect(result.filesToUpload, [hash3]);
      expect(result.duplicatesCount, 2);
      expect(result.totalFiles, 3);
    });

    test('should send each content only once when two files have the same content', () async {
      await serverHasNot([hash1]);

      final result = await useCase(sessionId: sessionId, fileHashes: [hash1, hash1]);

      final sentHashes = verify(() => repository.checkDuplicates(
            sessionId: sessionId,
            fileHashes: captureAny(named: 'fileHashes'),
          )).captured.single as List<String>;
      expect(sentHashes, hasLength(1));
      expect(result.filesToUpload, [hash1]);
    });

    // ==================== BUSINESS LOGIC TESTS ====================

    test('should throw MissingCurrentKeyFailure without a current key on this device', () async {
      await kit.store.clear();

      await expectLater(useCase(sessionId: sessionId, fileHashes: [hash1]), throwsA(isA<MissingCurrentKeyFailure>()));
      verifyNever(() => repository.checkDuplicates(
          sessionId: any(named: 'sessionId'), fileHashes: any(named: 'fileHashes')));
    });

    test('should propagate the errors of the server', () async {
      when(() => repository.checkDuplicates(sessionId: any(named: 'sessionId'), fileHashes: any(named: 'fileHashes')))
          .thenThrow(Exception('Network error'));

      await expectLater(useCase(sessionId: sessionId, fileHashes: [hash1]), throwsException);
    });

    // ==================== VALIDATION ERROR TESTS ====================

    for (final (description, session, hashes) in [
      ('the session id is empty', '  ', [hash1]),
      ('there are no hashes', sessionId, <String>[]),
      ('a hash is too short', sessionId, ['abc123']),
      ('a hash is not hexadecimal', sessionId, ['g' * 64]),
    ]) {
      test('should throw without calling the server when $description', () async {
        await expectLater(useCase(sessionId: session, fileHashes: hashes), throwsException);

        verifyNever(() => repository.checkDuplicates(
            sessionId: any(named: 'sessionId'), fileHashes: any(named: 'fileHashes')));
      });
    }
  });
}
