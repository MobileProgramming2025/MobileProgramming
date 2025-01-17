import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:mobileprogramming/models/user.dart';
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  
  static Database? _database;
  
  DatabaseHelper._internal();
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    
    _database = await _initDb();
    return _database!;
  }
  
  Future<Database> _initDb() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'my_database.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }
  
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id TEXT PRIMARY KEY,
        name TEXT,
        email TEXT,
        password TEXT,
        role TEXT,
        departmentId TEXT,
        enrolled_courses TEXT,
        taken_courses TEXT,
        added_date TEXT,
        year TEXT,
        profile_image_path TEXT
      )
    ''');
  }
  
  Future<void> updateProfileImagePath(String userId, String imagePath) async {
    final db = await database;
    
    await db.update(
      'users',
      {'profile_image_path': imagePath},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }
}
