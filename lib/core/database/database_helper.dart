import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:kyodex/core/constants/app_constants.dart';


class DatabaseHelper {
  // ._ means its a private constructor
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _db;

  Future<Database> get database async{
    if(_db != null) return _db!;
    _db = await _initDb();
    return _db!;

    //! is to indicate that _db is not null
  }

  Future<Database> _initDb() async{
    if(Platform.isLinux || Platform.isWindows || Platform.isMacOS){

      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;

    }

    //get access to the Document dir of each platform and makes a folder
    // with the name of the database
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, AppConstants.dbName);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    //writing via code SQL lines on the Query via .Execute()
    await db.execute(
      '''
        CREATE TABLE pokemon (
          id          INTEGER PRIMARY KEY,
          national_dex INTEGER NOT NULL,
          name        TEXT NOT NULL,
          category    TEXT NOT NULL,
          sprite_url  TEXT NOT NULL,
          height      REAL NOT NULL,
          weight      REAL NOT NULL,
          generation  INTEGER NOT NULL,
          evolution_chain_url   TEXT NOT NULL DEFAULT ''
      )
    ''');

    await db.execute(
      '''
        CREATE TABLE types (
          id    INTEGER PRIMARY KEY,
          name  TEXT NOT NULL,
          color_hex TEXT NOT NULL
        )
      ''');

    await db.execute(
      '''
        CREATE TABLE pokemon_types (
          pokemon_id  INTEGER NOT NULL,
          type_id     INTEGER NOT NULL,
          slot        INTEGER NOT NULL,
          FOREIGN KEY (pokemon_id) REFERENCES pokemon(id),
          FOREIGN KEY (type_id)    REFERENCES types(id)
        )
      ''');

    await db.execute('''
      CREATE TABLE pokemon_descriptions (
        id          INTEGER PRIMARY KEY,
        pokemon_id  INTEGER NOT NULL,
        version     TEXT NOT NULL,
        description TEXT NOT NULL,
        FOREIGN KEY (pokemon_id) REFERENCES pokemon(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE evolutions (
        id       INTEGER PRIMARY KEY,
        from_id  INTEGER NOT NULL,
        to_id    INTEGER NOT NULL,
        method   TEXT NOT NULL,
          chain_id  INTEGER NOT NULL,    
        FOREIGN KEY (from_id) REFERENCES pokemon(id),
        FOREIGN KEY (to_id)   REFERENCES pokemon(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE pokemon_forms (
        id          INTEGER PRIMARY KEY,
        pokemon_id  INTEGER NOT NULL,
        form_name   TEXT NOT NULL,
        sprite_url  TEXT NOT NULL,
        FOREIGN KEY (pokemon_id) REFERENCES pokemon(id)
      )
    ''');

    await db.execute('''
        CREATE TABLE pokemon_form_types (
      form_name   TEXT NOT NULL,
      pokemon_id  INTEGER NOT NULL,
      type_id     INTEGER NOT NULL,
      slot        INTEGER NOT NULL,
      FOREIGN KEY (pokemon_id) REFERENCES pokemon(id),
      FOREIGN KEY (type_id) REFERENCES types(id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async{
    if (oldVersion < 3) {
      await db.execute('''
      CREATE TABLE pokemon_form_types (
        form_name   TEXT NOT NULL,
        pokemon_id  INTEGER NOT NULL,
        type_id     INTEGER NOT NULL,
        slot        INTEGER NOT NULL,
        FOREIGN KEY (pokemon_id) REFERENCES pokemon(id),
        FOREIGN KEY (type_id) REFERENCES types(id)
      )
    ''');
    }


  }
}