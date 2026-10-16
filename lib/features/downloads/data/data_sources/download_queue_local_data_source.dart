import 'package:photo_manager_app/features/downloads/domain/entities/download_progress.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/queued_download.dart';
import 'package:sqflite/sqflite.dart';

/// The `download_queue` table of [AppDatabase] (version 2). Each isolate opens its own connection: SQLite keeps them
/// consistent.
abstract class DownloadQueueLocalDataSource {
  Future<void> enqueue(List<QueuedDownload> downloads);
  Future<List<QueuedDownload>> pending(int limit);
  Future<bool> isPending(String fileId);
  Future<void> setState(String fileId, String state);
  Future<List<String>> savedIds();
  Future<DownloadProgress> progress();
  Future<void> deletePending();
}

class DownloadQueueLocalDataSourceImpl implements DownloadQueueLocalDataSource {
  static const String table = 'download_queue';
  static const String statePending = 'pending';
  static const String stateSaved = 'saved';
  static const String stateFailed = 'failed';

  final Future<Database> Function() database;

  DownloadQueueLocalDataSourceImpl({required this.database});

  @override
  Future<void> enqueue(List<QueuedDownload> downloads) async {
    final db = await database();
    await db.transaction((txn) async {
      final pendingCount = Sqflite.firstIntValue(
              await txn.rawQuery('SELECT COUNT(*) FROM $table WHERE state = ?', [statePending])) ??
          0;
      if (pendingCount == 0) {
        // A new download: the files of the previous one stop counting in the progress
        await txn.delete(table);
      }
      var position = Sqflite.firstIntValue(await txn.rawQuery('SELECT MAX(position) FROM $table')) ?? 0;
      final batch = txn.batch();
      for (final download in downloads) {
        batch.insert(
          table,
          {
            'file_id': download.fileId,
            'album': download.album,
            'size_bytes': download.sizeBytes,
            'state': statePending,
            'position': ++position,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
      await batch.commit(noResult: true);
    });
  }

  @override
  Future<List<QueuedDownload>> pending(int limit) async {
    final rows = await (await database()).query(table,
        where: 'state = ?', whereArgs: [statePending], orderBy: 'position', limit: limit);
    return [
      for (final row in rows)
        QueuedDownload(
            fileId: row['file_id'] as String, album: row['album'] as String?, sizeBytes: row['size_bytes'] as int),
    ];
  }

  @override
  Future<bool> isPending(String fileId) async {
    final rows = await (await database())
        .query(table, columns: ['file_id'], where: 'file_id = ? AND state = ?', whereArgs: [fileId, statePending]);
    return rows.isNotEmpty;
  }

  @override
  Future<void> setState(String fileId, String state) async {
    await (await database()).update(table, {'state': state}, where: 'file_id = ?', whereArgs: [fileId]);
  }

  @override
  Future<List<String>> savedIds() async {
    final rows = await (await database())
        .query(table, columns: ['file_id'], where: 'state = ?', whereArgs: [stateSaved], orderBy: 'position');
    return [for (final row in rows) row['file_id'] as String];
  }

  @override
  Future<DownloadProgress> progress() async {
    final db = await database();
    final totals = (await db.rawQuery('''
      SELECT COUNT(*) AS total,
             COALESCE(SUM(CASE WHEN state = ? THEN 1 ELSE 0 END), 0) AS saved,
             COALESCE(SUM(CASE WHEN state = ? THEN 1 ELSE 0 END), 0) AS failed,
             COALESCE(SUM(size_bytes), 0) AS bytes_total,
             COALESCE(SUM(CASE WHEN state = ? THEN size_bytes ELSE 0 END), 0) AS bytes_saved
      FROM $table
    ''', [stateSaved, stateFailed, stateSaved])).first;
    final next = await db.query(table,
        columns: ['album'], where: 'state = ?', whereArgs: [statePending], orderBy: 'position', limit: 1);
    return DownloadProgress(
      total: totals['total'] as int,
      saved: totals['saved'] as int,
      failed: totals['failed'] as int,
      bytesTotal: totals['bytes_total'] as int,
      bytesSaved: totals['bytes_saved'] as int,
      currentAlbum: next.isEmpty ? null : next.first['album'] as String?,
    );
  }

  @override
  Future<void> deletePending() async {
    await (await database()).delete(table, where: 'state = ?', whereArgs: [statePending]);
  }
}
