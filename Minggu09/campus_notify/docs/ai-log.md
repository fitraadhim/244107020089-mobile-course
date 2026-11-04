# AI Development Log - Search Judul Notes

Tanggal: 4 November 2026  
Fitur: pencarian judul notes dengan empty state

## Konteks proyek

- Flutter dengan Dart SDK `^3.13.0`.
- Feature-first Clean Architecture: `presentation -> domain <- data`.
- Riverpod untuk dependency wiring/state, SQLite untuk penyimpanan lokal.
- Kontrak repository berada di `lib/features/notes/domain/repositories/note_repository.dart`.
- Entity dan use case domain tidak boleh mengimpor Flutter, Dio, SQLite, Firebase, atau secure storage.
- File yang tidak boleh diubah untuk fitur ini: kontrak repository dan datasource SQLite; fitur hanya memfilter daftar yang sudah diambil.

## Prompt mentah

```text
Peran: senior Flutter developer.
Konteks: project campus_notify memakai feature-first Clean Architecture,
Riverpod, dan SQLite. Domain tidak boleh bergantung pada Flutter atau
infrastruktur. NotesPage saat ini menampilkan daftar Note dari notesProvider.
Tugas: tambahkan satu fitur kecil untuk mencari berdasarkan judul note,
abaikan huruf besar/kecil, dukung query kosong, dan tampilkan empty state
ketika tidak ada hasil.
Batas: jangan ubah kontrak repository, datasource, atau arsitektur; pindahkan
aturan filter ke use case domain murni dan jaga fungsi tetap kecil.
Output: kode implementasi, minimal satu test sukses dan satu test gagal
untuk search, serta cara menjalankan analyze dan test.
```

## Output awal AI dan keputusan

Output awal yang diusulkan adalah filter langsung di widget menggunakan
`notes.where(...)`, state query di `TextEditingController`, dan pesan kosong
yang sama untuk daftar awal maupun hasil pencarian. Setelah diverifikasi,
aturan filter dipindahkan ke `SearchNotes` di domain agar dapat diuji tanpa
Flutter. Widget hanya mengelola input dan menampilkan state.

| File | Keputusan | Alasan dan bukti |
|---|---|---|
| `domain/usecases/search_notes.dart` | Terima + refactor | Aturan pencarian murni, tanpa import framework/infrastruktur; dibuktikan oleh `flutter analyze`. |
| `presentation/pages/notes_page.dart` | Terima + refactor | Widget mengelola query dan rendering saja; repository/database tidak dipanggil dari widget. |
| `test/search_notes_test.dart` | Terima | Mencakup query cocok, tidak cocok, dan kosong; semua lulus. |
| `note_repository.dart` | Tolak perubahan | Kontrak repository tidak perlu berubah karena pencarian dilakukan pada hasil yang sudah dimuat. |
| `notes_database.dart` | Tolak perubahan | Tidak ada query database baru; perubahan akan memperluas scope fitur tanpa kebutuhan. |

## Verifikasi dan temuan AI

1. Temuan terbukti benar: filter case-sensitive akan gagal untuk query
   `BELANJA`. Test `filter judul mengabaikan huruf besar dan kecil` membuktikan
   kebutuhan normalisasi `toLowerCase()`, lalu implementasi diperbaiki.
2. Temuan ditolak: usulan menambah method `searchNotes` pada repository
   ditolak karena kebutuhan ini hanya filter daftar lokal dan tidak memerlukan
   perubahan kontrak atau query SQLite. Test use case membuktikan aturan dapat
   diuji tanpa datasource.
3. API yang digunakan hanya API Dart/Flutter yang tersedia (`where`, `toLowerCase`,
   `TextField`, `InputDecoration`, `AsyncValue.when`); tidak ada method atau
   package baru yang diada-adakan.

## Bukti pengujian

```text
flutter analyze
No issues found!

flutter test
All tests passed.
```

Uji manual yang harus dilakukan:

1. Query kosong: semua notes tampil atau pesan `Belum ada catatan.` jika data
   memang kosong.
2. Query `belanja`: judul yang cocok tampil tanpa membedakan kapitalisasi.
3. Query `zzz-tak-ada`: pesan `Catatan tidak ditemukan.` tampil.

## Refleksi

- Halusinasi/risiko utama adalah asumsi bahwa repository perlu method search
  baru. Pemeriksaan kontrak dan test menunjukkan filter lokal sudah cukup.
- Prompt dengan slot peran, konteks, tugas, batas, dan output menghasilkan
  perubahan yang lebih mudah diverifikasi.
- Refactor utama adalah memindahkan filter dari widget ke use case domain.
- Keputusan tersulit adalah membedakan empty state data awal dengan empty state
  hasil query agar pengguna mendapat umpan balik yang jelas.
