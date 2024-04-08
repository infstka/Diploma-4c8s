import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider {
  static final DatabaseProvider dbProvider = DatabaseProvider();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await createDatabase();
    return _database!;
  }

  Future<Database> createDatabase() async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, "localDB.db");

    Database database = await openDatabase(path, version: 1, onCreate: (Database db, int version) async {
      await db.execute(
          "CREATE TABLE reviews ("
              "id INTEGER PRIMARY KEY,"
              "username TEXT,"
              "review_datetime DATETIME,"
              "review_mark INTEGER,"
              "review_comment TEXT"
              ")"
      );
      await db.execute(
          "CREATE TABLE users ("
              "id INTEGER PRIMARY KEY,"
              "username TEXT,"
              "user_email TEXT,"
              "user_type TEXT"
              ")"
      );
      await db.execute(
          "CREATE TABLE blocked_users ("
              "id INTEGER PRIMARY KEY,"
              "username TEXT,"
              "user_email TEXT,"
              "user_type TEXT"
              ")"
      );
      await db.execute(
          "CREATE TABLE bookings ("
              "id INTEGER PRIMARY KEY,"
              "username TEXT,"
              "data TEXT,"
              "timerange TEXT,"
              "status INT,"
              "category TEXT"
              ")"
      );
      await db.execute(
          "CREATE TABLE bookings_archive ("
              "id INTEGER PRIMARY KEY,"
              "username TEXT,"
              "data TEXT,"
              "timerange TEXT,"
              "category TEXT"
              ")"
      );
    });
    return database;
  }
}
