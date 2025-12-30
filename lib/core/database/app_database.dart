
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

    return await openDatabase(path, version: 1, onCreate: _onCreate);
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