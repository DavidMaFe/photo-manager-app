import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/sync_session/data/models/encrypted_upload_model.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/encrypted_upload.dart';

EncryptedUpload upload({String? localAlbumId}) => EncryptedUpload(
      encryptedFile: File('unused'),
      encryptedThumbnail: null,
      dedupHash: 'hmac',
      isVideo: false,
      capturedAt: DateTime(2024, 8, 15, 18, 30),
      keyVersion: 1,
      encryptedFileKey: Uint8List.fromList([1]),
      encryptedMetadata: Uint8List.fromList([2]),
      localAlbumId: localAlbumId,
    );

void main() {
  group('EncryptedUploadModel', () {
    group('metadataToJson', () {
      test('should send the album of the gallery of the file', () {
        expect(EncryptedUploadModel.metadataToJson(upload(localAlbumId: '747804901'))['localAlbumId'], '747804901');
      });

      test('should leave out the album when the file is in none', () {
        expect(EncryptedUploadModel.metadataToJson(upload()).containsKey('localAlbumId'), isFalse);
      });
    });
  });
}
