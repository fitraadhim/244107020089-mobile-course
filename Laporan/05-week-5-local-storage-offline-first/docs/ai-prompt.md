# Prompt AI dan Batasan Implementasi

## Prompt yang digunakan

> Bangun aplikasi Flutter Offline Notes dengan SharedPreferences untuk
> preferensi tema dan timestamp startup, SQLite/sqflite untuk CRUD catatan,
> Riverpod untuk state management, cache-first untuk data bacaan, dirty flag
> untuk tulisan offline, dan simulasi sinkronisasi. Pisahkan widget catatan,
> service sync, halaman detail GoRouter, unit test fake repository, serta
> dokumentasi trade-off storage.

## Batasan yang dipertahankan

- SharedPreferences tidak digunakan untuk menyimpan daftar catatan.
- Catatan disimpan sebagai baris SQLite agar dapat di-query, diurutkan, dan
  diperbarui per item.
- Cache boleh ditampilkan saat jaringan gagal.
- Dirty note tidak ditandai bersih sebelum proses sync berhasil.
- Mode `Force offline` harus deterministik untuk demo dan test.
- Konflik demo memakai aturan `localUpdatedAtWins`.

## Pemeriksaan terhadap hasil AI

Hasil implementasi diperiksa dengan membaca alur provider, repository, dan
service sync, kemudian diverifikasi memakai `flutter analyze` dan `flutter test`.
Klaim stream real-time tidak dianggap terpenuhi oleh `sqflite`; implementasi
saat ini memakai invalidasi provider. Stream `watch()` baru menjadi alasan
migrasi jika project beralih ke Drift.
