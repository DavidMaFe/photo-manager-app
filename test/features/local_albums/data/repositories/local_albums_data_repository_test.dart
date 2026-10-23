import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/local_albums/data/data_sources/gallery_albums_local_data_source.dart';
import 'package:photo_manager_app/features/local_albums/data/data_sources/local_album_snapshot_local_data_source.dart';
import 'package:photo_manager_app/features/local_albums/data/data_sources/local_albums_remote_data_source.dart';
import 'package:photo_manager_app/features/local_albums/data/data_sources/local_albums_review_local_data_source.dart';
import 'package:photo_manager_app/features/local_albums/data/models/local_album_model.dart';
import 'package:photo_manager_app/features/local_albums/data/repositories/local_albums_data_repository.dart';
import 'package:photo_manager_app/features/local_albums/domain/enums/local_album_mode.dart';

import '../../../../fixtures/test_data.dart';

class MockGallery extends Mock implements GalleryAlbumsLocalDataSource {}

class MockSnapshot extends Mock implements LocalAlbumSnapshotLocalDataSource {}

class MockRemote extends Mock implements LocalAlbumsRemoteDataSource {}

class MockReview extends Mock implements LocalAlbumsReviewLocalDataSource {}

void main() {
  late MockGallery gallery;
  late MockSnapshot snapshot;
  late MockRemote remote;
  late MockReview review;
  late LocalAlbumsDataRepository repository;

  setUp(() {
    gallery = MockGallery();
    snapshot = MockSnapshot();
    remote = MockRemote();
    review = MockReview();
    repository = LocalAlbumsDataRepository(galleryDataSource: gallery, snapshotDataSource: snapshot,
        remoteDataSource: remote, reviewDataSource: review);
  });

  group('LocalAlbumsDataRepository', () {
    test('should read the albums of the gallery', () async {
      when(() => gallery.albums()).thenAnswer((_) async => [TestLocalAlbums.camera]);

      expect(await repository.galleryAlbums(), [TestLocalAlbums.camera]);
    });

    test('should keep and read what the account saw', () async {
      when(() => snapshot.save('user-1', [TestLocalAlbums.camera])).thenAnswer((_) async {});
      when(() => snapshot.lastSeen('user-1')).thenAnswer((_) async => {'1': {'a'}});

      await repository.saveLastSeen('user-1', [TestLocalAlbums.camera]);

      expect(await repository.lastSeen('user-1'), {'1': {'a'}});
      verify(() => snapshot.save('user-1', [TestLocalAlbums.camera])).called(1);
    });

    test('should read the files of an album of the gallery', () async {
      when(() => gallery.assetIds('1')).thenAnswer((_) async => {'a', 'b'});

      expect(await repository.galleryAlbumAssetIds('1'), {'a', 'b'});
    });

    test('should keep whether the account reviewed the albums', () async {
      when(() => review.isReviewed('user-1')).thenAnswer((_) async => false);
      when(() => review.markReviewed('user-1')).thenAnswer((_) async {});

      expect(await repository.isReviewed('user-1'), isFalse);
      await repository.markReviewed('user-1');

      verify(() => review.markReviewed('user-1')).called(1);
    });

    test('should send the options to the server', () async {
      const model = LocalAlbumModel(localAlbumId: '1', name: 'WhatsApp Images', mode: LocalAlbumMode.excluded);
      when(() => remote.setModes('uuid', {'1': LocalAlbumMode.excluded})).thenAnswer((_) async => [model]);
      when(() => remote.getAlbums('uuid')).thenAnswer((_) async => [model]);
      when(() => remote.register('uuid', const [])).thenAnswer((_) async => []);

      expect(await repository.setModes('uuid', {'1': LocalAlbumMode.excluded}), [model]);
      expect(await repository.albums('uuid'), [model]);
      expect(await repository.register('uuid', const []), isEmpty);
    });
  });
}
