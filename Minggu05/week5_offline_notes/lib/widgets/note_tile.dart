import 'package:flutter/material.dart';

import '../data/local/note.dart';

class NoteTile extends StatelessWidget {
  const NoteTile({
    required this.note,
    required this.onTap,
    required this.onDelete,
    super.key,
  });

  final Note note;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(note.title),
        subtitle: Text(
          note.body.isEmpty ? 'Tanpa isi' : note.body,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (note.dirty)
              const Chip(
                label: Text('Belum tersinkron'),
                avatar: Icon(Icons.cloud_upload_outlined, size: 16),
              )
            else
              const Icon(Icons.cloud_done_outlined),
            IconButton(
              tooltip: 'Hapus catatan',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }
}
