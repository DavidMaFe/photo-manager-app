import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/enums/file_status.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/remote_media_file.dart';
import 'package:photo_manager_app/features/downloads/domain/services/on_device_presence.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_file.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/pending_files.dart';
import 'package:photo_manager_app/features/gallery/domain/enums/file_filter.dart';
import 'package:photo_manager_app/features/gallery/domain/repositories/gallery_repository.dart';
import 'package:photo_manager_app/features/gallery/domain/use_cases/get_files_use_case.dart';

class MockGalleryRepository extends Mock implements GalleryRepository {}

class MockOnDevicePresence extends Mock implements OnDevicePresence {}

void main() {
  late MockGalleryRepository repository;
  late MockOnDevicePresence presence;
  late GetFilesUseCase useCase;

  final missing = [
    for (var i = 1; i <= 5; i++) RemoteMediaFile(id: '$i', type: FileType.image, sizeBytes: 10),
  ];
  GalleryFile file(String id) => GalleryFile(id: id, type: FileType.image, status: FileStatus.managed, capturedAt: null);

  setUpAll(() => registerFallbackValue(FileFilter.all));

  setUp(() {
    repository = MockGalleryRepository();
    presence = MockOnDevicePresence();
    useCase = GetFilesUseCase(repository, presence);
    when(() => presence.isKnown).thenReturn(true);
    when(() => presence.missing).thenReturn(missing);
    when(() => repository.getPendingFileIds()).thenAnswer(
        (_) async => const PendingFiles(fileIds: ['p1', 'p2'], totalSizeBytes: 0));
    when(() => repository.getFilesByIds(any()))
        .thenAnswer((i) async => [for (final id in i.positionalArguments[0] as List<String>) file(id)]);
  });

  group('GetFilesUseCase with FileFilter.notOnDevice', () {
    test('should cut the page from what this phone is missing and ask for its files by id', () async {
      final page = await useCase(page: 1, pageSize: 2, filter: FileFilter.notOnDevice);

      verify(() => repository.getFilesByIds(['3', '4'])).called(1);
      expect(page.files.map((f) => f.id), ['3', '4']);
      expect(page.hasNext, isTrue);
      expect(page.totalFilesCount, 5);
      expect(page.totalPendingCount, 2);
      verifyNever(() => repository.getFiles(page: any(named: 'page'), pageSize: any(named: 'pageSize'),
          filter: any(named: 'filter')));
    });

    test('should say there is no next page at the end', () async {
      final page = await useCase(page: 2, pageSize: 2, filter: FileFilter.notOnDevice);

      expect(page.files.map((f) => f.id), ['5']);
      expect(page.hasNext, isFalse);
    });

    test('should compute the presence first when it is not known', () async {
      when(() => presence.isKnown).thenReturn(false);
      when(() => presence.refresh()).thenAnswer((_) async {});

      await useCase(filter: FileFilter.notOnDevice);

      verify(() => presence.refresh()).called(1);
    });

    test('should not ask the server for files when nothing is missing', () async {
      when(() => presence.missing).thenReturn([]);

      final page = await useCase(filter: FileFilter.notOnDevice);

      expect(page.files, isEmpty);
      expect(page.hasNext, isFalse);
      verifyNever(() => repository.getFilesByIds(any()));
    });

    test('should give an empty page without presence', () async {
      final page = await GetFilesUseCase(repository)(filter: FileFilter.notOnDevice);

      expect(page.files, isEmpty);
    });
  });
}
