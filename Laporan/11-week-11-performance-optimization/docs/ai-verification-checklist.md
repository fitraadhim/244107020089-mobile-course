# AI Verification Checklist — Optimasi Performa Minggu 11

Saran AI tidak langsung diterapkan. Setiap usulan diverifikasi terhadap kode
aplikasi, hasil `flutter analyze`/`flutter test`, dan hasil pengukuran di
Flutter DevTools. Yang tidak bisa dibuktikan ditandai **ditolak** beserta
alasannya.

## Usulan yang Diterima

- [x] **Router harus dibuat satu kali, bukan tiap perubahan status auth.**
      Bukti: `lib/app/router.dart` (sebelum) memanggil `ref.watch(authStateProvider)`
      di dalam `Provider<GoRouter>`, sehingga setiap perubahan status auth
      menghasilkan instance `GoRouter` baru. Perbaikan: satu instance dengan
      `refreshListenable` (`ValueNotifier<bool>`) + `ref.listen`.
- [x] **Repository perlu cache agar navigasi tidak memanggil jaringan lagi.**
      Bukti: `AnnouncementRepositoryImpl` (sebelum) selalu memanggil
      `AnnouncementRemoteDataSource`; tidak ada penyimpanan hasil fetch.
      Perbaikan: cache in-memory TTL 30 detik untuk daftar dan detail, dengan
      `forceRefresh` untuk pull-to-refresh. Test baru
      `test/announcement_repository_cache_test.dart` mengunci perilaku ini.
- [x] **Scope rebuild halaman daftar terlalu luas.**
      Bukti: `AnnouncementsPage` (sebelum) melakukan `ref.watch` pada provider
      yang sama dengan `Scaffold`/`AppBar`, sehingga perubahan data membangun
      ulang seluruh halaman. Perbaikan: isi list dipisah ke widget sendiri dan
      jumlah pengumuman diambil dengan `select()`.
- [x] **Item list perlu widget immutable + `ValueKey`.**
      Bukti: `itemBuilder` (sebelum) membangun `ListTile` di dalam closure
      tanpa key, sehingga element tidak dijamin dipakai ulang setelah daftar
      berubah. Perbaikan: `AnnouncementTile` dengan `ValueKey(id)` dan
      `addAutomaticKeepAlives: false`.
- [x] **`shrinkWrap: true` pada `NotesList` harus dihapus.**
      Bukti: `lib/features/notes/presentation/pages/notes_page.dart` (sebelum)
      memakai `shrinkWrap: true` sehingga `ListView` menghitung tinggi seluruh
      isi daftar; `ListView.builder` sudah lazy secara bawaan.
- [x] **File mati harus dihapus.**
      Bukti: `lib/core/providers.dart` (kosong) dan
      `lib/pages/announcement_page.dart` (stub yang digantikan
      `announcement_detail_page.dart`) tidak di-import oleh file mana pun di
      `lib/` maupun `test/` (dicek dengan pencarian import).

## Usulan yang Ditolak

- [x] **Menambah `RepaintBoundary` pada setiap item list ditolak.**
      `ListView.builder` sudah memakai `addRepaintBoundaries: true` secara
      bawaan, sehingga setiap item sudah berada di dalam layer sendiri.
      Menambah boundary kedua hanya menambah layer tanpa mengurangi pekerjaan.
      `RepaintBoundary` tetap dipakai di satu tempat yang memang butuh:
      kartu token FCM di `lib/pages/home_page.dart`, agar perubahan token hanya
      merepaint kartu itu.
- [x] **Menambah pagination dan `CachedNetworkImage` ditolak (YAGNI).**
      Data pada minggu ini berasal dari data source lokal (seed 200 item untuk
      pengukuran) dan `ListView.builder` sudah membangun item secara lazy.
      Pagination tidak mengubah pekerjaan yang terukur dan menambah
      kompleksitas state.
- [x] **Mengaktifkan "Count widget builds" di tab Rebuild Stats ditolak
      sebagai sumber bukti.** Opsi itu hanya berfungsi pada mode debug; aplikasi
      diukur pada mode profile sehingga DevTools menampilkan
      "Count widget builds must be enabled to see data". Bukti yang dipakai
      menggantinya: fase UI (Build/Layout/Paint) dan fase Raster per frame dari
      tab **Frame Analysis**, plus metrik timeline dari Dart VM Service.
- [x] **Mengaktifkan CPU profiler untuk flame chart ditolak.**
      VM service-proxy dari `flutter run` menjawab `getCpuSamples` dengan
      "Profiler is disabled", dan mencoba menyalakan profiler lewat
      `--es dart-flags --profiler` membuat aplikasi crash saat start
      (`FlutterJNI.init`). Karena itu tab CPU Profiler tidak bisa dipakai dan
      analisis frame dilakukan lewat Frame Analysis.

## Hasil Pemeriksaan

```text
flutter analyze
No issues found!

flutter test
00:02 +15: All tests passed!
```

Pemeriksaan dijalankan dari `Minggu11/campus_notify` (15 test: 13 test lama
+ 2 test cache repository).
