import 'package:sqflite/sqflite.dart';
import '../local/db.dart';
import '../local/note.dart';
import '../remote/posts_api.dart';

class NoteRepository {
  NoteRepository({
    Future<Database> Function()? openDb,
    PostsApi? postsApi,
  })  : _openDb = openDb ?? openNotesDb,
        _postsApi = postsApi ?? PostsApi();

  final Future<Database> Function() _openDb;
  final PostsApi _postsApi;

  Future<List<Note>> fetchNotes() async {
    final db = await _openDb();
    final rows = await db.query('notes', orderBy: 'updated_at DESC');
    return rows.map(Note.fromMap).toList();
  }

  Future<Note> addNote({required String title, String body = ''}) async {
    final db = await _openDb();
    final note = Note(
      title: title,
      body: body,
      updatedAt: DateTime.now(),
      dirty: true,
    );
    final id = await db.insert('notes', note.toMap());
    return Note(
      id: id,
      title: note.title,
      body: note.body,
      updatedAt: note.updatedAt,
      dirty: true,
    );
  }

  Future<void> deleteNote(int id) async {
    final db = await _openDb();
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> countDirty() async {
    final db = await _openDb();
    final rows = await db.rawQuery(
        'SELECT COUNT(*) AS c FROM notes WHERE dirty = 1');
    return ((rows.first['c'] as num?)?.toInt() ?? 0);
  }

  Future<void> markAllSynced() async {
    final db = await _openDb();
    await db.update('notes', {'dirty': 0}, where: 'dirty = 1');
  }

  Future<List<Post>> readCachedPosts() async {
    final db = await _openDb();
    final rows = await db.query('cached_posts', orderBy: 'id ASC');
    return rows.map(Post.fromCache).toList();
  }

  Future<List<Post>> refreshPosts() async {
    final posts = await _postsApi.fetchPosts();
    final db = await _openDb();
    await db.transaction((transaction) async {
      await transaction.delete('cached_posts');
      for (final post in posts) {
        await transaction.insert(
          'cached_posts',
          post.toCacheMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
    return posts;
  }
}