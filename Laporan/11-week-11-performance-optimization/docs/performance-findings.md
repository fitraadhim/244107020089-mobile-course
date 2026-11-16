# Temuan Optimasi Performa â€” Minggu 11

Proyek: `Minggu11/campus_notify` (aplikasi campus notify).
Target: `emulator-5554` (Android 14 / API 34, x86_64, 1080x2400, 420 dpi, 4 GB RAM,
rendering Impeller dengan GPU host).

## 1. Cara Pengukuran

| Komponen | Tool | Keterangan |
|---|---|---|
| Frame chart, jank, frame analysis | Flutter DevTools 3.47 (`Performance` tab), diakses via Chrome DevTools Protocol | DevTools dijalankan di Chrome desktop dan dihubungkan ke Dart VM Service aplikasi |
| Memori heap | Dart VM Service `getMemoryUsage` | diambil setelah skenario selesai |
| Timeline engine | Dart VM Service `getVMTimeline` | event `PipelineItem`, `PlatformVsync`, `MultipleCallsToSecondaryVsyncInFrameInterval` |
| Interaksi aplikasi | `adb` (tap, swipe, back) | koordinat dan jeda tetap (lihat skenario) |

Build yang diukur: `flutter run --profile` (mode profile, Impeller). APK yang sama
dipakai untuk pengukuran "sebelum" dan "sesudah", hanya kode sumbernya yang
berbeda.

### Skenario (identik untuk sebelum dan sesudah)

Semua jeda dalam milidetik;.app selalu berada di depan (foreground) selama
pengerjaan skenario.

| # | Langkah | Jeda |
|---|---|---|
| 1 | Dari home, tekan "Buka Daftar Pengumuman" (daftar 200 pengumuman) | 2500 ms |
| 2 | Scroll atas-bawah 5x (tiap siklus 2 swipe) | 400 ms antar gesture |
| 3 | Pull-to-refresh | 3000 ms |
| 4 | Buka detail pengumuman lalu kembali, 5x | 2200 ms per perpindahan |
| 5 | Kembali ke home, buka daftar pengumuman lagi | 1200 ms |
| 6 | Scroll 2x | 400 ms |

Langkah 5 adalah pembeda utama: pada versi sebelum, daftar kedua dimuat ulang
dengan state `loading` penuh; pada versi sesudah, repository melayani dari
cache.

## 2. Temuan

### T1 â€” Router dibangun ulang setiap perubahan status auth

`lib/app/router.dart` (sebelum):

```dart
final routerProvider = Provider<GoRouter>((ref) {
  final authAsync = ref.watch(authStateProvider);   // <- dependensi
  ...
  return GoRouter(...);                             // <- instance baru
});
```

`ref.watch` di dalam provider membuat `GoRouter` baru setiap kali
`authStateProvider` berubah. Instance baru berarti `Navigator` dan seluruh stack
halaman dibangun ulang dari nol, sehingga state navigasi hilang dan semua
widget yang sedang tampil dibangun ulang. Perubahan auth terjadi pada login,
logout, dan refresh token.

### T2 â€” Tidak ada cache di repository

`AnnouncementRepositoryImpl` selalu memanggil data source setiap kali
`fetchAnnouncements()` / `fetchAnnouncement()` dipanggil. Pada alur
"buka daftar -> buka detail -> kembali -> buka detail lagi", setiap perpindahan
halaman memicu panggilan jaringan lagi, dan provider menampilkan state
`loading` walaupun datanya sudah pernah diambil pada sesi yang sama.

Catatan pengukuran: pada skenario, latensi detail yang disimulasikan (180 ms)
tertutup oleh animasi transisi route (300 ms), sehingga efek cache tidak
tampak sebagai frame lambat di chart. Bukti cache ada di unit test, bukan di
metrik frame.

### T3 â€” Halaman daftar dibangun utuh saat state berubah

`AnnouncementsPage` melakukan `ref.watch(announcementsProvider)` di method
`build` milik `ConsumerWidget` yang sama dengan `Scaffold`/`AppBar`. Setiap
perubahan state provider (loading -> data, atau hasil pull-to-refresh)
membangun ulang `Scaffold`, `AppBar`, `RefreshIndicator`, dan `ListView`
sekaligus. Judul app bar juga ikut dibangun ulang walaupun isinya hanya
jumlah pengumuman.

### T4 â€” Item list dibuat sebagai closure, tanpa key

`itemBuilder` membuat `ListTile` baru di dalam closure setiap kali daftar
dibangun ulang. Tidak ada `ValueKey`, sehingga Flutter tidak bisa memastikan
element yang sama dipakai ulang ketika daftar berubah (mis. setelah
pull-to-refresh). `ListView.builder` juga memakai `addAutomaticKeepAlives`
default `true`, padahal item di sini stateless sehingga state kept-alive hanya
membuang memori.

### T5 â€” `NotesList` memakai `shrinkWrap: true`

`shrinkWrap: true` memaksa `ListView` menghitung tinggi seluruh isi daftar,
sehingga semua item dibangun dan di-layout walaupun tidak terlihat di layar.
`ListView.builder` sudah lazy secara bawaan. Selain itu item catatan tidak
punya `ValueKey`.

### T6 â€” File mati di `lib/`

- `lib/core/providers.dart` â€” file kosong, tidak di-import siapa pun.
- `lib/pages/announcement_page.dart` â€” stub yang digantikan
  `features/announcements/presentation/pages/announcement_detail_page.dart`.

### T7 â€” Batas lingkungan pengukuran

DevTools "Performance" hanya menyediakan data *widget build* pada mode debug.
Aplikasi diukur pada mode profile, sehingga tab **Rebuild Stats** menampilkan
"Count widget builds must be enabled to see data" dan rincian per-widget tidak
tersedia. Yang tetap terbaca pada mode profile adalah:

- grafik frame (UI vs raster vs jank) dan FPS rata-rata,
- Frame Analysis: fase UI (Build/Layout/Paint) dan fase Raster per frame,
- angka jank ("UI Jank Detected" / "Raster Jank Detected").

Bottleneck yang terukur pada emulator ini adalah **thread raster**, bukan
UI thread: pada frame yang sama, `Build` 0.2 ms / `Layout` 0.4 ms / `Paint`
0.7 ms tetapi `Raster` 18.8 ms (sebelum) sampai 34.3 ms (sesudah). Semua
target 60 FPS. Artinya perbaikan rebuild (T3, T4) sangat berpengaruh pada fase
UI, sedangkan bagian yang masih didominasi GPU emulator.

## 3. Ringkasan Temuan -> Tindakan

| Temuan | Tindakan | Jenis |
|---|---|---|
| T1 | Router tunggal + `refreshListenable` | Rebuild |
| T2 | Cache repository TTL + `forceRefresh` | I/O |
| T3 | Pisahkan isi list ke widget sendiri, `select()` untuk judul | Rebuild |
| T4 | Widget item immutable, `ValueKey`, `addAutomaticKeepAlives: false` | Rebuild |
| T5 | Hapus `shrinkWrap`, tambah `ValueKey` | Layout |
| T6 | Hapus file mati | Perawatan |
