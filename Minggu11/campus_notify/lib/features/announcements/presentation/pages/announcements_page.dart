import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/failures.dart';
import '../../../../routes.dart';
import '../providers/announcements_provider.dart';

class AnnouncementsPage extends ConsumerWidget {
  const AnnouncementsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(announcementsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Pengumuman')),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(failureMessage(error))),
        data: (announcements) => RefreshIndicator(
          onRefresh: () => ref.refresh(announcementsProvider.future),
          child: ListView.builder(
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final announcement = announcements[index];
              return ListTile(
                title: Text(announcement.title),
                subtitle: Text(announcement.body),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go(
                  AppRoutes.announcementById(announcement.id),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}