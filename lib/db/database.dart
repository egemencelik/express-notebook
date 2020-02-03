import 'package:moor_flutter/moor_flutter.dart';
import 'package:moor/moor.dart';

part 'database.g.dart';

class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 6, max: 32)();
  TextColumn get content => text().named('body')();
  IntColumn get category => integer().nullable()();
  DateTimeColumn get date => dateTime().nullable()();
}

@DataClassName("Category")
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get description => text()();
  TextColumn get color => text()();
}

@UseMoor(tables: [Notes, Categories])
class MyDatabase extends _$MyDatabase {
  MyDatabase()
      : super(FlutterQueryExecutor.inDatabaseFolder(
          path: 'db.sqlite',
        ));

  @override
  int get schemaVersion => 1;

  //Queries

  Stream<List<Note>> getAllNotes() => select(notes).watch();

  Future addNote(NotesCompanion note) => into(notes).insert(note);

  Future deleteAllNotes() => (delete(notes)).go();

  Future deleteNote(int id) =>
      (delete(notes)..where((note) => note.id.equals(id))).go();

  Future updateNote(NotesCompanion note) => update(notes).replace(note);

  Stream<List<Note>> getNotesByCategory(int id) =>
      (select(notes)..where((note) => note.category.equals(id))).watch();

  Future<List<Note>> searchByTitle(String stringToSearch) =>
      (select(notes)..where((note) => note.title.like("%$stringToSearch%")))
          .get();

  Future<List<Note>> searchByContent(String stringToSearch) =>
      (select(notes)..where((note) => note.content.like("%$stringToSearch%")))
          .get();
}
