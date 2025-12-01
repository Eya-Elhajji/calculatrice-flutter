import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/calcul.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    // Initialiser FFI pour Windows/Linux/macOS
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    _database = await _initDB('calculator.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE history(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        expression TEXT NOT NULL,
        result TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertCalculation(Calculation calc) async {
    final db = await database;
    return await db.insert('history', calc.toMap());
  }

  Future<List<Calculation>> getAllCalculations() async {
    final db = await database;
    final result = await db.query('history', orderBy: 'id DESC');
    return result.map((json) => Calculation.fromMap(json)).toList();
  }

  Future<int> deleteCalculation(int id) async {
    final db = await database;
    return await db.delete('history', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> clearHistory() async {
    final db = await database;
    return await db.delete('history');
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
