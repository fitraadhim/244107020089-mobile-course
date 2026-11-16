import '../models/announcement_model.dart';

/// Sumber data pengumuman.
///
/// Data awal hanya 2 item, sehingga metrik scroll/list tidak terukur.
/// Seed data 200 item ditambahkan agar profil baseline dan sesudah
/// optimasi memakai data yang identik (perbandingan tetap sahih).
///
/// Latensi 250 ms (daftar) dan 180 ms (detail) mensimulasikan round trip
/// jaringan. Tanpa latensi, biaya fetch tidak terlihat di frame chart dan
/// cache repository tidak bisa dibuktikan bekerja.
class AnnouncementRemoteDataSource {
  Future<List<AnnouncementModel>> fetchAnnouncements() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _items;
  }

  Future<AnnouncementModel> fetchAnnouncement(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
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
    for (var i = 3; i <= 200; i++)
      AnnouncementModel(
        id: '$i',
        title: 'Pengumuman Kampus Nomor $i',
        body:
            'Informasi pengumuman kampus nomor $i. Detail pengumuman dapat '
            'diakses melalui portal akademik. Pengumuman ini dibuat untuk '
            'menjadi data uji pada pengukuran performa list dan scroll.',
        publishedAt: DateTime(2026, 10, 8).subtract(Duration(hours: i)),
      ),
  ];
}
