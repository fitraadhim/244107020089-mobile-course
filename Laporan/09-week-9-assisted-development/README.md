# Week 09 - Assisted Development

## Identitas dan fitur

Project: `Minggu09/campus_notify`  
Fitur yang ditambahkan: pencarian berdasarkan judul notes dengan empty state.

Fitur ini menerima input pada field **Cari judul catatan**, melakukan pencarian
case-insensitive, dan menampilkan:

- `Belum ada catatan.` jika database belum memiliki notes;
- `Catatan tidak ditemukan.` jika query tidak cocok;
- daftar notes jika query cocok.

## Stack dan kontrak

- Flutter/Dart SDK `^3.13.0`
- Riverpod `^3.4.3`
- SQLite melalui `sqflite ^2.4.2+1`
- Dio `^5.11.1` untuk kebutuhan networking project
- Clean Architecture feature-first
- Kontrak repository: `Minggu09/campus_notify/lib/features/notes/domain/repositories/note_repository.dart`
- Use case baru: `Minggu09/campus_notify/lib/features/notes/domain/usecases/search_notes.dart`

Domain tetap bebas dari Flutter, Dio, SQLite, Firebase, dan secure storage.
Repository serta datasource tidak diubah karena pencarian dilakukan terhadap
daftar yang sudah diambil.

## Prompt dan proses AI-assisted development

Prompt mentah, konteks, output awal, keputusan terima/tolak, bukti grep/test,
serta refleksi tersedia di:

- [`Minggu09/campus_notify/docs/ai-log.md`](../../Minggu09/campus_notify/docs/ai-log.md)
- [`Minggu09/campus_notify/docs/ai-challenge.md`](../../Minggu09/campus_notify/docs/ai-challenge.md)
- [`Minggu09/campus_notify/docs/ai-verification-checklist.md`](../../Minggu09/campus_notify/docs/ai-verification-checklist.md)

Satu temuan yang terbukti benar adalah risiko filter case-sensitive, yang
ditutup dengan test `BELANJA`. Usulan menambah method search pada repository
ditolak karena tidak diperlukan untuk filter lokal dan akan mengubah kontrak
serta query database.

## Test dan verifikasi

Perintah dari folder `Minggu09/campus_notify`:

```powershell
flutter analyze
dart format --set-exit-if-changed .
flutter test
flutter test test/search_notes_test.dart
```

Test fitur berada di
[`Minggu09/campus_notify/test/search_notes_test.dart`](../../Minggu09/campus_notify/test/search_notes_test.dart)
dan mencakup query cocok, query tidak cocok, serta query kosong. Widget
menyediakan empty state untuk data kosong dan hasil pencarian kosong.

## Struktur perubahan

```text
Minggu09/campus_notify/
├── docs/ai-log.md
├── lib/features/notes/domain/usecases/search_notes.dart
├── lib/features/notes/presentation/pages/notes_page.dart
└── test/search_notes_test.dart
```

## Refleksi

1. Risiko halusinasi yang ditemukan adalah anggapan bahwa search selalu harus
   ditambahkan sebagai API repository. Kontrak dan kebutuhan lokal membuktikan
   sebaliknya.
2. Prompt paling membantu adalah prompt lima slot yang menyebut arsitektur,
   batas file, dan bentuk test.
3. Refactor penting adalah memindahkan filter dari widget ke use case domain
   yang dapat diuji tanpa Flutter.
4. Keputusan terima/tolak paling sulit adalah menolak perubahan repository,
   karena solusi tersebut terlihat lebih lengkap tetapi tidak sesuai scope dan
   menambah coupling.
