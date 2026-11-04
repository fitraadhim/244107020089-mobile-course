import 'package:campus_notify/features/notes/presentation/pages/notes_page.dart';
import 'package:campus_notify/features/notes/presentation/providers/notes_providers.dart';
import 'package:campus_notify/features/notes/domain/entities/note.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('menampilkan empty state saat query tidak cocok', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notesProvider.overrideWith(
            (ref) async => [
              Note(title: 'Jadwal kuliah', updatedAt: DateTime(2026, 9, 28)),
            ],
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: NotesPage())),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'belanja');
    await tester.pump();

    expect(find.text('Catatan tidak ditemukan.'), findsOneWidget);
  });
}
