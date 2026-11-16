import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/failures.dart';
import '../../../../routes.dart';
import '../../domain/entities/announcement.dart';
import '../providers/announcements_provider.dart';

class AnnouncementsPage extends ConsumerWidget {
  const AnnouncementsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const _AnnouncementsTitle()),
      // Isi daftar dipisah menjadi widget sendiri supaya perubahan state
      // provider hanya membangun ulang isi list, bukan Scaffold + AppBar +
      // RefreshIndicator sekaligus.
      body: const _AnnouncementsBody(),
    );
  }
}

/// Judul app bar hanya butuh jumlah pengumuman. `select` membuat widget ini
/// dibangun ulang hanya bila jumlahnya berubah, bukan setiap kali data
/// pengumuman berubah.
class _AnnouncementsTitle extends ConsumerWidget {
  const _AnnouncementsTitle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(
      announcementsProvider.select((state) => state.value?.length ?? 0),
    );
    return Text(
      count == 0 ? 'Daftar Pengumuman' : 'Daftar Pengumuman ($count)',
    );
  }
}

class _AnnouncementsBody extends ConsumerWidget {
  const _AnnouncementsBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(announcementsProvider);

    return state.when(
      // Saat daftar di-refresh, isi lama tetap tampil (tidak ada kedipan
      // spinner layar penuh); data baru menggantikan begitu tiba.
      skipLoadingOnReload: true,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(failureMessage(error))),
      data: (announcements) => RefreshIndicator(
        onRefresh: () async {
          // Pull-to-refresh selalu mengambil data terbaru dari jaringan,
          // lalu provider di-invalidate supaya UI memakai data baru.
          await ref.read(getAnnouncementsProvider).call(forceRefresh: true);
          ref.invalidate(announcementsProvider);
        },
        child: ListView.builder(
          itemCount: announcements.length,
          // Item stateless, jadi tidak perlu kept alive saat keluar layar.
          addAutomaticKeepAlives: false,
          itemBuilder: (context, index) {
            final announcement = announcements[index];
            return AnnouncementTile(
              key: ValueKey(announcement.id),
              announcement: announcement,
            );
          },
        ),
      ),
    );
  }
}

/// Satu baris daftar dipisah ke widget immutable: saat daftar dibangun ulang
/// (mis. setelah pull-to-refresh) element yang sama dipakai ulang lewat
/// ValueKey, sehingga tidak semua baris dibangun dari nol.
class AnnouncementTile extends StatelessWidget {
  const AnnouncementTile({required this.announcement, super.key});

  final Announcement announcement;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(announcement.title),
      subtitle: Text(announcement.body),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push(
        AppRoutes.announcementById(announcement.id),
      ),
    );
  }
}
