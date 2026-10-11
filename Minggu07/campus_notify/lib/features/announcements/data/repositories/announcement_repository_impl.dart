import '../../../../core/failures.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../datasources/announcement_remote_datasource.dart';

class AnnouncementRepositoryImpl implements AnnouncementRepository {
  const AnnouncementRepositoryImpl(this._remote);

  final AnnouncementRemoteDataSource _remote;

  @override
  Future<({List<Announcement> announcements, Failure? failure})>
      fetchAnnouncements() async {
    try {
      final models = await _remote.fetchAnnouncements();
      return (
        announcements: models.map((model) => model.toEntity()).toList(),
        failure: null,
      );
    } catch (_) {
      return (
        announcements: const <Announcement>[],
        failure: const NetworkFailure(
          'Pengumuman tidak dapat dimuat. Periksa koneksi lalu coba lagi.',
        ),
      );
    }
  }

  @override
  Future<({Announcement? announcement, Failure? failure})> fetchAnnouncement(
    String id,
  ) async {
    try {
      final model = await _remote.fetchAnnouncement(id);
      return (announcement: model.toEntity(), failure: null);
    } catch (_) {
      return (
        announcement: null,
        failure: const LocalFailure('Pengumuman tidak ditemukan.'),
      );
    }
  }
}