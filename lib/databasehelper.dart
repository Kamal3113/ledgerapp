import 'dart:async';
import 'dart:io';

import 'package:balanceapp/credit.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'package:sqflite/sqflite.dart';


class PersonDatabaseProvider {
  PersonDatabaseProvider._();

  static final PersonDatabaseProvider db = PersonDatabaseProvider._();
  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await getDatabaseInstance();
    return _database;
  }
 static const String TABLE = 'person';
  static const String ID = 'id';
  static const String Amount = 'amount';
  static const String Type = 'type';
  

  Future<Database> getDatabaseInstance() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, "person.db");
    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute( "CREATE TABLE   $TABLE ($ID INTEGER PRIMARY KEY, $Amount TEXT,$Type TEXT)");
    });
  }

  addPersonToDatabase(Person person) async {
    final db = await database;
    var raw = await db.insert(
      "Person",
      person.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return raw;
  }

  updatePerson(Person person) async {
    final db = await database;
    var response = await db.update("Person", person.toMap(),
        where: "id = ?", whereArgs: [person.id]);
    return response;
  }

  Future<Person> getPersonWithId(int id) async {
    final db = await database;
    var response = await db.query("Person", where: "id = ?", whereArgs: [id]);
    return response.isNotEmpty ? Person.fromMap(response.first) : null;
  }

  Future<List<Person>> getAllPersons() async {
    final db = await database;
    var response = await db.query("Person");
    List<Person> list = response.map((c) => Person.fromMap(c)).toList();
    return list;
  }

  deletePersonWithId(int id) async {
    final db = await database;
    return db.delete("Person", where: "id = ?", whereArgs: [id]);
  }

  deleteAllPersons() async {
    final db = await database;
    db.delete("Person");
  }
}