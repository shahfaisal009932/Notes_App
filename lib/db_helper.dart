import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  DbHelper._();

  ///singleton
  static DbHelper getInstance() => DbHelper._();
  Database? mDB;

  static const TABLE_NAME = "note";
  static const COLUMN_NOTE_ID = "n_id";
  static const COLUMN_NOTE_TITLE = "n_title";
  static const COLUMN_NOTE_DESC = "n_desc";
  static const COLUMN_NOTE_CREATED_AT = "n_created_at";

  Future<Database> initDb() async {
    mDB ??= await openDb();
    return mDB!;
  }

  Future<Database> openDb() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String dbPath = join(appDir.path, "notesDB.db");
    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) {
        /// create table here
        db.execute(
          "create table $TABLE_NAME($COLUMN_NOTE_ID integer primary key autoincrement, $COLUMN_NOTE_TITLE text, $COLUMN_NOTE_DESC text, $COLUMN_NOTE_CREATED_AT text)",
        );
      },
    );
  }

  //////////////////queries

  ///Add
  Future<bool> addNote({required String title, required String desc}) async {
    var db = await initDb();
    int rowsEffected = await db.insert(TABLE_NAME, {
      COLUMN_NOTE_TITLE: title,
      COLUMN_NOTE_DESC: desc,
      COLUMN_NOTE_CREATED_AT: DateTime.now().millisecondsSinceEpoch.toString(),
    });

    return rowsEffected > 0;
  }

  ///Fetch
  Future<List<Map<String, dynamic>>> fetchNote({String query = ""}) async {
    var db = await initDb();
    List<Map<String, dynamic>> allData = await db.query(
      TABLE_NAME,
      where: "$COLUMN_NOTE_TITLE LIKE ? OR $COLUMN_NOTE_DESC LIKE ?",
      whereArgs: ["%$query%", "%$query%"],
    );
    return allData;
  }

  ///Update
  Future<bool> updateNote({
    required String title,
    required String desc,
    required int id,
  }) async {
    var db = await initDb();
    int rowsEffected = await db.update(
      TABLE_NAME,
      {COLUMN_NOTE_TITLE: title, COLUMN_NOTE_DESC: desc},
      where: "$COLUMN_NOTE_ID = ?",
      whereArgs: [id],
    );
    return rowsEffected > 0;
  }

  ///Delete
  Future<bool> deleteNote({required int id}) async {
    var db = await initDb();
    int rowsEffected = await db.delete(
      TABLE_NAME,
      where: "$COLUMN_NOTE_ID = ?",
      whereArgs: [id],
    );
    return rowsEffected > 0;
  }

  ///Search
  Future<List<Map<String, dynamic>>> searchNote() async {
    var db = await initDb();
    List<Map<String, dynamic>> allData = await db.query(
      TABLE_NAME,
      where: "$COLUMN_NOTE_TITLE = ?",
      whereArgs: ["updated Note"],
    );
    return allData;
  }
}
