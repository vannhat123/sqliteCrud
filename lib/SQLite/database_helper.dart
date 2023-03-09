import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqlite_crud/Users/usr_model.dart';
import '../Notes/note_model.dart';

class DatabaseHelper{

  final databaseName = "hashimi.db";

  //Tables and queries as a variable
  String userTable = "create table users (usrId integer primary key autoincrement, usrName Text, usrPassword Text,image Text)";
  String userData = "insert into users (usrId, usrName, usrPassword) values(1,'flutter','123')";
  String notes = "create table notes (noteId integer primary key autoincrement, noteTitle Text, noteContent Text,noteStatus integer, createdAt DATETIME DEFAULT CURRENT_TIMESTAMP, updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP)";

  //Future init method to create a database, user table and user default data
  Future <Database> initDB()async{
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, databaseName);
    return await openDatabase(path,version: 1, onCreate: (db,version)async{

      //auto execute the user table into the database
      await db.execute(userTable);

      //auto execute the user default data in the table
      await db.rawQuery(userData);
      await db.execute(notes);
    });
  }
  
  //Authentication Method for login
  Future <bool> authentication(Users users)async{
    final Database db = await initDB();
    var result = await db.rawQuery("select * from users where usrName = '${users.usrName}' and usrPassword = '${users.usrPassword}' ");
    if(result.isNotEmpty){

      return true;
    }else{
      return false;
    }
  }

  //Method for creating an account
  Future <int> createUsers(Users users) async {
    final Database db = await initDB();
    return db.insert('users', users.toMap());
  }

  //Method to show users
  Future <List<Users>> getUsers () async{
    final Database db = await initDB();
    final List<Map<String, Object?>>  queryResult = await db.query('users',orderBy: 'usrId');
    return queryResult.map((e) => Users.fromMap(e)).toList();
  }



  // Delete a user
  Future<void> deleteUser(String id) async {
    final db = await initDB();
    try {
      await db.delete("users", where: "usrId = ?", whereArgs: [id]);
    } catch (err) {
      if (kDebugMode){
        print("deleting failed: $err");
      }
    }
  }

  //Update user
  Future <int> updateUser(Users users)async{
    final Database db = await initDB();
    var result = await db.update('users', users.toMap(), where: 'usrId = ?', whereArgs: [users.usrId]);
    return result;
  }

  //Total users count
  Future <int?> totalUsers() async {
    final Database db = await initDB();
    final count = Sqflite.firstIntValue(await db.rawQuery("select count(*) from users"));
    return count;
  }


  //Notes ----------------------------------------------------------------------

  //Create a new note
  Future <int> createNote(Notes note)async{
    final Database db = await initDB();
    return db.insert('notes', note.toMap());
  }

  //Show incomplete notes with 1 status
  Future <List<Notes>> getNotes () async{
    final Database db = await initDB();
    final List<Map<String, Object?>>  queryResult = await db.query('notes',orderBy: 'noteId');
    return queryResult.map((e) => Notes.fromMap(e)).toList();
  }

  //show completed notes with 0 status
  Future <List<Notes>> getCompletedNotes () async{
    final Database db = await initDB();
    final List<Map<String, Object?>>  queryResult = await db.query('notes',orderBy: 'noteId',where: 'noteStatus = 0');
    return queryResult.map((e) => Notes.fromMap(e)).toList();
  }

  //show pending notes with 0 status
  Future <List<Notes>> getPendingNotes () async{
    final Database db = await initDB();
    final List<Map<String, Object?>>  queryResult = await db.query('notes',orderBy: 'noteId',where: 'noteStatus = 1');
    return queryResult.map((e) => Notes.fromMap(e)).toList();
  }


  // Delete
  Future<void> deleteNote(String id) async {
    final db = await initDB();
    try {
      await db.delete("notes", where: "noteId = ?", whereArgs: [id]);
    } catch (err) {
      if (kDebugMode){
        print("deleting failed: $err");
      }
    }
  }

  //Update note
  Future <int> updateNotes(Notes note)async{
    final Database db = await initDB();
    var result = await db.update('notes', note.toMap(), where: 'noteId = ?', whereArgs: [note.noteId]);
    return result;
  }

  //Update note Status to complete
  Future <int> setNoteStatus(int? id)async{
    final Database db = await initDB();
    final res = await db.rawUpdate('UPDATE notes SET noteStatus = 0 WHERE noteId = ?', [id]);
    return res;
  }

  //Total note count
  Future <int?> totalNotes() async {
    final Database db = await initDB();
    final count = Sqflite.firstIntValue(await db.rawQuery("select count(*) from notes"));
    return count;
  }

 }