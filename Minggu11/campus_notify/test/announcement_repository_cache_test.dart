import 'package:campus_notify/features/announcements/data/datasources/announcement_remote_datasource.dart';
import 'package:campus_notify/features/announcements/data/models/announcement_model.dart';
import 'package:campus_notify/features/announcements/data/repositories/announcement_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

/// Data source yang menghitung berapa kali jaringan dipanggil.
class _CountingDataSource extends AnnouncementRemoteDataSource {
  int listCalls = 0;

  @override
  Future<List<AnnouncementModel>> fetchAnnouncements() async {
    listCalls++;
    return super.fetchAnnouncements();
  }
}

void main() {
  test('panggilan kedua memakai cache, forceRefresh mengambil data baru', () async {
    final remote = _CountingDataSource();
    final repository = AnnouncementRepositoryImpl(remote);

    final first = await repository.fetchAnnouncements();
    final second = await repository.fetchAnnouncements();

    expect(first.announcements, isNotEmpty);
    expect(second.announcements.length, first.announcements.length);
    expect(remote.listCalls, 1, reason: 'panggilan kedua harus dilayani cache');

    await repository.fetchAnnouncements(forceRefresh: true);
    expect(remote.listCalls, 2, reason: 'forceRefresh harus melewati cache');
  });

  test('detail pengumuman dilayani dari cache daftar', () async {
    final remote = _CountingDataSource();
    final repository = AnnouncementRepositoryImpl(remote);

    await repository.fetchAnnouncements();
    final detail = await repository.fetchAnnouncement('7');

    expect(detail.failure, isNull);
    expect(detail.announcement?.id, '7');
  });
}
