import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/errors/base/failure_codes.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/features/folders/domain/entities/album_cover.dart';
import 'package:photo_manager_app/features/folders/domain/entities/cover_change.dart';
import 'package:photo_manager_app/features/folders/domain/entities/cover_target.dart';
import 'package:photo_manager_app/features/folders/domain/entities/folder_covers.dart';
import 'package:photo_manager_app/features/folders/domain/repositories/covers_repository.dart';
import 'package:photo_manager_app/features/folders/domain/use_cases/apply_cover_changes_use_case.dart';
import 'package:photo_manager_app/features/folders/domain/use_cases/get_album_covers_use_case.dart';
import 'package:photo_manager_app/features/folders/domain/use_cases/get_cover_targets_use_case.dart';
import 'package:photo_manager_app/features/folders/domain/use_cases/set_album_covers_use_case.dart';

class MockCoversRepository extends Mock implements CoversRepository {}

Matcher failsWith(String code) => throwsA(isA<ValidationFailure>().having((f) => f.code, 'code', code));

void main() {
  late MockCoversRepository repository;

  setUp(() => repository = MockCoversRepository());

  AlbumCover cover(String fileId, int position) =>
      AlbumCover(fileId: fileId, position: position, sourceFolderId: 'x', sourceFolderName: 'X');

  CoverTarget target(String folderId, List<String> coverIds) => CoverTarget(
        folderId: folderId,
        name: folderId,
        depth: 0,
        containsDirectly: true,
        covers: [for (var i = 0; i < coverIds.length; i++) cover(coverIds[i], i)],
      );

  group('GetCoverTargetsUseCase', () {
    late GetCoverTargetsUseCase useCase;
    setUp(() => useCase = GetCoverTargetsUseCase(repository));

    test('should get the targets of up to 3 photos once each', () async {
      // Arrange
      when(() => repository.getCoverTargets(any())).thenAnswer((_) async => [target('a1', [])]);

      // Act
      final targets = await useCase(['p1', 'p2', 'p1']);

      // Assert
      expect(targets.single.folderId, 'a1');
      verify(() => repository.getCoverTargets(['p1', 'p2'])).called(1);
    });

    test('should reject more than 3 photos', () async {
      await expectLater(useCase(['1', '2', '3', '4']), failsWith(FailureCodes.folderCoversLimitExceeded));
      verifyNever(() => repository.getCoverTargets(any()));
    });

    test('should reject no photos', () async {
      await expectLater(useCase([]), failsWith(FailureCodes.folderCoverFileNotValid));
    });
  });

  group('ApplyCoverChangesUseCase', () {
    late ApplyCoverChangesUseCase useCase;
    setUp(() {
      useCase = ApplyCoverChangesUseCase(repository);
      when(() => repository.applyCoverChanges(any(), any())).thenAnswer((invocation) async {
        final changes = invocation.positionalArguments[1] as List<CoverChange>;
        return [for (final c in changes) FolderCovers(folderId: c.folderId, covers: const [])];
      });
    });

    final targets = [
      target('root', ['c1']),
      target('beach', ['c1', 'c2', 'c3']),
      target('sunsets', []),
    ];

    test('should add, remove and replace for one photo in one request', () async {
      // Arrange
      final changes = {
        'c1': [
          const CoverChange.remove('root'),
          const CoverChange.add('sunsets'),
        ],
      };

      // Act
      final result = await useCase(targets: targets, changesByFile: changes);

      // Assert
      verify(() => repository.applyCoverChanges('c1', changes['c1']!)).called(1);
      expect(result.map((f) => f.folderId), ['root', 'sunsets']);
    });

    test('should accept replacing a cover of a full album', () async {
      // Act
      await useCase(targets: targets, changesByFile: {
        'p1': [const CoverChange.replace('beach', 'c2')],
      });

      // Assert
      verify(() => repository.applyCoverChanges('p1', [const CoverChange.replace('beach', 'c2')])).called(1);
    });

    test('should reject adding to a full album without a replacement', () async {
      await expectLater(
        useCase(targets: targets, changesByFile: {'p1': [const CoverChange.add('beach')]}),
        failsWith(FailureCodes.folderCoversLimitExceeded),
      );
      verifyNever(() => repository.applyCoverChanges(any(), any()));
    });

    test('should reject filling an album beyond 3 with several photos', () async {
      // root has 1 cover: two more fit, a third does not.
      await expectLater(
        useCase(targets: targets, changesByFile: {
          'p1': [const CoverChange.add('root')],
          'p2': [const CoverChange.add('root')],
          'p3': [const CoverChange.add('root')],
        }),
        failsWith(FailureCodes.folderCoversLimitExceeded),
      );
      verifyNever(() => repository.applyCoverChanges(any(), any()));
    });

    test('should send one request per photo when several fit', () async {
      // Act
      await useCase(targets: targets, changesByFile: {
        'p1': [const CoverChange.add('root')],
        'p2': [const CoverChange.add('root')],
      });

      // Assert
      verify(() => repository.applyCoverChanges('p1', any())).called(1);
      verify(() => repository.applyCoverChanges('p2', any())).called(1);
    });

    test('should reject more than 3 photos', () async {
      await expectLater(
        useCase(targets: targets, changesByFile: {
          for (final id in ['p1', 'p2', 'p3', 'p4']) id: [const CoverChange.add('sunsets')],
        }),
        failsWith(FailureCodes.folderCoversLimitExceeded),
      );
    });

    test('should reject replacing a photo that is not a cover', () async {
      await expectLater(
        useCase(targets: targets, changesByFile: {'p1': [const CoverChange.replace('beach', 'nope')]}),
        failsWith(FailureCodes.folderCoverReplaceNotValid),
      );
    });

    test('should reject the same cover being replaced twice', () async {
      await expectLater(
        useCase(targets: targets, changesByFile: {
          'p1': [const CoverChange.replace('beach', 'c2')],
          'p2': [const CoverChange.replace('beach', 'c2')],
        }),
        failsWith(FailureCodes.folderCoverReplaceNotValid),
      );
    });

    test('should reject adding a photo that already is a cover', () async {
      await expectLater(
        useCase(targets: targets, changesByFile: {'c1': [const CoverChange.add('root')]}),
        failsWith(FailureCodes.folderCoverDuplicated),
      );
    });

    test('should reject removing a photo that is not a cover', () async {
      await expectLater(
        useCase(targets: targets, changesByFile: {'p1': [const CoverChange.remove('root')]}),
        failsWith(FailureCodes.folderCoverFileNotValid),
      );
    });

    test('should reject albums outside the targets and repeated albums', () async {
      await expectLater(
        useCase(targets: targets, changesByFile: {'p1': [const CoverChange.add('other')]}),
        failsWith(FailureCodes.folderCoverFileNotValid),
      );
      await expectLater(
        useCase(targets: targets, changesByFile: {
          'p1': [const CoverChange.add('sunsets'), const CoverChange.remove('sunsets')],
        }),
        failsWith(FailureCodes.folderCoverFileNotValid),
      );
    });

    test('should reject no changes', () async {
      await expectLater(
        useCase(targets: targets, changesByFile: {'p1': []}),
        failsWith(FailureCodes.validationError),
      );
    });

    test('should keep the last state of each album across photos', () async {
      // Arrange
      when(() => repository.applyCoverChanges('p1', any())).thenAnswer(
        (_) async => [FolderCovers(folderId: 'root', covers: [cover('c1', 0), cover('p1', 1)])],
      );
      when(() => repository.applyCoverChanges('p2', any())).thenAnswer(
        (_) async => [FolderCovers(folderId: 'root', covers: [cover('c1', 0), cover('p1', 1), cover('p2', 2)])],
      );

      // Act
      final result = await useCase(targets: targets, changesByFile: {
        'p1': [const CoverChange.add('root')],
        'p2': [const CoverChange.add('root')],
      });

      // Assert
      expect(result.single.covers, hasLength(3));
    });
  });

  group('GetAlbumCoversUseCase', () {
    test('should return the covers of the album', () async {
      // Arrange
      when(() => repository.getAlbumCovers('a1')).thenAnswer((_) async => [cover('c1', 0)]);

      // Act & Assert
      expect(await GetAlbumCoversUseCase(repository)('a1'), [cover('c1', 0)]);
    });
  });

  group('SetAlbumCoversUseCase', () {
    late SetAlbumCoversUseCase useCase;
    setUp(() => useCase = SetAlbumCoversUseCase(repository));

    test('should save the final order', () async {
      // Arrange
      when(() => repository.setAlbumCovers(any(), any())).thenAnswer((_) async => const []);

      // Act
      await useCase(folderId: 'a1', orderedFileIds: ['c3', 'c1']);

      // Assert
      verify(() => repository.setAlbumCovers('a1', ['c3', 'c1'])).called(1);
    });

    test('should allow an empty list to go back to automatic covers', () async {
      // Arrange
      when(() => repository.setAlbumCovers(any(), any())).thenAnswer((_) async => const []);

      // Act & Assert
      expect(await useCase(folderId: 'a1', orderedFileIds: []), isEmpty);
    });

    test('should reject more than 3 covers', () async {
      await expectLater(
        useCase(folderId: 'a1', orderedFileIds: ['1', '2', '3', '4']),
        failsWith(FailureCodes.folderCoversLimitExceeded),
      );
    });

    test('should reject repeated covers', () async {
      await expectLater(
        useCase(folderId: 'a1', orderedFileIds: ['1', '1']),
        failsWith(FailureCodes.folderCoverDuplicated),
      );
      verifyNever(() => repository.setAlbumCovers(any(), any()));
    });
  });
}
