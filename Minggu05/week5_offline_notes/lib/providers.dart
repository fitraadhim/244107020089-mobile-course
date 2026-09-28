import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/local/note.dart';
import 'data/prefs.dart';
import 'data/repositories/note_repository.dart';

final prefsRepositoryProvider = Provider<PrefsRepository>(
  (ref) => PrefsRepository(),
);
final noteRepositoryProvider = Provider<NoteRepository>(
  (ref) => NoteRepository(),
);

final darkModeProvider =
    AsyncNotifierProvider<DarkModeNotifier, bool>(DarkModeNotifier.new);
final forceOfflineProvider =
    AsyncNotifierProvider<ForceOfflineNotifier, bool>(ForceOfflineNotifier.new);
final notesProvider =
    AsyncNotifierProvider<NotesNotifier, List<Note>>(NotesNotifier.new);
final postsProvider =
    AsyncNotifierProvider<PostsNotifier, List<Post>>(PostsNotifier.new);

class DarkModeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => ref.watch(prefsRepositoryProvider).getDarkMode();

  Future<void> toggle() async {
    final next = !(state.value ?? false);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(prefsRepositoryProvider).setDarkMode(next);
      return next;
    });
  }
}

class ForceOfflineNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => ref.watch(prefsRepositoryProvider).getForceOffline();

  Future<void> setEnabled(bool value) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(prefsRepositoryProvider).setForceOffline(value);
      return value;
    });
    ref.invalidate(postsProvider);
  }
}

class NotesNotifier extends AsyncNotifier<List<Note>> {
  NoteRepository get _repository => ref.read(noteRepositoryProvider);

  @override
  Future<List<Note>> build() => _repository.fetchNotes();

  Future<void> add(String title, String body) async {
    await _repository.addNote(title: title, body: body);
    ref.invalidateSelf();
  }

  Future<void> delete(int id) async {
    await _repository.deleteNote(id);
    ref.invalidateSelf();
  }

  Future<int> sync() async {
    final count = await _repository.countDirty();
    if (count == 0) return 0;
    await Future<void>.delayed(const Duration(seconds: 1));
    await _repository.markAllSynced();
    ref.invalidateSelf();
    return count;
  }
}

class PostsNotifier extends AsyncNotifier<List<Post>> {
  NoteRepository get _repository => ref.read(noteRepositoryProvider);

  @override
  Future<List<Post>> build() async {
    final cached = await _repository.readCachedPosts();
    if (!(await ref.watch(forceOfflineProvider.future))) {
      unawaited(_refreshInBackground());
    }
    return cached;
  }

  Future<void> _refreshInBackground() async {
    try {
      final posts = await _repository.refreshPosts();
      state = AsyncData(posts);
    } catch (_) {
      // Cached data remains visible when the network is unavailable.
    }
  }

  Future<void> refresh() async {
    if (await ref.read(forceOfflineProvider.future)) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repository.refreshPosts);
  }
}