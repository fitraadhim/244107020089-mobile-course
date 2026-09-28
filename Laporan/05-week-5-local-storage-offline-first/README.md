# Week 05 - Local Storage and Offline First

## Praktikum Cache-First dan Sinkronisasi Data

### Tujuan

Praktikum ini bertujuan untuk menguji penyimpanan data lokal dan mekanisme
offline-first pada aplikasi Flutter. Data posts ditampilkan dari cache lokal
terlebih dahulu, sedangkan catatan baru disimpan secara lokal dengan status
`dirty` sampai dilakukan sinkronisasi.

### Skenario Pengujian

#### 1. Kondisi awal

Pada kondisi awal, aplikasi menampilkan halaman **Offline Notes**. Belum ada
catatan lokal sehingga badge menunjukkan `0 dirty`. Data posts berhasil
ditampilkan pada bagian **Posts cache-first**.

![Kondisi awal](screenshots/1.jpeg)

#### 2. Mengaktifkan force offline

Mode `Force offline` diaktifkan melalui halaman Settings. Aplikasi menampilkan
label **OFFLINE**, tetapi data posts yang sebelumnya tersimpan di cache tetap
tersedia dan dapat dibaca tanpa koneksi jaringan. Badge catatan tetap akurat
sebesar `0 dirty`.

![Force offline aktif](screenshots/2.jpeg)

#### 3. Menambahkan catatan dirty

Sebuah catatan baru dengan judul `lalala` dan isi `rawr` ditambahkan ketika
mode offline aktif. Catatan langsung tersimpan pada database lokal dan dapat
ditampilkan kembali. Karena belum disinkronkan ke server, badge berubah menjadi
`1 dirty` dan ikon cloud menunjukkan status belum tersinkron.

![Catatan dirty](screenshots/3.jpeg)

#### 4. Sinkronisasi catatan

Mode offline dimatikan dan sinkronisasi dijalankan menggunakan tombol sync.
Setelah proses selesai, badge kembali menjadi `0 dirty`. Ikon cloud pada
catatan berubah menjadi status tersinkron, sehingga catatan tetap tersedia di
database lokal dengan status bersih.

![Setelah sinkronisasi](screenshots/4.jpeg)

### Hasil Pengamatan

| Tahap | Kondisi aplikasi | Hasil |
| --- | --- | --- |
| 1 | Online, belum ada catatan | Posts tampil dan badge `0 dirty` |
| 2 | `Force offline` aktif | Cache posts tetap dapat dibaca tanpa jaringan |
| 3 | Catatan baru dibuat offline | Catatan tersimpan lokal dan badge menjadi `1 dirty` |
| 4 | Sinkronisasi dijalankan | Badge kembali menjadi `0 dirty` dan catatan berstatus tersinkron |

### Kesimpulan

Implementasi berhasil menerapkan konsep offline-first. Data yang sudah pernah
di-cache tetap dapat ditampilkan ketika aplikasi berada dalam mode offline.
Catatan baru juga tidak hilang karena langsung disimpan ke database lokal dan
diberi penanda `dirty`. Setelah koneksi tersedia kembali, proses sinkronisasi
mengubah status catatan menjadi bersih (`0 dirty`).

## Analisis Pilihan Local Storage

Aplikasi memiliki dua jenis data yang berbeda:

- **Preferensi tema** dan `forceOffline` adalah beberapa nilai sederhana berupa
	boolean/string.
- **Catatan** adalah data berulang yang dapat berjumlah 1000 atau lebih dan
	membutuhkan pencarian, pengurutan, pagination, serta status `dirty`.

### Perbandingan Teknologi

