import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/pending_files.dart';
import 'package:photo_manager_app/features/gallery/domain/repositories/gallery_repository.dart';
import 'package:photo_manager_app/features/gallery/domain/use_cases/get_pending_file_ids_use_case.dart';

class MockGalleryRepository extends Mock implements GalleryRepository {}

void main() {
  late MockGalleryRepository repository;
  late GetPendingFileIdsUseCase useCase;

  setUp(() {
    repository = MockGalleryRepository();
    useCase = GetPendingFileIdsUseCase(repository);
  });

  group('GetPendingFileIdsUseCase', () {
    test('should return the pending files of the repository', () async {
      // Arrange
      const pending = PendingFiles(fileIds: ['1', '2'], totalSizeBytes: 2048);
      when(() => repository.getPendingFileIds(type: any(named: 'type'), folderId: any(named: 'folderId')))
          .thenAnswer((_) async => pending);

      // Act
      final result = await useCase();

      // Assert
      expect(result, pending);
      verify(() => repository.getPendingFileIds(type: null, folderId: null)).called(1);
    });

    test('should pass the type and folder filters', () async {
      // Arrange
      when(() => repository.getPendingFileIds(type: any(named: 'type'), folderId: any(named: 'folderId')))
          .thenAnswer((_) async => const PendingFiles(fileIds: [], totalSizeBytes: 0));

      // Act
      await useCase(type: FileType.image, folderId: '3');

      // Assert
      verify(() => repository.getPendingFileIds(type: FileType.image, folderId: '3')).called(1);
    });

    test('should propagate repository errors', () async {
      // Arrange
      when(() => repository.getPendingFileIds(type: any(named: 'type'), folderId: any(named: 'folderId')))
          .thenThrow(Exception('Network error'));

      // Act & Assert
      expect(() => useCase(), throwsException);
    });
  });
}
