import 'package:nest/models/drug_container.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/drug.dart';

class DrugDb {
  static final DrugDb instance = DrugDb._init();
  static Database? _database;

  DrugDb._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDb("drugDb");
    return _database!;
  }

  Future<Database> _initDb(String filepath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filepath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
      // onUpgrade: _onUpgrade,
    );
  }

  // // UPGRADE DATABASE TABLES
  // void _onUpgrade(Database db, int oldVersion, int newVersion) {
  //   if (oldVersion < newVersion) {
  //     // db.execute("ALTER TABLE $tableName ALTER COLUMN $cre TEXT;");
  //     db.execute(
  //         "ALTER TABLE $tableName ADD COLUMN ${DrugFields.categoryId} INTEGER NOT NULL DEFAULT 0;");
  //   }
  // }

  Future _createDb(Database db, int version) async {
    const idType = "INTEGER PRIMARY KEY AUTOINCREMENT";
    const nameType = "TEXT NOT NULL";
    const descriptionType = "TEXT NOT NULL";
    const parentIdType = "INTEGER NOT NULL";

    await db.execute('''
    CREATE TABLE $tableName (
      ${DrugFields.id} $idType,
      ${DrugFields.name} $nameType,
      ${DrugFields.description} $descriptionType,
      ${DrugFields.parentId} $parentIdType,
      ${DrugFields.categoryId} $parentIdType,
      ${DrugFields.createdAt} $parentIdType
    )
    ''');

    await db.execute('''
    CREATE TABLE $drugContainerTableName (
      ${DrugContainerFields.id} $idType,
      ${DrugContainerFields.name} $nameType,
      ${DrugContainerFields.createdAt} $parentIdType
    )
    ''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  // ! DrugContainers !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  Future<int> createDrugContainer(DrugContainer drugContainer) async {
    final db = await instance.database;
    final id = db.insert(drugContainerTableName, drugContainer.toMap());
    return id;
  }

  Future<DrugContainer?> readDrugContainer(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      drugContainerTableName,
      columns: DrugContainerFields.values,
      where: '${DrugContainerFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return DrugContainer.fromJson(maps.first);
    }
    return null;
  }

  Future<int> getCategoryCount() async {
    final db = await instance.database;
    var x = await db.rawQuery('SELECT COUNT (*) from $drugContainerTableName');
    return x.first.values.first as int;
  }

  Future<List<DrugContainer>> readAllDrugContainers() async {
    final db = await instance.database;
    const orderBy = '${DrugContainerFields.createdAt} ASC';
    final result = await db.query(drugContainerTableName, orderBy: orderBy);

    return result.map((e) => DrugContainer.fromJson(e)).toList();
  }

  Future<int> updateDrugContainer(DrugContainer drugContainer) async {
    final db = await instance.database;
    final id = await db.update(
      drugContainerTableName,
      drugContainer.toMap(),
      where: '${DrugContainerFields.id} = ?',
      whereArgs: [drugContainer.id],
    );
    return id;
  }

  Future<int> deleteDrugContainer(int id) async {
    final db = await instance.database;

    return await db.delete(
      drugContainerTableName,
      where: '${DrugContainerFields.id} = ?',
      whereArgs: [id],
    );
  }

  // ! Drugs !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  Future<int> create(Drug drug) async {
    final db = await instance.database;
    final id = db.insert(tableName, drug.toMap());
    return id;
  }

  // ! Bulk insert with transaction
  Future<int> createBulk(
      List<Drug> drugs, List<DrugContainer> containers) async {
    final db = await instance.database;
    try {
      await db.transaction((txn) async {
        await txn.rawQuery('DELETE from $tableName');
        await txn.rawQuery('DELETE from $drugContainerTableName');

        for (var drug in drugs) {
          await txn.insert(tableName, drug.toMap());
        }
        for (var container in containers) {
          await txn.insert(drugContainerTableName, container.toMap());
        }
      });
    } catch (e) {
      return 0;
    }
    return 1;
  }

  Future<Drug?> read(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      tableName,
      columns: DrugFields.values,
      where: '${DrugFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Drug.fromJson(maps.first);
    }
    return null;
  }

  // ! read all sub drugs
  Future<int> getDrugCount() async {
    final db = await instance.database;
    var x = await db.rawQuery('SELECT COUNT (*) from $tableName');
    return x.first.values.first as int;
  }

  // ! read drugs with the same category
  Future<List<Drug>> readAll(int categoryId) async {
    final db = await instance.database;
    const orderBy = '${DrugFields.createdAt} ASC';
    final result = await db.query(
      tableName,
      where: '${DrugFields.categoryId} = ?',
      whereArgs: [categoryId],
      orderBy: orderBy,
    );

    return result.map((e) => Drug.fromJson(e)).toList();
  }

  // ! read all drugs
  Future<List<Drug>> readAllDrugs() async {
    final db = await instance.database;
    const orderBy = '${DrugFields.createdAt} ASC';
    final result = await db.query(tableName, orderBy: orderBy);

    return result.map((e) => Drug.fromJson(e)).toList();
  }

  // ! read Drugs with same drug name
  Future<List<Drug>> readAllWithName(String drugName) async {
    final db = await instance.database;
    const orderBy = '${DrugFields.createdAt} ASC';
    final result = await db.query(
      tableName,
      where: '${DrugFields.name} = ?',
      whereArgs: [drugName],
      orderBy: orderBy,
    );

    return result.map((e) => Drug.fromJson(e)).toList();
  }

  Future<int> update(Drug drug) async {
    final db = await instance.database;
    final id = await db.update(
      tableName,
      drug.toMap(),
      where: '${DrugFields.id} = ?',
      whereArgs: [drug.id],
    );
    return id;
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    // ! transaction with cascade delete
    // ! same for category
    return await db.delete(
      tableName,
      where: '${DrugFields.id} = ?',
      whereArgs: [id],
    );
  }
}
