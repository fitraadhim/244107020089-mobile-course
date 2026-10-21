# Week 08 - Mid Project Review

hasil audit riwayat

![alt text](<screenshots/Screenshot 2026-10-21 231529.png>)

![alt text](<screenshots/Screenshot 2026-10-21 231622.png>)

![alt text](<screenshots/Screenshot 2026-10-21 231713.png>)

PR kecil 
![alt text](screenshots/PR.png)
nama commit dan isi commit kurang sesuai

## Nilai Kesiapan Tengah Semester

Penilaian tengah semester berfokus pada kesiapan fondasi proyek, bukan hanya
banyaknya fitur. Hasil review dirangkum dalam
[daftar periksa review commit](docs/review-checklist.md).

### Status Pemeriksaan

- [x] Struktur dan riwayat commit ditinjau; tiga pesan commit lama ditulis ulang
      dalam format Conventional Commits beserta alasannya.
- [x] Analisis Flutter bersih dengan `flutter analyze`.
- [x] Pengujian widget berjalan hijau dengan `flutter test`.
- [x] Pull Request kecil telah didokumentasikan melalui screenshot.
- [x] Workflow CI tersedia di
      [`.github/workflows/ci.yml`](../../.github/workflows/ci.yml) untuk
      menjalankan analisis dan test pada setiap Pull Request.
- [x] Temuan review yang dapat direproduksi telah ditindaklanjuti dan hasilnya
      dicatat di bagian verifikasi AI.

### Definisi Selesai

Mid review dinyatakan selesai apabila aplikasi tetap berjalan sesuai kondisi
akhir Minggu 7, pemeriksaan `flutter analyze` dan `flutter test` berhasil,
minimal satu PR kecil per pasangan telah melalui review, serta README
menyertakan status dan peta issue/PR. Review ini sudah memiliki checklist,
catatan PR, dan bukti pemeriksaan lokal; tindak lanjut komentar reviewer perlu
dicatat setelah proses review selesai.

Yang dinilai bukan banyaknya fitur, melainkan fondasi yang dapat dipercaya untuk
melanjutkan pengembangan pada paruh kedua semester.

## AI Verification Checklist

Hasil review AI tidak langsung diterapkan. Setiap temuan diverifikasi terhadap
kode, hasil test, dan konfigurasi CI. Detail prompt dan lima temuan awal
tersedia di [docs/ai_prompt.md](docs/ai_prompt.md).

### Bukti Verifikasi

- [x] **Temuan CI memakai direktori yang salah terbukti benar.** `pubspec.yaml`
      berada di `Minggu01/my_first_app`, sedangkan workflow menjalankan perintah
      Flutter dari root repository.
- [x] **Temuan dependensi belum di-install terbukti benar.** Workflow tidak
      memiliki langkah `flutter pub get`, sehingga runner baru belum memperoleh
      konfigurasi dependensi sebelum `analyze` dan `test`.
- [x] **Temuan test counter lama terbukti benar.** `test/widget_test.dart`
      masih mencari teks `0`, `1`, dan ikon `add`, sedangkan UI
      `main.dart` menampilkan profil mahasiswa. Saat diverifikasi dengan
      `flutter test`, test gagal karena widget `0` tidak ditemukan.
- [x] **Temuan `flutter analyze` diverifikasi.** Perintah `flutter analyze`
      berhasil pada pemeriksaan lokal dan menghasilkan `No issues found!`.
- [x] **Workflow CI telah diperbaiki secara lokal.** Workflow sekarang
      diarahkan ke `Minggu01/my_first_app`, menjalankan `flutter pub get`, lalu
      `flutter analyze` dan `flutter test`. Status GitHub Actions tetap perlu
      dikonfirmasi setelah Pull Request dibuat atau diperbarui.

### Temuan yang Ditolak

- [x] **Usulan pelanggaran aturan dependency ditolak.** Tidak ada perubahan
      feature-first atau Clean Architecture pada diff ini yang mengimpor
      Flutter, Dio, atau SQLite ke domain. Karena itu, tidak ada bukti untuk
      menolak perubahan berdasarkan aturan arah dependency.
