import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/database/app_database.dart';
import 'package:photo_manager_app/features/local_albums/data/data_sources/local_album_snapshot_local_data_source.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../../fixtures/test_data.dart';

void main() {
  late Database db;
  late LocalAlbumSnapshotLocalDataSourceImpl dataSource;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath,
        options: OpenDatabaseOptions(version: 1, onCreate: (db, _) => AppDatabase.createLocalAlbumSnapshot(db)));
    dataSource = LocalAlbumSnapshotLocalDataSourceImpl(database: () async => db);
  });

  tearDown(() => db.close());

  group('LocalAlbumSnapshotLocalDataSource', () {
    test('should give back the albums saved with some ids of their files', () async {
      await dataSource.save('user-1', [TestLocalAlbums.camera, TestLocalAlbums.vacaciones]);

      expect(await dataSource.lastSeen('user-1'), {
        TestLocalAlbums.camera.id: {'c1', 'c2'},
        TestLocalAlbums.vacaciones.id: {'v1', 'v2', 'v3'},
      });
    });

    test('should replace what the account saw before, and keep the other accounts apart', () async {
      await dataSource.save('user-1', [TestLocalAlbums.camera]);
      await dataSource.save('user-2', [TestLocalAlbums.whatsapp]);

      await dataSource.save('user-1', [TestLocalAlbums.vacaciones]);

      expect((await dataSource.lastSeen('user-1')).keys, [TestLocalAlbums.vacaciones.id]);
      expect((await dataSource.lastSeen('user-2')).keys, [TestLocalAlbums.whatsapp.id]);
    });

    test('should give back nothing the first time', () async {
      expect(await dataSource.lastSeen('user-1'), isEmpty);
    });
  });
}
