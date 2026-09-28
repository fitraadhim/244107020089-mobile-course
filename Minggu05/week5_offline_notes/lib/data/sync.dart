import 'package:sqflite/sqflite.dart';

import 'local/db.dart';
import 'local/note.dart';
import 'remote/posts_api.dart';

enum ConflictPolicy { localUpdatedAtWins }

class SyncService {
  SyncService({Future<Database> Function()? openDb, PostsApi? postsApi})
    : _openDb = openDb ?? openNotesDb,
      _postsApi = postsApi ?? PostsApi();

  final Future<Database> Function() _openDb;
  final PostsApi _postsApi;

  Future<List<Post>> cachePosts({bool refresh = true}) async {
    final db = await _openDb();
    final rows = await db.query('cached_posts', orderBy: 'id ASC');
    final cached = rows.map(Post.fromCache).toList();
    if (!refresh) return cached;

    final posts = await _postsApi.fetchPosts();
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

  Future<int> syncNotes({
    ConflictPolicy conflictPolicy = ConflictPolicy.localUpdatedAtWins,
  }) async {
    if (conflictPolicy != ConflictPolicy.localUpdatedAtWins) {
      throw ArgumentError('Conflict policy belum didukung');
    }

    final db = await _openDb();
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM notes WHERE dirty = 1',
    );
    final dirtyCount = ((rows.first['c'] as num?)?.toInt() ?? 0);
    if (dirtyCount == 0) return 0;

    await Future<void>.delayed(const Duration(seconds: 1));
    await db.update('notes', {'dirty': 0}, where: 'dirty = 1');
    return dirtyCount;
  }
}
