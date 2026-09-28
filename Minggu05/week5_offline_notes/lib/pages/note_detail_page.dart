import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

class NoteDetailPage extends ConsumerWidget {
  const NoteDetailPage({required this.noteId, super.key});

  final int noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final note = ref.watch(noteDetailProvider(noteId));
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Catatan')),
      body: note.when(
        data: (value) {
          if (value == null) {
            return const Center(child: Text('Catatan tidak ditemukan.'));
          }
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      _editNote(context, ref, value.title, value.body),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                ),
              ),
              Text(
                value.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              if (value.dirty)
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Chip(label: Text('Belum tersinkron')),
                ),
              Text(value.body.isEmpty ? 'Tanpa isi' : value.body),
              const SizedBox(height: 24),
              Text('Diperbarui: ${value.updatedAt.toLocal()}'),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Gagal membaca catatan: $error')),
      ),
    );
  }

  Future<void> _editNote(
    BuildContext context,
    WidgetRef ref,
    String title,
    String body,
  ) async {
    final titleController = TextEditingController(text: title);
    final bodyController = TextEditingController(text: body);
    final result = await showDialog<(String, String)>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit catatan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController),
            TextField(controller: bodyController),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, (
              titleController.text,
              bodyController.text,
            )),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    titleController.dispose();
    bodyController.dispose();
    if (result == null || result.$1.trim().isEmpty) return;
    await ref
        .read(notesProvider.notifier)
        .edit(id: noteId, title: result.$1.trim(), body: result.$2.trim());
  }
}
