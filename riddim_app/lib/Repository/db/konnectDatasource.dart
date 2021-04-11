import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riddim_app/data/Model/userModel.dart';
import "package:sqflite/sqflite.dart";


class KonnectDatasource {
  static final KonnectDatasource _instance = new KonnectDatasource.internal();

  factory KonnectDatasource() => _instance;

  static Database _db;

  Future<Database> get db async {
    if (_db != null)
      return _db;
    _db = await initDb();
    return _db;
  }

  KonnectDatasource.internal();

  initDb() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'riddimdriver.db');
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    // When creating the db, create the table
    //user table
    await db.execute(
        "CREATE TABLE User(id INTEGER PRIMARY KEY, user_id TEXT, username TEXT, fullname TEXT, email TEXT, contact TEXT, token TEXT, dob TEXT, address TEXT, gender TEXT, tickets TEXT, hours TEXT, distance TEXT, rating TEXT, base TEXT, farekm TEXT, faremin TEXT, earn TEXT)");
    print("Created tables");
  }

  Future<int> saveUser(User user) async {
    var dbClient = await db;
    int res = await dbClient.insert("User", user.toMap());
    return res;
  }

  Future<int> deleteUsers() async {
    var dbClient = await db;
    int res = await dbClient.delete("User");
    return res;
  }

  Future<bool> isLoggedIn() async {
    var dbClient = await db;
    var res = await dbClient.query("User");
    return res.isNotEmpty? true: false;
  }

  /*
  Future<User> getUser(int id) async {
    var dbClient = await db;
    var res = await  dbClient.query("User", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? User.map(res.first) : null;

  }

  getAllClients() async {
    final db = await database;
    var res = await db.query("Client");
    List<Client> list =
        res.isNotEmpty ? res.map((c) => Client.fromMap(c)).toList() : [];
    return list;
  }

  getBlockedClients() async {
    final db = await database;
    var res = await db.rawQuery("SELECT * FROM Client WHERE blocked=1");
    List<Client> list =
        res.isNotEmpty ? res.toList().map((c) => Client.fromMap(c)) : null;
    return list;
  }

  updateClient(Client newClient) async {
    final db = await database;
    var res = await db.update("Client", newClient.toMap(),
        where: "id = ?", whereArgs: [newClient.id]);
    return res;
  }

  deleteClient(int id) async {
    final db = await database;
    db.delete("Client", where: "id = ?", whereArgs: [id]);
  }

  */

  Future<User> getUser(String token) async {
    var dbClient = await db;
    var res = await  dbClient.query("User");
    return res.isNotEmpty ? User.map(res.first) : null;

  }

}