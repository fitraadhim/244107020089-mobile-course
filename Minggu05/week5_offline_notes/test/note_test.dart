import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:week5_offline_notes/data/local/note.dart';
import 'package:week5_offline_notes/data/repositories/note_repository.dart';
import 'package:week5_offline_notes/providers.dart';

class FakeNoteRepository extends NoteRepository {
  FakeNoteRepository({this._notes = const [], this.failure})
    : super(openDb: () async => throw UnimplementedError());

  final List<Note> _notes;
  final Object? failure;

  @override
  Future<List<Note>> fetchNotes() async {
    if (failure != null) throw failure!;
    return List<Note>.of(_notes);
  }

  @override
  Future<Note> addNote({required String title, String body = ''}) async {
    final note = Note(
      id: _notes.length + 1,
      title: title,
      body: body,
      updatedAt: DateTime.now(),
      dirty: true,
    );
    _notes.add(note);
    return note;
  }

  @override
  Future<void> deleteNote(int id) async {
    _notes.removeWhere((note) => note.id == id);
  }
}

void main() {
  test('Note.fromMap handles null and missing fields', () {
    final note = Note.fromMap({
      'id': null,
      'title': null,
      'body': null,
      'updated_at': null,
      'dirty': null,
    });

    expect(note.id, isNull);
    expect(note.title, isEmpty);
    expect(note.body, isEmpty);
    expect(note.dirty, isFalse);
    expect(note.updatedAt, DateTime.fromMillisecondsSinceEpoch(0));
  });

  test('dirty flag survives toMap and fromMap', () {
    final original = Note(
      id: 7,
      title: 'Offline',
      body: 'Draft',
      updatedAt: DateTime.utc(2026, 9, 28),
      dirty: true,
    );

    final restored = Note.fromMap(original.toMap());

    expect(restored.id, original.id);
    expect(restored.title, original.title);
    expect(restored.body, original.body);
    expect(restored.updatedAt, original.updatedAt);
    expect(restored.dirty, isTrue);
  });

  test('NotesNotifier succeeds with FakeNoteRepository', () async {
    final fake = FakeNoteRepository(
      notes: [
        Note(
          id: 1,
          title: 'Catatan lokal',
          updatedAt: DateTime.utc(2026, 9, 28),
          dirty: true,
        ),
      ],
    );
    final container = ProviderContainer(
      overrides: [noteRepositoryProvider.overrideWithValue(fake)],
    );
    addTearDown(container.dispose);

    final notes = await container.read(notesProvider.future);

    expect(notes, hasLength(1));
    expect(notes.single.title, 'Catatan lokal');
    expect(notes.single.dirty, isTrue);
  });

  test('NotesNotifier exposes FakeNoteRepository errors', () async {
    final container = ProviderContainer(
      overrides: [
        noteRepositoryProvider.overrideWithValue(
          FakeNoteRepository(failure: StateError('storage unavailable')),
        ),
      ],
    );
    addTearDown(container.dispose);

    await expectLater(
      container.read(notesProvider.future),
      throwsA(isA<StateError>()),
    );
    expect(container.read(notesProvider).hasError, isTrue);
  });
}
