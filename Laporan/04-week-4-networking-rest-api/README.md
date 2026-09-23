# Week 04 - Networking and REST API

## PRAKTIKUM 2

1. berjalan normal
2. matikan internet
![alt text](<screenshots/Screenshot 2026-09-23 142706.png>)
setelah dinyalakan dan di coba kembali
![alt text](<screenshots/Screenshot 2026-09-23 142904.png>)
3. ini adalah hasilnya jika baseUrl diubah dengan url yang salah
![alt text](<screenshots/Screenshot 2026-09-23 143035.png>)

## PRAKTIKUM 3

![alt text](<screenshots/Screenshot 2026-09-23 150140.png>)

## AI Prompt Challenge

```text
Buatkan repository layer Flutter untuk endpoint GET /comments?postId={id}
dari JSONPlaceholder menggunakan Dio + flutter_riverpod.
Requirements:
- Model Comment dengan fromJson aman null (postId, id, name, email, body).
- CommentRepository dengan method fetchComments(postId) + timeout 10 detik.
- AsyncNotifierProvider dengan penanganan error otomatis (AsyncError)
  dan fungsi pesan error
  ramah pengguna untuk timeout, connection error, 404, dan 500.
- Satu unit test untuk fromJson dengan field yang hilang.
Jelaskan setiap bagian kode dalam komentar.
```

AI Verification

- [x] Prompt AI sudah ditulis dan dipindahkan ke [Laporan/04-week-4-networking-rest-api/README.md](Laporan/04-week-4-networking-rest-api/README.md).
- [x] Implementasi komentar dibuat pada model, repository, dan provider sesuai requirement: `Comment.fromJson` aman null, `CommentRepository.fetchComments(postId)` dengan timeout 10 detik, serta `AsyncNotifierProvider` dengan pesan error ramah pengguna.
- [x] Unit test untuk field yang hilang sudah dibuat dan berhasil dijalankan.
- [x] Hasil verifikasi: `flutter test test/comment_model_test.dart` menghasilkan `00:06 +1: All tests passed!`.
- [x] Setiap bagian kode dilengkapi komentar penjelasan untuk memudahkan pembacaan dan pengujian.

Prompt AI yang dipakai:

```text
Buatkan repository layer Flutter untuk endpoint GET /comments?postId={id}
dari JSONPlaceholder menggunakan Dio + flutter_riverpod.
Requirements:
- Model Comment dengan fromJson aman null (postId, id, name, email, body).
- CommentRepository dengan method fetchComments(postId) + timeout 10 detik.
- AsyncNotifierProvider dengan penanganan error otomatis (AsyncError)
  dan fungsi pesan error
  ramah pengguna untuk timeout, connection error, 404, dan 500.
- Satu unit test untuk fromJson dengan field yang hilang.
Jelaskan setiap bagian kode dalam komentar.
```

## Checklist verifikasi mandiri

- [x] UI tidak memanggil Dio langsung, semua akses data lewat repository + provider.
- [x] Empat state tampil benar: loading, error (+ retry), empty, success.
- [x] Pagination: data bertambah saat scroll, tidak ada request ganda, ada indikator akhir data.
- [x] `flutter analyze` tanpa issue dan semua test lulus.
- [x] Hasil AI diverifikasi dan didokumentasikan pada folder `docs/`.

Catatan implementasi:

- Struktur test akhir memuat: `import 'package:flutter_test/flutter_test.dart';` + `FakePostRepository` + `main()` dengan 4 skenario uji.
- `fromJson` aman terhadap field yang hilang, dengan fallback nilai default untuk `id`, `title`, dan `userId`.
- `friendlyErrorMessage` memeriksa `DioExceptionType.connectionError` dan memastikan pesan menggunakan kata `terhubung`.
- Provider test menggunakan `ProviderContainer` dan `overrideWithValue` agar repository palsu dapat menggantikan repository asli tanpa memanggil HTTP nyata.
- Helper `readPostsOnce` dan `readPostsErrorOnce` dipakai untuk menguji state success dan state error secara konsisten.

TUGAS

## MINI PROJECT / INDUSTRY CHALLENGE

Implementasi dibuat pada project Flutter [Minggu04/hola](../../Minggu04/hola).

1. **REST API dan Riverpod**
  - Mengambil data dari JSONPlaceholder endpoint `GET /posts`.
  - Data ditampilkan ke UI melalui `PostRepository` dan `flutter_riverpod`.

2. **Dio dan model**
  - Dio dibuat terpusat di `ApiClient` dengan base URL JSONPlaceholder.
  - Menggunakan timeout 10 detik dan `LogInterceptor`.
  - `Post.fromJson` aman terhadap field atau nilai null.

3. **Empat state UI**
  - `Loading`: menampilkan indikator loading.
  - `Error`: menampilkan pesan error dan tombol `Retry`.
  - `Empty`: menampilkan pesan ketika API mengembalikan data kosong.
  - `Success`: menampilkan daftar post.

4. **Pagination**
  - Infinite scroll menggunakan 10 item per halaman dengan parameter `_page` dan `_limit`.
  - Flag `isLoadingMore` mencegah request ganda.
  - Flag `hasReachedEnd` menghentikan request ketika data sudah habis.

5. **Pengujian**
  - Unit test model `Post.fromJson` untuk field null atau malformed.
  - Provider test menggunakan `FakePostRepository` untuk menguji pagination dan guard request ganda.
  - Hasil `flutter test`: `00:01 +2: All tests passed!`.
6. diatas
 
