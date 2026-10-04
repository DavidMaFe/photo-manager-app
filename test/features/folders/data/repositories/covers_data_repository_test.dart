import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/folders/data/data_sources/covers_remote_data_source.dart';
import 'package:photo_manager_app/features/folders/data/models/cover_target_model.dart';
import 'package:photo_manager_app/features/folders/data/models/folder_covers_model.dart';
import 'package:photo_manager_app/features/folders/data/repositories/covers_data_repository.dart';
import 'package:photo_manager_app/features/folders/domain/entities/album_cover.dart';
import 'package:photo_manager_app/features/folders/domain/entities/cover_change.dart';

class MockCoversRemoteDataSource extends Mock implements CoversRemoteDataSource {}

void main() {
  late MockCoversRemoteDataSource remote;
  late CoversDataRepository repository;

  setUp(() {
    remote = MockCoversRemoteDataSource();
    repository = CoversDataRepository(remote);
  });

  CoverTargetModel target(String id, int depth, {bool direct = false}) =>
      CoverTargetModel(folderId: id, name: 'Album $id', depth: depth, containsDirectly: direct);

  group('getCoverTargets', () {
    test('should return the targets of a single photo as they are', () async {
      // Arrange
      final targets = [target('root', 0), target('beach', 1, direct: true)];
      when(() => remote.getCoverTargets('a')).thenAnswer((_) async => targets);

      // Act & Assert
      expect(await repository.getCoverTargets(['a']), targets);
    });

    test('should keep only the common ancestors of several photos, root first', () async {
      // Arrange: a is in root › beach › sunsets, b is in root › beach
      when(() => remote.getCoverTargets('a'))
          .thenAnswer((_) async => [target('root', 0), target('beach', 1), target('sunsets', 2, direct: true)]);
      when(() => remote.getCoverTargets('b'))
          .thenAnswer((_) async => [target('root', 0), target('beach', 1, direct: true)]);

      // Act
      final common = await repository.getCoverTargets(['a', 'b']);

      // Assert
      expect(common.map((t) => t.folderId), ['root', 'beach']);
      // Not every photo is directly in "beach".
      expect(common.last.containsDirectly, isFalse);
    });

    test('should mark an album as direct when every photo is directly in it', () async {
      // Arrange
      when(() => remote.getCoverTargets(any()))
          .thenAnswer((_) async => [target('root', 0), target('beach', 1, direct: true)]);

      // Act
      final common = await repository.getCoverTargets(['a', 'b', 'c']);

      // Assert
      expect(common.last.containsDirectly, isTrue);
      verify(() => remote.getCoverTargets(any())).called(3);
    });

    test('should return nothing when the photos share no album', () async {
      // Arrange
      when(() => remote.getCoverTargets('a')).thenAnswer((_) async => [target('trips', 0)]);
      when(() => remote.getCoverTargets('b')).thenAnswer((_) async => [target('family', 0)]);

      // Act & Assert
      expect(await repository.getCoverTargets(['a', 'b']), isEmpty);
    });
  });

  group('delegation', () {
    const cover = AlbumCover(fileId: '1', position: 0, sourceFolderId: '2', sourceFolderName: 'Playa');

    test('should apply the changes of one file', () async {
      // Arrange
      const folders = [FolderCoversModel(folderId: '2', covers: [cover])];
      when(() => remote.applyCoverChanges(any(), any())).thenAnswer((_) async => folders);

      // Act & Assert
      expect(await repository.applyCoverChanges('1', const [CoverChange.add('2')]), folders);
      verify(() => remote.applyCoverChanges('1', const [CoverChange.add('2')])).called(1);
    });

    test('should get and set the covers of an album', () async {
      // Arrange
      when(() => remote.getAlbumCovers('2')).thenAnswer((_) async => const [cover]);
      when(() => remote.setAlbumCovers('2', ['1'])).thenAnswer((_) async => const [cover]);

      // Act & Assert
      expect(await repository.getAlbumCovers('2'), const [cover]);
      expect(await repository.setAlbumCovers('2', ['1']), const [cover]);
    });
  });
}
