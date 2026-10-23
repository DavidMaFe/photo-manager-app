import 'package:photo_manager_app/features/local_albums/domain/entities/gallery_album.dart';
import 'package:sqflite/sqflite.dart';

/// The table `local_album_snapshot` of `AppDatabase`: the albums the last registration of each account saw, with
/// some ids of their files (ROADMAP-local-albums.md).
abstract class LocalAlbumSnapshotLocalDataSource {
  Future<Map<String, Set<String>>> lastSeen(String userId);
  Future<void> save(String userId, List<GalleryAlbum> albums);
}

class LocalAlbumSnapshotLocalDataSourceImpl implements LocalAlbumSnapshotLocalDataSource {
  final Future<Database> Function() database;

  LocalAlbumSnapshotLocalDataSourceImpl({required this.database});

  @override
  Future<Map<String, Set<String>>> lastSeen(String userId) async {
    final rows = await (await database()).query('local_album_snapshot',
        columns: ['local_album_id', 'sample_asset_ids'], where: 'user_id = ?', whereArgs: [userId]);
    return {
      for (final row in rows)
        row['local_album_id'] as String:
            (row['sample_asset_ids'] as String).split(',').where((id) => id.isNotEmpty).toSet(),
    };
  }

  @override
  Future<void> save(String userId, List<GalleryAlbum> albums) async {
    await (await database()).transaction((txn) async {
      await txn.delete('local_album_snapshot', where: 'user_id = ?', whereArgs: [userId]);
      final batch = txn.batch();
      for (final album in albums) {
        batch.insert('local_album_snapshot', {
          'user_id': userId,
          'local_album_id': album.id,
          'sample_asset_ids': album.sampleAssetIds.join(','),
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit(noResult: true);
    });
  }
}
