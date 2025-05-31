import 'dart:io';
import 'package:app1/models/%20%20%20%20%20%20cftv_info.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cftv_manager.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const nullableTextType = 'TEXT';

    await db.execute('''
CREATE TABLE cftv ( 
  id $idType, 
  nome $textType,
  ip $textType,
  mac $textType,
  numeroSerie $textType,
  imagePath $nullableTextType
  )
''');
  }

  Future<CftvInfo> create(CftvInfo cftv) async {
    final db = await instance.database;
    final id = await db.insert('cftv', cftv.toMap()..remove('id'));
    return cftv..id = id;
  }

  Future<CftvInfo?> readCftv(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'cftv',
      columns: ['id', 'nome', 'ip', 'mac', 'numeroSerie', 'imagePath'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return CftvInfo.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<CftvInfo>> readAllCftvs() async {
    final db = await instance.database;
    const orderBy = 'nome ASC';
    final result = await db.query('cftv', orderBy: orderBy);
    return result.map((json) => CftvInfo.fromMap(json)).toList();
  }

  Future<int> update(CftvInfo cftv) async {
    final db = await instance.database;
    return db.update(
      'cftv',
      cftv.toMap(),
      where: 'id = ?',
      whereArgs: [cftv.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    final cftvToDelete = await readCftv(id);
    if (cftvToDelete?.imagePath != null) {
      try {
        final imageFile = File(cftvToDelete!.imagePath!);
        if (await imageFile.exists()) {
          await imageFile.delete();
        }
      } catch (e) {
        print("Erro ao deletar arquivo de imagem: $e");
      }
    }

    return await db.delete('cftv', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
