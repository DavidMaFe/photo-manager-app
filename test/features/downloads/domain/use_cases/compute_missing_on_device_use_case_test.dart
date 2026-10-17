import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/downloads/domain/use_cases/compute_missing_on_device_use_case.dart';

import '../../downloads_mocks.dart';

void main() {
  late MockServerFilesRepository serverFiles;
  late MockFileMappingRepository mappings;
  late MockDeviceGalleryRepository gallery;
  late ComputeMissingOnDeviceUseCase useCase;

  setUp(() {
    serverFiles = MockServerFilesRepository();
    mappings = MockFileMappingRepository();
    gallery = MockDeviceGalleryRepository();
    useCase = ComputeMissingOnDeviceUseCase(serverFiles, mappings, gallery);
  });

  group('ComputeMissingOnDeviceUseCase', () {
    test('should split the server files by whether their mapped file is still in the gallery', () async {
      // Arrange: photo mapped and in the gallery, video mapped but deleted outside the app, other photo not mapped
      when(() => serverFiles.files()).thenAnswer(
          (_) async => [DownloadsTestData.photo, DownloadsTestData.video, DownloadsTestData.otherPhoto]);
      when(() => mappings.all()).thenAnswer((_) async => {'1': '100', '2': '200'});
      when(() => gallery.galleryIds()).thenAnswer((_) async => {'100', '300'});

      // Act
      final result = await useCase();

      // Assert
      expect(result.onDevice, [DownloadsTestData.photo]);
      expect(result.missing, [DownloadsTestData.video, DownloadsTestData.otherPhoto]);
      expect(result.missingBytes, DownloadsTestData.video.sizeBytes + DownloadsTestData.otherPhoto.sizeBytes);
    });

    test('should ask only for the album and its subalbums when they are given', () async {
      when(() => serverFiles.files(folderId: '10', includeSubfolders: true))
          .thenAnswer((_) async => [DownloadsTestData.photo]);
      when(() => mappings.all()).thenAnswer((_) async => {});
      when(() => gallery.galleryIds()).thenAnswer((_) async => {});

      final result = await useCase(folderId: '10', includeSubfolders: true);

      expect(result.missing, [DownloadsTestData.photo]);
      verify(() => serverFiles.files(folderId: '10', includeSubfolders: true)).called(1);
    });

    test('should propagate a failure of the server', () async {
      when(() => serverFiles.files()).thenThrow(Exception('offline'));
      when(() => mappings.all()).thenAnswer((_) async => {});
      when(() => gallery.galleryIds()).thenAnswer((_) async => {});

      expect(useCase(), throwsA(isA<Exception>()));
    });
  });
}
