import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/download_failures.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/original_content.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/remote_media_file.dart';
import 'package:photo_manager_app/features/downloads/domain/use_cases/clear_shared_files_use_case.dart';
import 'package:photo_manager_app/features/downloads/domain/use_cases/share_files_use_case.dart';

import '../../downloads_mocks.dart';

void main() {
  late MockFileMappingRepository mappings;
  late MockDeviceGalleryRepository gallery;
  late MockOriginalContentReader reader;
  late MockShareRepository share;
  late ShareFilesUseCase useCase;

  final videoBytes = Stream.value(Uint8List.fromList([9]));

  setUpAll(() => registerFallbackValue(const Stream<Uint8List>.empty()));

  setUp(() {
    mappings = MockFileMappingRepository();
    gallery = MockDeviceGalleryRepository();
    reader = MockOriginalContentReader();
    share = MockShareRepository();
    useCase = ShareFilesUseCase(mappings, gallery, reader, share);
    when(() => mappings.all()).thenAnswer((_) async => {'1': '100'});
    when(() => gallery.isSupported()).thenAnswer((_) async => true);
    when(() => gallery.galleryIds()).thenAnswer((_) async => {'100'});
    when(() => share.temporaryFreeBytes()).thenAnswer((_) async => DownloadsTestData.roomyStorage.freeBytes);
    when(() => share.galleryFilePath('100')).thenAnswer((_) async => '/gallery/IMG_1.jpg');
    when(() => share.writeTemporary(any(), any())).thenAnswer((_) async => '/cache/share_tmp/a/VID_2.mp4');
    when(() => share.share(any())).thenAnswer((_) async {});
    when(() => share.clearTemporary()).thenAnswer((_) async {});
    when(() => reader.read('2', isVideo: true)).thenAnswer(
        (_) async => OriginalContent(fileName: 'VID_2.mp4', mimeType: 'video/mp4', length: 1, bytes: videoBytes));
  });

  group('ShareFilesUseCase', () {
    test('should share the gallery file when it is on the device and decrypt the others', () async {
      final progress = <int>[];

      await useCase([DownloadsTestData.photo, DownloadsTestData.video],
          onPrepared: (prepared, total) => progress.add(prepared));

      verify(() => share.share(['/gallery/IMG_1.jpg', '/cache/share_tmp/a/VID_2.mp4'])).called(1);
      verify(() => share.writeTemporary('VID_2.mp4', videoBytes)).called(1);
      verifyNever(() => reader.read('1', isVideo: any(named: 'isVideo')));
      expect(progress, [1, 2]);
    });

    test('should decrypt a mapped file that was deleted from the gallery', () async {
      when(() => gallery.galleryIds()).thenAnswer((_) async => {});
      when(() => reader.read('1', isVideo: false)).thenAnswer(
          (_) async => OriginalContent(fileName: 'IMG_1.jpg', mimeType: 'image/jpeg', length: 1, bytes: videoBytes));

      await useCase([DownloadsTestData.photo]);

      verify(() => share.writeTemporary('IMG_1.jpg', any())).called(1);
    });

    test('should refuse more than 50 files', () async {
      final files = [
        for (var i = 0; i < 51; i++) RemoteMediaFile(id: '$i', type: FileType.image, sizeBytes: 1),
      ];

      await expectLater(useCase(files), throwsA(isA<TooManyFilesToShareFailure>()));
      verifyNever(() => share.share(any()));
    });

    test('should refuse when the decrypted files do not fit in the free space', () async {
      when(() => share.temporaryFreeBytes()).thenAnswer((_) async => 1000);

      await expectLater(useCase([DownloadsTestData.video]), throwsA(isA<NotEnoughSpaceFailure>()));
      verifyNever(() => share.writeTemporary(any(), any()));
    });

    test('should remove the temporary files when preparing them fails', () async {
      when(() => reader.read('2', isVideo: true)).thenThrow(Exception('offline'));

      await expectLater(useCase([DownloadsTestData.video]), throwsA(isA<Exception>()));
      verify(() => share.clearTemporary()).called(1);
      verifyNever(() => share.share(any()));
    });

    test('should decrypt every file when the gallery cannot be read', () async {
      when(() => gallery.isSupported()).thenAnswer((_) async => false);
      when(() => reader.read('1', isVideo: false)).thenAnswer(
          (_) async => OriginalContent(fileName: 'IMG_1.jpg', mimeType: 'image/jpeg', length: 1, bytes: videoBytes));

      await useCase([DownloadsTestData.photo]);

      verifyNever(() => share.galleryFilePath(any()));
      verify(() => share.writeTemporary('IMG_1.jpg', any())).called(1);
    });

    test('should do nothing without files', () async {
      await useCase([]);

      verifyNever(() => share.share(any()));
    });
  });

  group('ClearSharedFilesUseCase', () {
    test('should remove the temporary files', () async {
      await ClearSharedFilesUseCase(share)();

      verify(() => share.clearTemporary()).called(1);
    });

    test('should not fail when they cannot be removed', () async {
      when(() => share.clearTemporary()).thenThrow(Exception('busy'));

      await ClearSharedFilesUseCase(share)();
    });
  });
}