- [x] **Temuan style yang tidak berdampak pada kebenaran ditolak.** Perubahan
      `print` menjadi `debugPrint` tidak dianggap masalah arsitektur atau
      perilaku. Perubahan tersebut justru menghilangkan lint `avoid_print`,
      sehingga tidak perlu ditolak sebagai sekadar preferensi style.

### Keputusan Akhir

Temuan bahwa test lama dan workflow CI belum siap dinyatakan **benar** karena
didukung inspeksi file dan kegagalan test yang dapat direproduksi. Temuan
dependency rule dinyatakan **tidak terbukti** karena diff tidak menyentuh layer
domain, data, atau presentation. Perbaikan lokal sudah selesai; status CI pada
Pull Request perlu dikonfirmasi setelah perubahan diunggah.

## Refactoring, Testing, dan Error Umum

Challenge refactoring sudah dikerjakan sebagai tindak lanjut review:

1. **Tindak lanjut review:** tiga temuan blocker dari review AI sudah diperbaiki:
   workflow diarahkan ke folder Flutter, dependensi di-install dengan
   `flutter pub get`, dan test counter lama diganti dengan test profil
   mahasiswa. Tidak ada komentar reviewer aktif lain yang tersedia untuk
   diimplementasikan.
2. **Otomatisasi pemeriksaan:** workflow
   [`.github/workflows/ci.yml`](../../.github/workflows/ci.yml) menjalankan
   `flutter analyze` dan `flutter test` pada setiap Pull Request. Format file
   Dart juga sudah dijalankan menggunakan `dart format`.
3. **Pemecahan perubahan:** perubahan dipisahkan menjadi bagian workflow CI,
   perbaikan test, dan dokumentasi review. Masing-masing perubahan dapat
   ditinjau secara terarah dan tidak mencampurkan refactor besar yang tidak
   berkaitan.

### Hasil Verifikasi

Perintah berikut dijalankan dari `Minggu01/my_first_app`:

```text
flutter analyze
No issues found!

flutter test
All tests passed!
```

Dengan demikian, error umum berupa test bawaan yang masih menguji counter lama
dan CI yang tidak menemukan project Flutter sudah diselesaikan. Pemeriksaan
GitHub Actions tetap menjadi verifikasi terakhir setelah workflow dijalankan
oleh Pull Request.

## Checklist Verifikasi Mandiri

Checklist ini digunakan untuk memastikan hasil review dapat dibuktikan secara
mandiri:

- [x] Branch fitur berasal dari `develop` dan PR kecil sudah dibuat menuju
      `develop`. PR #4 berstatus merged.
- [ ] Issue terkait tertutup otomatis melalui PR. Issue `#12` tidak ditemukan
      pada repository, sehingga klaim penutupan otomatis belum dapat
      diverifikasi.
- [ ] Minimal tiga komentar review bermakna sudah ditindaklanjuti sampai
      approve. Data PR #4 menunjukkan tidak ada komentar review, sehingga
      persyaratan ini belum terpenuhi.
- [x] `flutter analyze` bersih: `No issues found!`.
- [x] `dart format --set-exit-if-changed .` berhasil setelah file Dart
      dirapikan.
- [x] `flutter test` hijau: `All tests passed!`.
- [x] Tabel usulan AI dan keputusan final sudah didokumentasikan di
      [docs/ai_prompt.md](docs/ai_prompt.md), sedangkan verifikasi hasilnya
      dicatat pada bagian [AI Verification Checklist](#ai-verification-checklist).

### Status Akhir

Pemeriksaan kode dan otomatisasi sudah lulus. Dua item kolaborasi belum dapat
ditandai selesai karena bukti tiga komentar review dan issue yang ditutup
otomatis belum tersedia. Item tersebut perlu dilengkapi pada PR berikutnya,
bukan diisi berdasarkan asumsi.
