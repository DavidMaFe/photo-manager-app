import 'package:sqflite/sqflite.dart';

/// The tables `backup_watermark` and `pending_uploads` of `AppDatabase` (ROADMAP-local-albums.md).
abstract class BackupProgressLocalDataSource {
  Future<DateTime?> watermark(String userId);
  Future<void> saveWatermark(String userId, DateTime scanStartedAt);
  Future<Set<String>> pending(String userId);
  Future<void> replacePending(String userId, Set<String> localIds);
}

class BackupProgressLocalDataSourceImpl implements BackupProgressLocalDataSource {
  final Future<Database> Function() database;

  BackupProgressLocalDataSourceImpl({required this.database});

  @override
  Future<DateTime?> watermark(String userId) async {
    final rows = await (await database())
        .query('backup_watermark', columns: ['scan_started_at'], where: 'user_id = ?', whereArgs: [userId]);
    if (rows.isEmpty) return null;
    return DateTime.fromMillisecondsSinceEpoch(rows.first['scan_started_at'] as int);
  }

  @override
  Future<void> saveWatermark(String userId, DateTime scanStartedAt) async {
    await (await database()).insert(
      'backup_watermark',
      {'user_id': userId, 'scan_started_at': scanStartedAt.millisecondsSinceEpoch},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<Set<String>> pending(String userId) async {
    final rows = await (await database())
        .query('pending_uploads', columns: ['local_id'], where: 'user_id = ?', whereArgs: [userId]);
    return {for (final row in rows) row['local_id'] as String};
  }

  @override
  Future<void> replacePending(String userId, Set<String> localIds) async {
    await (await database()).transaction((txn) async {
      await txn.delete('pending_uploads', where: 'user_id = ?', whereArgs: [userId]);
      final batch = txn.batch();
      for (final localId in localIds) {
        batch.insert('pending_uploads', {'user_id': userId, 'local_id': localId},
            conflictAlgorithm: ConflictAlgorithm.ignore);
      }
      await batch.commit(noResult: true);
    });
  }
}
