import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/firestore_models/saved_location.dart';

class LocalDatabaseService {
  static final LocalDatabaseService instance = LocalDatabaseService._init();
  static Database? _database;
  LocalDatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sqlite.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';
    const intType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE savedLocations (
  id $idType,
  uid $textType,
  latitude $realType,
  longitude $realType,
  method $textType,
  placeId $textType,
  address $textType,
  visitedAt $textType
)
''');
    await db.execute('''
CREATE TABLE trackedLocations(
  id $idType,
  uid $textType,
  latitude $realType,
  longitude $realType,
  accuracy $realType,
  isMoving $intType,
  timestamp $textType,
  batteryLevel $realType,
  isCharging $intType
)
''');
  }

  Future<void> insertSavedLocation(SavedLocationModel location) async {
    final db = await instance.database;
    await db.insert('savedLocations', location.toJson());
  }

  Future<List<SavedLocationModel>> fetchSavedLocationsByUid(String uid) async {
    final db = await instance.database;
    final result = await db.query(
      'savedLocations',
      where: 'uid = ?', // Use ? to avoid SQL injection
      whereArgs: [uid], // Pass uid as a parameter
    );
    return result.map((json) => SavedLocationModel.fromJson(json)).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
