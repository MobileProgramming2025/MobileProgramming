import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'user.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          '''
          CREATE TABLE user(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            profile_image_path TEXT
          )
          ''',
        );
      },
    );
  }

  Future<void> saveProfileImagePath(String path) async {
    final db = await database;
    await db.insert(
      'user',
      {'profile_image_path': path},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getProfileImagePath() async {
    final db = await database;
    final result = await db.query('user');
    if (result.isNotEmpty) {
      return result.first['profile_image_path'] as String?;
    }
    return null;
  }
}
