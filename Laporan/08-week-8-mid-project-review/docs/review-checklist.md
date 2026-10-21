# Daftar Periksa Review Riwayat Commit

## Tujuan

Dokumen ini mencatat tiga commit lama yang memiliki pesan kurang informatif.
Pesan tersebut ditulis ulang menggunakan format
[Conventional Commits](https://www.conventionalcommits.org/).

Format dasar yang digunakan:

```text
<type>(<scope>): <description>
```

## Hasil Review

| Commit lama | Pesan lama | Pesan yang disarankan | Alasan |
|---|---|---|---|
| `7a03e36` | `.` | `fix(api): update Dio timeout options and remove unused imports` | Commit ini memperbaiki konfigurasi timeout Dio agar kompatibel dengan konstruksi `Options` yang digunakan, sekaligus menghapus import yang tidak terpakai dari halaman dan widget test. Pesan `.` tidak menjelaskan tujuan perubahan. |
| `11298cd` | `refleksi` | `docs(week-4): add networking reflection and implementation answers` | Perubahan hanya menambahkan bagian refleksi beserta jawaban pada README Week 4. Tipe `docs` lebih tepat karena tidak mengubah perilaku aplikasi. |
| `6ceea73` | `selesai` | `feat(notes): add offline notes sync, detail page, and tests` | Commit ini menambahkan fitur utama aplikasi catatan offline, sinkronisasi, halaman detail, provider, widget, konfigurasi dependensi, dan pengujian. Tipe `feat` menggambarkan penambahan kemampuan baru, sedangkan scope `notes` memperjelas area yang terdampak. |

## Panduan Pesan Commit yang Baik

- [x] Menggunakan tipe commit yang sesuai, seperti `fix`, `feat`, atau `docs`.
- [x] Menggunakan scope untuk memperjelas area perubahan.
- [x] Menggunakan deskripsi singkat dalam bentuk perintah atau tindakan.
- [x] Menjelaskan perubahan berdasarkan isi diff, bukan hanya nama tugas.
- [x] Menghindari pesan umum seperti `.`, `selesai`, atau `refleksi`.
- [x] Menggunakan huruf kecil pada tipe, scope, dan deskripsi.
- [x] Tidak mengakhiri deskripsi dengan tanda titik.
- [x] Membatasi baris pertama agar tetap singkat dan mudah dibaca.
- [x] Memisahkan perubahan yang tidak berkaitan ke commit yang berbeda.
- [x] Menambahkan isi commit jika perubahan membutuhkan konteks atau alasan tambahan.

### Format yang Disarankan

```text
<tipe>(<cakupan>): <deskripsi singkat>
```

Contoh:

```text
fix(api): perbaiki batas waktu permintaan Dio
feat(notes): tambahkan sinkronisasi catatan offline
docs(week-4): tambahkan refleksi jaringan dan jawaban tugas
```

### Panduan Pemilihan Tipe

| Tipe | Penggunaan |
|---|---|
| `feat` | Menambahkan fitur atau kemampuan baru. |
| `fix` | Memperbaiki kesalahan atau perilaku yang tidak sesuai. |
| `docs` | Mengubah dokumentasi tanpa mengubah perilaku aplikasi. |
| `test` | Menambahkan atau memperbaiki pengujian. |
| `refactor` | Mengubah struktur kode tanpa mengubah perilaku. |
| `chore` | Melakukan pemeliharaan seperti konfigurasi atau dependensi. |

Pesan commit harus menjawab pertanyaan: perubahan apa yang dibuat dan pada
bagian mana perubahan tersebut terjadi? Hindari pesan yang terlalu umum seperti
`update`, `perbaikan`, atau `selesai` karena tidak membantu saat membaca riwayat.

## Catatan

Daftar di atas adalah usulan pesan untuk proses simulasi perbaikan riwayat
commit. Isi commit lama tidak diubah secara langsung dalam review ini. Jika
dilakukan penulisan ulang riwayat, perubahan tersebut perlu dikomunikasikan
kepada kolaborator sebelum branch diunggah ulang secara paksa (`force-push`).
