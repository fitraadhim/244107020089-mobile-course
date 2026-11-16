import '../../../../core/failures.dart';
import '../entities/announcement.dart';

abstract interface class AnnouncementRepository {
  /// Ambil daftar pengumuman.
  ///
  /// [forceRefresh] = true melewati cache dan meminta data terbaru ke
  /// jaringan (dipakai oleh pull-to-refresh).
  Future<({List<Announcement> announcements, Failure? failure})>
      fetchAnnouncements({bool forceRefresh = false});

  /// Ambil detail satu pengumuman.
  ///
  /// Implementasi boleh memakai data yang sudah pernah diambil sehingga
  /// navigasi detail tidak menunggu round trip jaringan.
  Future<({Announcement? announcement, Failure? failure})> fetchAnnouncement(
    String id, {
    bool forceRefresh = false,
  });
}
