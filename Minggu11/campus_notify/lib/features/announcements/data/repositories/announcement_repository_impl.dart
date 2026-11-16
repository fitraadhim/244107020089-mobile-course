import '../../../../core/failures.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../datasources/announcement_remote_datasource.dart';

/// Repository pengumuman dengan cache in-memory (TTL).
///
/// Sebelum: setiap kali daftar dibuka, atau setiap kali detail dibuka,
/// repository memanggil data source lagi. UI sempat menampilkan spinner
/// dan seluruh isi halaman dibangun ulang although datanya sama saja.
///
/// Sesudah: data yang baru diambil disimpan dan dipakai ulang selama
/// [cacheTtl]. Daftar kedua yang dibuka pada sesi yang sama tampil
/// seketika tanpa menunggu jaringan, dan detail pengumuman diambil dari
/// cache tanpa round trip baru.
class AnnouncementRepositoryImpl implements AnnouncementRepository {
  AnnouncementRepositoryImpl(this._remote);

  final AnnouncementRemoteDataSource _remote;

  /// Umur maksimum cache sebelum data dianggap basi.
  static const cacheTtl = Duration(seconds: 30);

  List<Announcement>? _cachedList;
  DateTime? _cachedAt;
  final Map<String, Announcement> _cachedDetails = <String, Announcement>{};

  bool get _isFresh =>
      _cachedAt != null && DateTime.now().difference(_cachedAt!) < cacheTtl;

  @override
  Future<({List<Announcement> announcements, Failure? failure})>
      fetchAnnouncements({bool forceRefresh = false}) async {
    final cached = _cachedList;
    if (cached != null && !forceRefresh && _isFresh) {
      return (announcements: cached, failure: null);
    }
    return _loadList();
  }

  @override
  Future<({Announcement? announcement, Failure? failure})> fetchAnnouncement(
    String id, {
    bool forceRefresh = false,
  }) async {
    final cached = _cachedDetails[id];
    if (cached != null && !forceRefresh && _isFresh) {
      return (announcement: cached, failure: null);
    }
    try {
      final model = await _remote.fetchAnnouncement(id);
      final announcement = model.toEntity();
      _cachedDetails[id] = announcement;
      return (announcement: announcement, failure: null);
    } catch (_) {
      return (
        announcement: null,
        failure: const LocalFailure('Pengumuman tidak ditemukan.'),
      );
    }
  }

  Future<({List<Announcement> announcements, Failure? failure})>
      _loadList() async {
    try {
      final models = await _remote.fetchAnnouncements();
      final announcements = models
          .map((model) => model.toEntity())
          .toList(growable: false);
      _cachedList = announcements;
      _cachedAt = DateTime.now();
      // Detail diambil dari cache yang sama, sehingga membuka detail
      // pengumuman yang sudah ada di daftar tidak perlu jaringan lagi.
      for (final announcement in announcements) {
        _cachedDetails[announcement.id] = announcement;
      }
      return (announcements: announcements, failure: null);
    } catch (_) {
      return (
        announcements: const <Announcement>[],
        failure: const NetworkFailure(
          'Pengumuman tidak dapat dimuat. Periksa koneksi lalu coba lagi.',
        ),
      );
    }
  }
}