| Teknologi | Kompleksitas query | Relasi | Reaktivitas (stream) | Type-safety | Boilerplate | Kemudahan testing | Trade-off utama |
| --- | --- | --- | --- | --- | --- | --- | --- |
| **SharedPreferences** | Sangat terbatas: key-value sederhana | Tidak cocok | Tidak ada stream database bawaan | Rendah; nilai dibaca berdasarkan tipe runtime | Paling kecil | Sangat mudah untuk di-mock | Ringan dan cepat untuk preferensi, tetapi tidak cocok untuk daftar catatan atau query 1000+ data |
| **Hive** | Baik untuk lookup dan filter sederhana, tetapi bukan SQL | Terbatas; relasi harus dikelola aplikasi | Ada listener/`ValueListenable`, tetapi tidak sefleksibel query stream | Sedang; adapter dan model perlu dijaga konsistensinya | Kecil sampai sedang | Mudah dengan box sementara/test adapter | Cepat dan sederhana, tetapi query kompleks, relasi, migrasi, dan pagination perlu lebih banyak logika manual |
| **sqflite (SQLite)** | Sangat baik; SQL, `WHERE`, `JOIN`, index, transaksi, pagination | Sangat baik | Tidak bawaan; perlu invalidasi provider atau wrapper stream | Sedang-rendah; hasil query berupa map dan raw SQL tidak dikompilasi | Sedang | Baik dengan database in-memory/mock dan fixture SQL | Matang dan fleksibel, tetapi mapping model, migrasi, dan query harus ditulis manual |
| **Drift** | Sangat baik; mendukung SQL dan query terkomposisi | Sangat baik | Sangat baik; query dapat menghasilkan stream reaktif | Tinggi; tabel, row, query, dan hasil dibuat type-safe | Sedang sampai besar karena code generation | Sangat baik; mendukung database test dan query terisolasi | Pilihan paling lengkap untuk aplikasi catatan, tetapi build runner, generated code, dan learning curve menambah setup |

### Verifikasi terhadap Rekomendasi AI

Sebelum menerima rekomendasi AI, temuan berikut diverifikasi terhadap kode
aplikasi dan hasil implementasi proyek:

| Pertanyaan verifikasi | Temuan aktual | Keputusan |
| --- | --- | --- |
| Apakah daftar catatan ditempatkan di SharedPreferences? | Tidak. `SharedPreferences` hanya menyimpan `dark_mode`, `force_offline`, dan waktu terakhir dibuka. Catatan disimpan pada tabel SQLite `notes`. Menyimpan koleksi catatan sebagai satu nilai key-value akan rapuh karena tidak mendukung query, transaksi, index, dan update per item. | Rekomendasi AI diterima untuk preferensi, tetapi ditolak untuk koleksi catatan. |
| Apakah skema mendukung antrean sync? | Ya. Tabel `notes` memiliki `dirty` dan `updated_at`. Catatan baru diberi `dirty = 1`, dihitung melalui `countDirty()`, lalu ditandai bersih setelah proses sinkronisasi selesai. | Skema sudah mendukung antrean dasar. Untuk produksi, antrean dapat diperkuat dengan `sync_status`, `retry_count`, `last_error`, dan `remote_id`. |
| Apakah klaim real-time didukung stream? | Belum pada implementasi saat ini. `sqflite` mengembalikan `Future` dan UI diperbarui melalui invalidasi provider. Klaim stream reaktif berlaku untuk Drift dengan `watch()`, bukan otomatis untuk sqflite. | Klaim real-time AI dikoreksi: aplikasi saat ini bersifat reactive-by-invalidation, bukan database stream real-time. |
| Apakah estimasi boilerplate masuk akal? | Pada proyek ini, dependensi `sqflite` sudah diuji bersama `flutter pub get`, helper database, model `toMap/fromMap`, repository, dan skema tabel. Drift belum dipasang karena belum menjadi kebutuhan implementasi; secara teknis instalasinya membutuhkan `drift`, `drift_dev`, `build_runner`, deklarasi tabel, generated code, serta migrasi skema yang tetap harus diuji. | Estimasi AI masuk akal secara relatif, tetapi Drift bukan tanpa boilerplate. `sqflite` terbukti lebih ringan untuk praktikum ini, sedangkan Drift lebih layak saat query dan stream berkembang. |

