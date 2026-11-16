import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

Future<Database> openNotesDb() async {
  final databasePath = await getDatabasesPath();
  return openDatabase(
    path.join(databasePath, 'campus_notes.db'),
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE notes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          body TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          dirty INTEGER NOT NULL DEFAULT 1
        )
      ''');
    },
  );
}