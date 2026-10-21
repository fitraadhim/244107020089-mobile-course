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

## Mini Project / Industry Challenge

Bagian ini mendokumentasikan kelanjutan project portfolio dan bukti disiplin
kolaborasi pada Week 08. Perubahan dilakukan pada repository yang sama, bukan
membuat project baru.

### Peta Project dan Teknologi

| Bagian | Dokumentasi |
|---|---|
| Project yang dilanjutkan | Portfolio project dari minggu sebelumnya; review Week 08 berfokus pada validasi, testing, CI, dan dokumentasi. |
| Fitur utama yang diverifikasi | Tampilan profil mahasiswa pada [Minggu01/my_first_app/lib/main.dart](../../Minggu01/my_first_app/lib/main.dart). |
| Stack yang digunakan | Flutter, Dart, Flutter Test, GitHub Actions, dan Conventional Commits. |
| Cara menjalankan pemeriksaan | `cd Minggu01/my_first_app`, lalu `flutter pub get`, `flutter analyze`, dan `flutter test`. |
| Dokumentasi teknis | [review-checklist.md](docs/review-checklist.md) dan [ai_prompt.md](docs/ai_prompt.md). |

### Bukti Persyaratan Challenge

1. **Issue dan PR kecil:** PR [#4](https://github.com/fitraadhim/244107020089-mobile-course/pull/4)
   dibuat dari branch `feat` menuju `develop` dan sudah di-merge. Issue `#12`
   tidak tersedia di repository, sehingga hubungan `Closes #12` tidak
   diklaim sebagai bukti.
2. **Template PR:** bukti PR dan perubahan tersedia pada
   [screenshots/PR.png](screenshots/PR.png). Dokumentasi review mencatat
   masalah, solusi, cara uji, dan keputusan teknis.
3. **Mesin hijau:** pemeriksaan lokal menghasilkan `flutter analyze` bersih,
   `dart format --set-exit-if-changed .` bersih, dan `flutter test` lulus.
   Workflow CI tersedia di
   [`.github/workflows/ci.yml`](../../.github/workflows/ci.yml) dan sudah
   diarahkan ke folder project Flutter.
4. **AI verification:** prompt, lima temuan, bukti verifikasi, keputusan
   penerimaan/penolakan, dan alasan teknis tersedia di
   [docs/ai_prompt.md](docs/ai_prompt.md) serta bagian
   [AI Verification Checklist](#ai-verification-checklist).
5. **Struktur folder portfolio:** folder Week 08 memiliki
   `README.md`, `docs/`, dan `screenshots/` sesuai kebutuhan dokumentasi.

### Status dan Hasil yang Dicapai

- [x] Pemeriksaan lokal dan test aplikasi berhasil.
- [x] Workflow CI untuk Pull Request tersedia.
- [x] Dokumentasi review commit, review AI, dan verifikasi mandiri tersedia.
- [x] Bukti PR kecil yang sudah di-merge tersedia.
- [ ] Minimal tiga komentar review bermakna sampai approve belum tercapai pada
      PR #4 karena PR tersebut tidak memiliki komentar review.
- [ ] Issue tertutup otomatis belum dapat dibuktikan karena issue `#12` tidak
      ditemukan.

Kesimpulannya, fondasi teknis dan dokumentasi challenge sudah dikerjakan.
Persyaratan kolaborasi yang belum memiliki bukti ditandai terbuka agar dapat
dilengkapi pada PR berikutnya tanpa memalsukan status review.

## Refleksi

### 1. Apa beda LGTM buta dengan approve yang bertanggung jawab?

LGTM buta hanya menyatakan bahwa perubahan terlihat baik tanpa memeriksa
kebenaran kode, test, konfigurasi CI, atau dampaknya terhadap project. Risiko
untuk tim adalah bug ikut di-merge, CI gagal setelah PR diterima, dan reviewer
tidak memiliki bukti untuk mempertanggungjawabkan keputusannya.

Approve yang bertanggung jawab dilakukan setelah reviewer membaca diff,
menjalankan atau memeriksa test, memvalidasi konfigurasi, dan memastikan
komentar penting sudah ditindaklanjuti. Pada review Week 08, pemeriksaan
menemukan bahwa CI belum diarahkan ke folder Flutter dan test masih memakai
template counter lama. Karena itu, perubahan tersebut tidak seharusnya langsung
di-approve sebelum diperbaiki.

### 2. Kapan memberi status request changes, dan kapan cukup saran?

`Request changes` diberikan jika masalah dapat membuat aplikasi atau CI gagal,
test tidak merepresentasikan perilaku aplikasi, ada risiko regresi, atau
perubahan melanggar aturan arsitektur dan keamanan. Temuan seperti CI yang
menjalankan Flutter dari direktori yang salah dan test counter lama termasuk
kategori ini.

Saran cukup digunakan untuk perbaikan yang tidak menghalangi fungsi utama,
misalnya mengunci versi Flutter di CI agar hasil build lebih konsisten atau
merapikan struktur workflow. Saran tetap perlu dipertimbangkan, tetapi tidak
selalu menjadi alasan untuk menahan merge.

### 3. Bagian mana dari review AI yang ditolak atau disederhanakan?

Temuan mengenai kemungkinan pelanggaran dependency rule ditolak karena diff
tidak menyentuh layer `domain`, `data`, atau `presentation` pada arsitektur
feature-first. Tidak ada bukti bahwa Flutter, Dio, atau SQLite diimpor ke
domain, sehingga temuan tersebut tidak dapat dianggap sebagai masalah nyata.

Temuan style juga disederhanakan. Perubahan `print` menjadi `debugPrint` memang
menghilangkan lint `avoid_print`, tetapi tidak dianggap sebagai masalah
arsitektur atau kebenaran perilaku. Fokus review tetap pada CI, test, dan
validasi yang berdampak langsung.

### 4. Satu hal konkret yang diperbaiki setelah review sejawat

Perbaikan paling konkret adalah mengganti `widget_test.dart` yang masih
menguji aplikasi counter bawaan dengan test yang memverifikasi UI profil
mahasiswa. Dampaknya, test sekarang sesuai dengan perilaku aplikasi yang
sebenarnya dan tidak lagi gagal karena mencari teks `0`, `1`, atau ikon `add`
yang tidak ada.

Selain itu, workflow CI diperbaiki agar menggunakan folder
`Minggu01/my_first_app`, menjalankan `flutter pub get`, lalu menjalankan
`flutter analyze` dan `flutter test`. Hasil akhirnya adalah analisis bersih
dan seluruh test lulus secara lokal.
