import 'package:campus_notify/features/notes/domain/entities/note.dart';
import 'package:campus_notify/features/notes/domain/usecases/search_notes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final notes = [
    Note(title: 'Belanja mingguan', updatedAt: DateTime(2026, 9, 27)),
    Note(title: 'Jadwal kuliah', updatedAt: DateTime(2026, 9, 28)),
    Note(title: 'Daftar belanja', updatedAt: DateTime(2026, 9, 29)),
  ];

  test('filter judul mengabaikan huruf besar dan kecil', () {
    final result = const SearchNotes().call(notes, 'BELANJA');

    expect(result, hasLength(2));
    expect(
      result.map((note) => note.title),
      containsAll(['Belanja mingguan', 'Daftar belanja']),
    );
  });

  test('query yang tidak cocok mengembalikan daftar kosong', () {
    final result = const SearchNotes().call(notes, 'zzz-tak-ada');

    expect(result, isEmpty);
  });

  test('query kosong mengembalikan semua catatan', () {
    expect(const SearchNotes().call(notes, '  '), same(notes));
  });
}
