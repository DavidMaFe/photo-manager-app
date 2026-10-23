import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/database/app_database.dart';
import 'package:photo_manager_app/features/sync_session/data/data_sources/local/backup_progress_local_data_source.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Database db;
  late BackupProgressLocalDataSourceImpl dataSource;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath,
        options: OpenDatabaseOptions(version: 1, onCreate: (db, _) => AppDatabase.createBackupProgress(db)));
    dataSource = BackupProgressLocalDataSourceImpl(database: () async => db);
  });

  tearDown(() => db.close());

  group('BackupProgressLocalDataSource', () {
    group('watermark', () {
      test('should give back nothing before the first completed backup', () async {
        expect(await dataSource.watermark('user-1'), isNull);
      });

      test('should keep the last one of each account', () async {
        await dataSource.saveWatermark('user-1', DateTime(2026, 10, 1, 12));
        await dataSource.saveWatermark('user-1', DateTime(2026, 10, 23, 9, 30));
        await dataSource.saveWatermark('user-2', DateTime(2026, 1, 1));

        expect(await dataSource.watermark('user-1'), DateTime(2026, 10, 23, 9, 30));
        expect(await dataSource.watermark('user-2'), DateTime(2026, 1, 1));
      });
    });

    group('pending', () {
      test('should replace the pending files of the account and keep the other accounts apart', () async {
        await dataSource.replacePending('user-1', {'a', 'b'});
        await dataSource.replacePending('user-2', {'z'});

        await dataSource.replacePending('user-1', {'b', 'c'});

        expect(await dataSource.pending('user-1'), {'b', 'c'});
        expect(await dataSource.pending('user-2'), {'z'});
      });

      test('should empty the pending files', () async {
        await dataSource.replacePending('user-1', {'a'});

        await dataSource.replacePending('user-1', {});

        expect(await dataSource.pending('user-1'), isEmpty);
      });
    });
  });
}
