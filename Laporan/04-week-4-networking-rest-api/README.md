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
