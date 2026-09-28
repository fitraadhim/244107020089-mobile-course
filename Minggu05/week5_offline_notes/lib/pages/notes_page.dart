import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/note.dart';
import '../providers.dart';
import '../widgets/note_tile.dart';

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider);
    final posts = ref.watch(postsProvider);
    final offline = ref.watch(forceOfflineProvider).value ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Notes'),
        actions: [
          if (offline)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Center(child: Text('OFFLINE')),
            ),
          IconButton(
            tooltip: 'Sinkronisasi',
            onPressed: () => _sync(context, ref),
            icon: const Icon(Icons.sync),
          ),
          IconButton(
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(postsProvider.notifier).refresh(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionTitle(
              title: 'Catatan lokal',
              action: notes.when(
                data: (items) => Text(
                  '${items.where((note) => note.dirty).length} dirty',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
            ),
            notes.when(
              data: (items) => items.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text('Belum ada catatan.'),
                    )
                  : Column(
                      children: items
                          .where((note) => note.id != null)
                          .map(
                            (note) => NoteTile(
                              note: note,
                              onTap: () => context.push('/note/${note.id}'),
                              onDelete: () => ref
                                  .read(notesProvider.notifier)
                                  .delete(note.id!),
                            ),
                          )
                          .toList(),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text('Gagal membaca catatan: $error'),
            ),
            const SizedBox(height: 24),
            _SectionTitle(
              title: 'Posts cache-first',
              action: offline
                  ? const Icon(Icons.wifi_off, size: 18)
                  : IconButton(
                      tooltip: 'Refresh posts',
                      onPressed: () =>
                          ref.read(postsProvider.notifier).refresh(),
                      icon: const Icon(Icons.refresh),
                    ),
            ),
            posts.when(
              data: (items) => items.isEmpty
                  ? const Text(
                      'Cache kosong. Refresh untuk mengambil data jaringan.',
                    )
                  : Column(children: items.take(10).map(_postTile).toList()),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text('Gagal membaca posts: $error'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddNote(context, ref),
        tooltip: 'Tambah catatan',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _postTile(Post post) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text('${post.id}. ${post.title}'),
      subtitle: Text(post.body, maxLines: 2, overflow: TextOverflow.ellipsis),
    );
  }

  Future<void> _sync(BuildContext context, WidgetRef ref) async {
    final count = await ref.read(notesProvider.notifier).sync();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          count == 0 ? 'Tidak ada catatan dirty' : '$count catatan tersinkron',
        ),
      ),
    );
  }

  Future<void> _showAddNote(BuildContext context, WidgetRef ref) async {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    final result = await showDialog<(String, String)>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Catatan baru'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Judul'),
            ),
            TextField(
              controller: bodyController,
              decoration: const InputDecoration(labelText: 'Isi'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, (
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
        .add(result.$1.trim(), result.$2.trim());
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.action});

  final String title;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        action,
      ],
    );
  }
}
