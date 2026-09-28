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