#### Bukti Implementasi

- `lib/data/prefs.dart` menyimpan preferensi sederhana melalui
	`SharedPreferences`.
- `lib/data/local/db.dart` mendefinisikan tabel `notes` dan `cached_posts`.
- `lib/data/local/note.dart` memetakan `updated_at` dan `dirty` ke model `Note`.
- `lib/data/repositories/note_repository.dart` menyediakan `countDirty()`,
	`markAllSynced()`, pembacaan cache, dan refresh data.
- Validasi proyek menunjukkan `flutter analyze` dan widget test berhasil.

### Keputusan Final Setelah Verifikasi

Keputusan akhir tetap menggunakan **SharedPreferences untuk preferensi** dan
**sqflite untuk catatan** pada proyek ini. Alasannya adalah kebutuhan
preferensi memang key-value sederhana, sedangkan catatan memerlukan tabel,
status dirty, timestamp, transaksi, dan cache yang tidak rapuh untuk 1000+
baris. Drift menjadi kandidat migrasi berikutnya jika aplikasi membutuhkan
query yang lebih kompleks dan stream `watch()` yang benar-benar reaktif.

| Kebutuhan | Rekomendasi | Alasan |
| --- | --- | --- |
| Preferensi tema, `forceOffline`, dan nilai aplikasi kecil | **SharedPreferences** | Data hanya berupa key-value sederhana, tidak membutuhkan relasi, query, stream, atau pagination. Boilerplate dan biaya testing paling kecil. |
| Catatan 1000+ item dengan pencarian, sorting, status `dirty`, dan kemungkinan relasi | **Drift** | Menyediakan SQLite, query type-safe, stream reaktif, transaksi, index, dan dukungan testing yang baik. Perubahan catatan dapat langsung mengalir ke UI tanpa invalidasi manual. |
| Catatan jika ukuran aplikasi dan setup harus minimal | **sqflite** | Tetap memakai SQLite yang kuat dan cocok untuk 1000+ catatan. Pilihan ini lebih sederhana daripada Drift, tetapi mapping, query, dan reaktivitas harus dikelola manual. |

Untuk aplikasi pada praktikum ini, `SharedPreferences` sudah tepat untuk
preferensi. Implementasi saat ini memakai `sqflite` untuk catatan karena cukup
untuk kebutuhan CRUD, cache, status `dirty`, dan sinkronisasi. Jika fitur
pencarian, filter, relasi, dan update real-time bertambah, migrasi ke **Drift**
akan menjadi pilihan yang lebih aman untuk jangka panjang.

### Skema Data untuk 1000+ Catatan

Berikut skema minimal yang dapat digunakan pada SQLite maupun Drift. Satu baris
mewakili satu catatan, sedangkan index membantu pencarian dan pengurutan tanpa
memindai seluruh tabel.

```text
+---------------------------+
| notes                     |
+---------------------------+
| id          INTEGER  PK   |
| title       TEXT NOT NULL |
| body        TEXT          |
| updated_at  TEXT NOT NULL |
| dirty       INTEGER       |
+---------------------------+
					|
					| optional, jika catatan memiliki label
					v
+---------------------------+       +---------------------------+
| note_tags                 |       | tags                      |
+---------------------------+       +---------------------------+
| note_id     INTEGER  FK   |------>| id          INTEGER  PK   |
| tag_id      INTEGER  FK   |       | name        TEXT UNIQUE   |
+---------------------------+       +---------------------------+

Index yang disarankan:
- INDEX notes_updated_at_idx ON notes(updated_at DESC)
- INDEX notes_dirty_idx ON notes(dirty)
- INDEX note_tags_note_id_idx ON note_tags(note_id)
- INDEX note_tags_tag_id_idx ON note_tags(tag_id)
```

