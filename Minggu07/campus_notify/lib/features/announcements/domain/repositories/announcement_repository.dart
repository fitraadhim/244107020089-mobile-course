import '../entities/announcement.dart';
import '../../../../core/failures.dart';

abstract interface class AnnouncementRepository {
  Future<({List<Announcement> announcements, Failure? failure})>
      fetchAnnouncements();

  Future<({Announcement? announcement, Failure? failure})> fetchAnnouncement(
    String id,
  );
}