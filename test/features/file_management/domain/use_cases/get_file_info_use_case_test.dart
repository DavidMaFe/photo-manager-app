import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/enums/file_status.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';
import 'package:photo_manager_app/features/file_management/domain/entities/file_info.dart';
import 'package:photo_manager_app/features/file_management/domain/repositories/file_management_repository.dart';
import 'package:photo_manager_app/features/file_management/domain/use_cases/get_file_info_use_case.dart';

class MockFileManagementRepository extends Mock implements FileManagementRepository {}

void main() {
  late MockFileManagementRepository repository;
  late GetFileInfoUseCase useCase;

  setUp(() {
    repository = MockFileManagementRepository();
    useCase = GetFileInfoUseCase(repository);
  });

  group('GetFileInfoUseCase', () {
    test('should return the file info from the repository', () async {
      // Arrange
      const info = FileInfo(id: '42', type: FileType.image, status: FileStatus.managed);
      when(() => repository.getFileInfo('42')).thenAnswer((_) async => info);

      // Act
      final result = await useCase('42');

      // Assert
      expect(result, info);
    });

    test('should reject an empty file ID without calling the repository', () async {
      // Act & Assert
      await expectLater(useCase('  '), throwsException);
      verifyNever(() => repository.getFileInfo(any()));
    });

    test('should propagate repository errors', () async {
      // Arrange
      when(() => repository.getFileInfo(any())).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(() => useCase('42'), throwsException);
    });
  });
}
