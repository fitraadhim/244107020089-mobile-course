import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/announcement_remote_datasource.dart';
import '../../data/repositories/announcement_repository_impl.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../../domain/usecases/get_announcement_detail.dart';
import '../../domain/usecases/get_announcements.dart';

final announcementRemoteDataSourceProvider =
    Provider<AnnouncementRemoteDataSource>((ref) {
  return AnnouncementRemoteDataSource();
});

final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) {
  return AnnouncementRepositoryImpl(
    ref.watch(announcementRemoteDataSourceProvider),
  );
});

final getAnnouncementsProvider = Provider<GetAnnouncements>((ref) {
  return GetAnnouncements(ref.watch(announcementRepositoryProvider));
});

final getAnnouncementDetailProvider = Provider<GetAnnouncementDetail>((ref) {
  return GetAnnouncementDetail(ref.watch(announcementRepositoryProvider));
});

final announcementsProvider = FutureProvider<List<Announcement>>((ref) {
  return ref.watch(getAnnouncementsProvider).call().then((result) {
    if (result.failure != null) throw result.failure!;
    return result.announcements;
  });
});

final announcementDetailProvider =
    FutureProvider.family<Announcement, String>((ref, id) {
  return ref.watch(getAnnouncementDetailProvider).call(id).then((result) {
    if (result.failure != null) throw result.failure!;
    return result.announcement!;
  });
});