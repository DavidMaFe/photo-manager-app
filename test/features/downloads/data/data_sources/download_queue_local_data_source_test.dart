import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/database/app_database.dart';
import 'package:photo_manager_app/features/downloads/data/data_sources/download_queue_local_data_source.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/queued_download.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Database db;
  late DownloadQueueLocalDataSourceImpl dataSource;

  const trip1 = QueuedDownload(fileId: '1', album: 'Trip', sizeBytes: 100);
  const trip2 = QueuedDownload(fileId: '2', album: 'Trip', sizeBytes: 200);
  const loose = QueuedDownload(fileId: '3', sizeBytes: 300);

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath,
        options: OpenDatabaseOptions(version: 1, onCreate: (db, _) => AppDatabase.createDownloadQueue(db)));
    dataSource = DownloadQueueLocalDataSourceImpl(database: () async => db);
  });

  tearDown(() => db.close());

  group('DownloadQueueLocalDataSource', () {
    test('should give back the pending files in the order they were queued', () async {
      await dataSource.enqueue([trip1, trip2]);
      await dataSource.enqueue([loose]);

      expect(await dataSource.pending(10), [trip1, trip2, loose]);
      expect(await dataSource.pending(2), [trip1, trip2]);
      expect(await dataSource.isPending('3'), isTrue);
    });

    test('should skip files already queued', () async {
      await dataSource.enqueue([trip1]);
      await dataSource.enqueue([trip1, loose]);

      expect(await dataSource.pending(10), [trip1, loose]);
    });

    test('should count the progress of saved and failed files, with the album of the next one', () async {
      await dataSource.enqueue([trip1, trip2, loose]);
      await dataSource.setState('1', DownloadQueueLocalDataSourceImpl.stateSaved);
      await dataSource.setState('2', DownloadQueueLocalDataSourceImpl.stateFailed);

      final progress = await dataSource.progress();

      expect(progress.total, 3);
      expect(progress.saved, 1);
      expect(progress.failed, 1);
      expect(progress.bytesTotal, 600);
      expect(progress.bytesSaved, 100);
      expect(progress.currentAlbum, isNull);
      expect(progress.isRunning, isTrue);
      expect(await dataSource.savedIds(), ['1']);
      expect(await dataSource.isPending('1'), isFalse);
    });

    test('should start the progress again when a download is queued after the previous one ended', () async {
      await dataSource.enqueue([trip1]);
      await dataSource.setState('1', DownloadQueueLocalDataSourceImpl.stateSaved);

      await dataSource.enqueue([loose]);

      final progress = await dataSource.progress();
      expect(progress.total, 1);
      expect(progress.saved, 0);
      expect(await dataSource.savedIds(), isEmpty);
    });

    test('should add to the progress when a download is queued while another runs', () async {
      await dataSource.enqueue([trip1, trip2]);
      await dataSource.setState('1', DownloadQueueLocalDataSourceImpl.stateSaved);

      await dataSource.enqueue([loose]);

      final progress = await dataSource.progress();
      expect(progress.total, 3);
      expect(progress.saved, 1);
      expect(progress.currentAlbum, 'Trip');
    });

    test('should remove only the pending files when cancelled', () async {
      await dataSource.enqueue([trip1, trip2]);
      await dataSource.setState('1', DownloadQueueLocalDataSourceImpl.stateSaved);

      await dataSource.deletePending();

      expect(await dataSource.pending(10), isEmpty);
      final progress = await dataSource.progress();
      expect(progress.total, 1);
      expect(progress.isRunning, isFalse);
    });

    test('should report an empty progress with nothing queued', () async {
      expect((await dataSource.progress()).isEmpty, isTrue);
    });
  });
}