Untuk 1000+ catatan, daftar tidak sebaiknya dimuat sekaligus. Gunakan
pagination, misalnya `LIMIT 50 OFFSET n` atau cursor berdasarkan `updated_at`
dan `id`. Query umum yang diperlukan adalah:

```sql
SELECT id, title, body, updated_at, dirty
FROM notes
ORDER BY updated_at DESC, id DESC
LIMIT 50;
```

Catatan baru atau catatan yang diedit diberi `dirty = 1`. Proses sinkronisasi
memproses baris dirty dalam transaksi, lalu mengubahnya menjadi `dirty = 0`
setelah server mengonfirmasi keberhasilan. Dengan aturan ini, kegagalan
jaringan tidak menghapus data lokal dan catatan dapat dicoba sinkronisasi
kembali.

# Offline Notes

Aplikasi Flutter untuk mempraktikkan local storage, cache-first, dan
sinkronisasi catatan secara offline-first.

## Tujuan Project

Project ini menunjukkan cara menyimpan preferensi aplikasi secara persisten,
mengelola CRUD catatan dengan SQLite, menampilkan data bacaan dari cache lokal,
dan menandai tulisan lokal yang belum tersinkron melalui dirty flag.

## Fitur Utama

- Toggle tema terang/gelap yang disimpan dengan `SharedPreferences`.
- Timestamp `last_opened_at` yang diperbarui setiap aplikasi dibuka.
- CRUD catatan persisten menggunakan `sqflite` dan Riverpod.
- Daftar catatan diurutkan berdasarkan `updated_at` terbaru.
- Cache-first posts dari JSONPlaceholder dengan fallback ke cache lokal.
- Mode deterministik `Force offline` untuk pengujian tanpa jaringan.
- Dirty badge pada catatan baru atau catatan yang diedit.
- Simulasi `syncNotes` dengan aturan konflik `localUpdatedAtWins`.
- Detail catatan melalui GoRouter pada `/note/:id` yang membaca ulang
  repository lokal.
- Unit test model dan provider menggunakan `FakeNoteRepository`.

## Stack Teknologi

- Flutter dan Dart
- Riverpod untuk state management
- SharedPreferences untuk preferensi kecil
- SQLite melalui `sqflite` untuk catatan dan cache posts
- GoRouter untuk navigasi
- HTTP client untuk endpoint JSONPlaceholder
- Flutter test untuk unit dan widget testing

## Struktur Project

```text
lib/
├── main.dart
├── providers.dart
├── data/
│   ├── local/
│   │   ├── db.dart
│   │   └── note.dart
│   ├── remote/
│   │   └── posts_api.dart
│   ├── prefs.dart
│   ├── repositories/
│   │   └── note_repository.dart
│   └── sync.dart
├── pages/
│   ├── note_detail_page.dart
│   ├── notes_page.dart
│   └── settings_page.dart
└── widgets/
    └── note_tile.dart

test/
├── note_test.dart
└── widget_test.dart

docs/
├── ai-prompt.md
├── refactoring-testing.md
├── reflection.md
└── storage-comparison.md

screenshots/
└── README.md
```

## Cara Menjalankan

Pastikan Flutter SDK sudah terpasang, lalu jalankan dari folder project:

```powershell
flutter pub get
flutter run
```

Untuk menjalankan pada perangkat Android:

1. Aktifkan Developer Options dan USB debugging pada perangkat.
2. Hubungkan perangkat ke komputer dan terima dialog debugging.
3. Periksa perangkat dengan `flutter devices`.
4. Jalankan `flutter run -d <device-id>`.

## Skenario Pengujian Offline

1. Buka aplikasi dan masuk ke Settings.
2. Aktifkan `Force offline`.
3. Buat catatan baru. Catatan tetap tampil dan badge berubah menjadi `1 dirty`.
4. Matikan `Force offline`.
5. Tekan tombol sync dan tunggu simulasi selesai.
6. Badge kembali menjadi `0 dirty` dan ikon berubah menjadi tersinkron.
7. Simpan screenshot setiap tahap pada folder `screenshots/`.

