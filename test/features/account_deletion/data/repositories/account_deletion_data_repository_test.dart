import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/crypto/domain/crypto_key.dart';
import 'package:photo_manager_app/features/account_deletion/data/data_sources/account_deletion_remote_data_source.dart';
import 'package:photo_manager_app/features/account_deletion/data/models/account_deletion_summary_model.dart';
import 'package:photo_manager_app/features/account_deletion/data/repositories/account_deletion_data_repository.dart';

class MockAccountDeletionRemoteDataSource extends Mock implements AccountDeletionRemoteDataSource {}

void main() {
  late MockAccountDeletionRemoteDataSource remote;
  late AccountDeletionDataRepository repository;

  setUp(() {
    remote = MockAccountDeletionRemoteDataSource();
    repository = AccountDeletionDataRepository(remoteDataSource: remote);
  });

  group('AccountDeletionDataRepository', () {
    test('should give the summary of the server', () async {
      const summary = AccountDeletionSummaryModel(files: 1, storedBytes: 2, albums: 3, devices: 4);
      when(() => remote.getSummary()).thenAnswer((_) async => summary);

      expect(await repository.getSummary(), summary);
    });

    test('should send the authKey in Base64', () async {
      when(() => remote.deleteAccount(any())).thenAnswer((_) async {});
      final authKey = CryptoKey(Uint8List.fromList(List.generate(32, (i) => i)));

      await repository.deleteAccount(authKey);

      verify(() => remote.deleteAccount(base64Encode(authKey.bytes))).called(1);
    });
  });
}
