import 'dart:io';
import 'package:flutter/material.dart';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import 'note.dart';

const String table_notes = 'notes';
const String column_id = 'id';
const String column_title = 'title';
const String column_content = 'content';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._constructor();

  static const _file = "Notes.db";
  static const _version = 1;

  Database _database;

  DatabaseHelper._constructor();

  Future<Database> get database async {
    if (_database == null) {
      Directory documents = await getApplicationDocumentsDirectory();
      String path = p.join(documents.path, _file);

      _database =
          await openDatabase(path, version: _version, onCreate: (db, version) {
        db.execute('''
            CREATE TABLE $table_notes (
              $column_id INTEGER PRIMARY KEY AUTOINCREMENT,
              $column_title TEXT,
              $column_content TEXT              
            )
        ''');
      });
    }

    return _database;
  }

  Future<List<Note>> findAll() async {
    var db = await database;
    var entities = List<Note>();

    var result = await db
        .query(table_notes, columns: [column_id, column_title, column_content]);

    for (var value in result) {
      entities.add(Note.fromMap(value));
    }

    return entities;
  }

  void persist(Note note) async {
    var db = await database;

    if(note.id == null) {
      var id = await db.insert(table_notes, note.toMap());

      note.id = id;
    } else {
      await db.update(table_notes, note.toMap(),
          where: "$column_id = ?",
          whereArgs: [note.id]
      );
    }
  }

  void delete(Note note) async {
    var db = await database;

    await db.delete(table_notes,
        where: "$column_id = ?",
        whereArgs: [note.id]
    ).then((val) {
      debugPrint("$val");
    });
  }
}
