
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {

  static AppDatabase? _instance;
  static Database? _database;

  AppDatabase._();

  factory AppDatabase() {
    _instance ??= AppDatabase._();
    return _instance!;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'photo_manager_db');

    return await openDatabase(path, version: 3, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE file_mapping (
        server_id TEXT PRIMARY KEY,
        local_id TEXT NOT NULL,
        local_path TEXT NOT NULL,
        hash TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_hash ON file_mapping(hash)
    ''');

    await createDownloadQueue(db);
    await createBackupProgress(db);
    await createLocalAlbumSnapshot(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await createDownloadQueue(db);
    }
    if (oldVersion < 3) {
      await createBackupProgress(db);
      await createLocalAlbumSnapshot(db);
    }
  }

  /// What the backups of each account have seen (ROADMAP-local-albums.md): when the last completed backup started to
  /// look at the gallery, and the files a backup skipped (did not fit, too big for the plan, failed), retried by the
  /// next ones. Shared by the UI isolate and the WorkManager isolate.
  static Future<void> createBackupProgress(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE backup_watermark (
        user_id TEXT PRIMARY KEY,
        scan_started_at INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE pending_uploads (
        user_id TEXT NOT NULL,
        local_id TEXT NOT NULL,
        PRIMARY KEY (user_id, local_id)
      )
    ''');
  }

  /// The albums of the gallery the last registration saw, with some ids of their files: an album that disappears and
  /// a new one with its files is a folder renamed on the device (ROADMAP-local-albums.md).
  static Future<void> createLocalAlbumSnapshot(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE local_album_snapshot (
        user_id TEXT NOT NULL,
        local_album_id TEXT NOT NULL,
        sample_asset_ids TEXT NOT NULL,
        PRIMARY KEY (user_id, local_album_id)
      )
    ''');
  }

  /// Files waiting to be saved into the gallery (ROADMAP-downloads-and-account-deletion.md). Shared by the UI
  /// isolate, which adds them, and the WorkManager isolate, which saves them.
  static Future<void> createDownloadQueue(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE download_queue (
        file_id TEXT PRIMARY KEY,
        album TEXT,
        size_bytes INTEGER NOT NULL,
        state TEXT NOT NULL,
        position INTEGER NOT NULL
      )
    ''');
  }

  Future<void> saveFileMapping({
    required String serverId,
    required String localId,
    required String localPath,
    required String hash,
  }) async {

    final db = await database;
    await db.insert(
      'file_mapping',
      {
        'server_id': serverId,
        'local_id': localId,
        'local_path': localPath,
        'hash': hash,
        'created_at': DateTime.now().millisecondsSinceEpoch
      },
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  /// Every mapping, as server id → local id.
  Future<Map<String, String>> getAllMappings() async {

    final db = await database;
    final rows = await db.query('file_mapping', columns: ['server_id', 'local_id']);
    return {for (final row in rows) row['server_id'] as String: row['local_id'] as String};
  }

  Future<Map<String, dynamic>?> getFileMapping(String serverId) async {

    final db = await database;
    final results = await db.query(
      'file_mapping',
      where: 'server_id = ?',
      whereArgs: [serverId]
    );

    if (results.isEmpty) return null;
    return results.first;
  }

  Future<List<Map<String, dynamic>>> getFileMappings(List<String> serverIds) async {

    final db = await database;
    final placeholders = List.filled(serverIds.length, '?').join(',');

    final results = await db.query(
      'file_mapping',
      where: 'server_id IN ($placeholders)',
      whereArgs: serverIds
    );

    return results;
  }

  Future<void> deleteMapping(String serverId) async {

    final db = await database;
    await db.delete(
      'file_mapping',
      where: 'server_id = ?',
      whereArgs: [serverId]
    );
  }

  /// Forgets every file of the gallery linked to the server (the account was deleted).
  Future<void> clearFileMappings() async {
    final db = await database;
    await db.delete('file_mapping');
  }

  Future<void> deleteMappings(List<String> serverIds) async {

    final db = await database;
    final placeholders = List.filled(serverIds.length, '?').join(',');

    await db.delete(
      'file_mapping',
      where: 'server_id IN ($placeholders)',
      whereArgs: serverIds
    );
  }
}