## Aturan Konflik

Sinkronisasi menggunakan aturan **local updated-at wins**: perubahan lokal
terbaru berdasarkan `updated_at` dipertahankan ketika ada konflik. Pada demo,
server disimulasikan dengan delay sehingga dirty rows ditandai bersih setelah
proses berhasil. Implementasi produksi perlu menambahkan `remote_id`, versi
server, retry count, dan status error agar konflik serta kegagalan dapat
dilacak lebih lengkap.

## Verifikasi

```powershell
flutter analyze
flutter test
```

Hasil verifikasi terakhir: analyzer lulus tanpa issue dan seluruh test proyek
lulus.

Dokumentasi teknis, prompt AI, tabel perbandingan storage, dan jawaban refleksi
tersedia di folder [`docs/`](docs/).

# Refleksi Week 05

## 1. Mengapa daftar catatan tidak boleh disimpan di SharedPreferences?

SharedPreferences adalah penyimpanan key-value untuk data kecil seperti
boolean, string, dan angka. Daftar catatan harus diubah menjadi satu blob
JSON/string jika disimpan di sana. Akibatnya, setiap perubahan memerlukan
baca-ubah-tulis seluruh koleksi, pencarian tidak memakai index, transaksi sulit
dijamin, relasi tidak tersedia, dan risiko kehilangan perubahan meningkat saat
dua operasi terjadi berdekatan. Ukuran data juga tidak terkontrol untuk 1000+
catatan. Karena itu catatan disimpan sebagai baris SQLite.

## 2. Kapan cache-first cukup dan kapan membutuhkan network-first?

Cache-first cukup untuk data bacaan yang boleh sedikit stale, misalnya daftar
posts atau konten offline. UI dapat tampil cepat dari cache lalu melakukan
refresh jaringan di background. Network-first lebih tepat untuk data yang harus
paling baru atau sangat sensitif terhadap perubahan, seperti saldo, status
pembayaran, inventaris, dan izin akses. Pola hybrid juga dapat dipakai: tampilkan
cache segera, tetapi blokir aksi penting sampai validasi jaringan berhasil.

## 3. Bagaimana dirty flag menjadi antrean sync tanpa memblokir UI?

Saat catatan dibuat atau diedit, repository langsung menulisnya ke SQLite dengan
`dirty = 1` dan `updated_at` terbaru. UI membaca hasil lokal sehingga tidak
menunggu jaringan. `syncNotes` berjalan sebagai Future/asynchronous task; ia
mengambil dirty rows, mengirim atau mensimulasikan pengiriman, lalu dalam
transaksi mengubah rows yang berhasil menjadi `dirty = 0`. Provider di-invalidate
setelah selesai agar badge diperbarui.

Satu dirty flag cukup untuk demo sederhana. Tabel `outbox` diperlukan ketika
setiap operasi harus dipertahankan sebagai event terpisah, misalnya create,
update, delete, retry dengan backoff, idempotency key, urutan operasi, error
per item, atau sinkronisasi parsial. Struktur outbox biasanya memuat
`operation`, `entity_id`, `payload`, `attempts`, `next_retry_at`, dan `last_error`.

## 4. Bagian rekomendasi AI yang ditolak

Rekomendasi menyimpan koleksi catatan pada SharedPreferences ditolak karena
key-value tidak menyediakan query, relasi, index, transaksi, atau update per
baris. Klaim bahwa sqflite otomatis real-time juga ditolak: sqflite memberi
Future dan hasil query, bukan stream perubahan. Project ini memakai invalidasi
Riverpod secara eksplisit. Drift memang menyediakan `watch()` dan type-safety
yang lebih baik, tetapi belum dipilih karena kebutuhan project masih dapat
ditangani sqflite dan Drift menambah code generation serta boilerplate setup.
