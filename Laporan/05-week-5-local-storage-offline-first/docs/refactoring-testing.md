# Refactoring dan Testing

## Refactoring

- Baris catatan dipindahkan dari `NotesPage` ke `lib/widgets/note_tile.dart`.
- `NoteTile` menampilkan badge `Belum tersinkron` saat `note.dirty == true`.
- Pemrosesan cache posts dan sinkronisasi dirty notes dipindahkan ke `lib/data/sync.dart`.
- Detail catatan tersedia melalui GoRouter pada path `/note/:id`.
- Halaman detail mengambil data ulang melalui `noteDetailProvider`, sehingga tidak bergantung pada state daftar.
- Repository sekarang memiliki operasi CRUD lengkap termasuk `updateNote`, yang
	memperbarui `updated_at` dan mengembalikan `dirty` menjadi `1`.
- `main.dart` memanggil `markOpenedNow()` saat startup untuk menyimpan timestamp
	pembukaan aplikasi.
- `SyncService` mendeklarasikan policy konflik `localUpdatedAtWins` secara
	eksplisit.

## Unit test

`test/note_test.dart` memverifikasi:

1. `Note.fromMap` aman saat field null atau hilang.
2. Flag `dirty` bertahan saat `toMap` lalu `fromMap`.
3. `NotesNotifier` berhasil menggunakan `FakeNoteRepository` tanpa SQLite.
4. `NotesNotifier` meneruskan error dari `FakeNoteRepository` sebagai state error.

## Verifikasi

Jalankan dari root proyek:

```powershell
flutter analyze
flutter test
```

Test tambahan yang relevan:

- Widget test memverifikasi root aplikasi dan section utama tampil.
- Unit test model memverifikasi null-safe mapping dan persistensi dirty flag.
- Provider test memakai `FakeNoteRepository` untuk skenario sukses dan error.
