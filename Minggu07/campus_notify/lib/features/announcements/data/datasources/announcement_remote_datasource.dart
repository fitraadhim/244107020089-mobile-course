import '../models/announcement_model.dart';

class AnnouncementRemoteDataSource {
  Future<List<AnnouncementModel>> fetchAnnouncements() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _items;
  }

  Future<AnnouncementModel> fetchAnnouncement(String id) async {
    final item = _items.cast<AnnouncementModel?>().firstWhere(
          (announcement) => announcement?.id == id,
          orElse: () => null,
        );
    if (item == null) throw Exception('Pengumuman tidak ditemukan');
    return item;
  }

  static final _items = <AnnouncementModel>[
    AnnouncementModel(
      id: '1',
      title: 'Jadwal Ujian Tengah Semester',
      body: 'Jadwal UTS dapat dilihat melalui portal akademik kampus.',
      publishedAt: DateTime(2026, 10, 8),
    ),
    AnnouncementModel(
      id: '2',
      title: 'Pemeliharaan Sistem Akademik',
      body: 'Sistem akademik tidak tersedia pada Sabtu pukul 22.00-24.00.',
      publishedAt: DateTime(2026, 10, 6),
    ),
  ];
}