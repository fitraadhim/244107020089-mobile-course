import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/failures.dart';
import '../../../../core/format.dart';
import '../providers/announcements_provider.dart';

class AnnouncementDetailPage extends ConsumerWidget {
  const AnnouncementDetailPage({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(announcementDetailProvider(id));

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pengumuman')),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(failureMessage(error))),
        data: (announcement) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                announcement.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(announcement.body),
              const SizedBox(height: 12),
              Text('Diterbitkan: ${formatDateTime(announcement.publishedAt)}'),
            ],
          ),
        ),
      ),
    );
  }
}