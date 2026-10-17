import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/original_content.dart';
import 'package:photo_manager_app/features/downloads/domain/use_cases/save_original_to_gallery_use_case.dart';

import '../../downloads_mocks.dart';

void main() {
  late MockOriginalContentReader reader;
  late MockDeviceGalleryRepository gallery;
  late MockFileMappingRepository mappings;
  late SaveOriginalToGalleryUseCase useCase;

  final photoBytes = Stream.value(Uint8List.fromList([1, 2, 3]));

  setUpAll(() => registerFallbackValue(const Stream<Uint8List>.empty()));

  setUp(() {
    reader = MockOriginalContentReader();
    gallery = MockDeviceGalleryRepository();
    mappings = MockFileMappingRepository();
    useCase = SaveOriginalToGalleryUseCase(reader, gallery, mappings);
    when(() => mappings.save(serverId: any(named: 'serverId'), localId: any(named: 'localId'),
        localPath: any(named: 'localPath'))).thenAnswer((_) async {});
    when(() => gallery.save(
          relativePath: any(named: 'relativePath'),
          fileName: any(named: 'fileName'),
          mimeType: any(named: 'mimeType'),
          takenAt: any(named: 'takenAt'),
          bytes: any(named: 'bytes'),
        )).thenAnswer((_) async => '555');
  });

  group('SaveOriginalToGalleryUseCase', () {
    test('should save a photo into the album folder dated when it was taken and remember it', () async {
      when(() => reader.read('1', isVideo: false)).thenAnswer((_) async =>
          OriginalContent(fileName: 'IMG_1.jpg', mimeType: 'image/jpeg', length: 3, bytes: photoBytes));

      final localId = await useCase(DownloadsTestData.downloadablePhoto, album: 'Vacaciones 2024');

      expect(localId, '555');
      verify(() => gallery.save(
            relativePath: 'Pictures/PhotoManager/Vacaciones 2024',
            fileName: 'IMG_1.jpg',
            mimeType: 'image/jpeg',
            takenAt: DateTime(2024, 8, 3, 10, 42),
            bytes: photoBytes,
          )).called(1);
      verify(() => mappings.save(
          serverId: '1', localId: '555', localPath: 'Pictures/PhotoManager/Vacaciones 2024/IMG_1.jpg')).called(1);
    });

    test('should save a video into Movies of the main folder when there is no album', () async {
      when(() => reader.read('2', isVideo: true)).thenAnswer((_) async =>
          OriginalContent(fileName: 'VID_2.mp4', mimeType: 'video/mp4', length: 3, bytes: photoBytes));

      await useCase(DownloadsTestData.downloadableVideo);

      verify(() => gallery.save(
            relativePath: 'Movies/PhotoManager',
            fileName: 'VID_2.mp4',
            mimeType: 'video/mp4',
            takenAt: any(named: 'takenAt'),
            bytes: any(named: 'bytes'),
          )).called(1);
    });

    test('should not remember the file when saving fails', () async {
      when(() => reader.read('1', isVideo: false)).thenAnswer((_) async =>
          OriginalContent(fileName: 'IMG_1.jpg', mimeType: 'image/jpeg', length: 3, bytes: photoBytes));
      when(() => gallery.save(
            relativePath: any(named: 'relativePath'),
            fileName: any(named: 'fileName'),
            mimeType: any(named: 'mimeType'),
            takenAt: any(named: 'takenAt'),
            bytes: any(named: 'bytes'),
          )).thenThrow(Exception('disk full'));

      await expectLater(useCase(DownloadsTestData.downloadablePhoto), throwsA(isA<Exception>()));
      verifyNever(() => mappings.save(serverId: any(named: 'serverId'), localId: any(named: 'localId'),
          localPath: any(named: 'localPath')));
    });

    group('relativePathFor', () {
      test('should replace the characters a folder name cannot have', () {
        expect(SaveOriginalToGalleryUseCase.relativePathFor(isVideo: false, album: 'Viaje: 2024/Playa'),
            'Pictures/PhotoManager/Viaje_ 2024_Playa');
      });

      test('should use the main folder for empty or dot names', () {
        expect(SaveOriginalToGalleryUseCase.relativePathFor(isVideo: false, album: '  '), 'Pictures/PhotoManager');
        expect(SaveOriginalToGalleryUseCase.relativePathFor(isVideo: true, album: '..'), 'Movies/PhotoManager');
      });
    });
  });
}
