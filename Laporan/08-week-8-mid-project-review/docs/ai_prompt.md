# Hasil Review PR Flutter

## Prompt Review

```text
Review PR Flutter ini sebagai senior Flutter dev.
Konteks: feature-first Clean Architecture
(presentation -> domain <- data), Riverpod, GoRouter, SQLite + Dio.
Fokus: kebenaran, arsitektur, dan test. Abaikan style.
Berikan 5 temuan teratas + level (blocker/saran)
+ alasan + usulan potongan kode perbaikan.
```

## Konteks Review

Tidak ada Pull Request aktif yang terdeteksi di GitHub. Oleh karena itu, review
dilakukan pada kandidat branch lokal `feat` dibandingkan dengan
`origin/develop`.

Perubahan yang diperiksa:

- Workflow CI untuk Pull Request.
- Perubahan `print` menjadi `debugPrint`.
- Dokumentasi kesiapan tengah semester.
- Test widget aplikasi Flutter.

## Lima Temuan Teratas

### 1. BLOCKER - CI berjalan dari direktori yang salah

File: [`.github/workflows/ci.yml`](../../../.github/workflows/ci.yml)

Workflow menjalankan `flutter analyze` dan `flutter test` dari root repository,
sedangkan `pubspec.yaml` berada di `Minggu01/my_first_app`. Runner GitHub
Actions tidak akan menemukan project Flutter.

Usulan perbaikan:

```yaml
defaults:
  run:
    working-directory: Minggu01/my_first_app
```

### 2. BLOCKER - Dependensi belum di-install

File: [`.github/workflows/ci.yml`](../../../.github/workflows/ci.yml)

Workflow belum menjalankan `flutter pub get`. Pada runner baru, konfigurasi
dependensi belum tersedia sehingga analisis dan test dapat gagal sebelum kode
diperiksa.

Usulan perbaikan:

```yaml
- name: Install dependencies
  run: flutter pub get
```

Langkah ini harus dijalankan setelah `working-directory` diarahkan ke project
Flutter.

### 3. BLOCKER - Test masih menguji aplikasi counter lama

File:
[`Minggu01/my_first_app/test/widget_test.dart`](../../../Minggu01/my_first_app/test/widget_test.dart)

Test masih mencari teks `0`, `1`, dan ikon `add`, sedangkan aplikasi sekarang
menampilkan profil mahasiswa. Test akan gagal karena widget counter sudah tidak
ada.

Usulan perbaikan:

```dart
void main() {
  testWidgets('menampilkan profil mahasiswa', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Profil Mahasiswa'), findsOneWidget);
    expect(
      find.text('Nama Anda: Muhammad Fitra Adhim Nurrochman'),
      findsOneWidget,
    );
    expect(find.text('NIM: 244107020089'), findsOneWidget);
    expect(find.byIcon(Icons.school), findsOneWidget);
  });
}
```

### 4. SARAN - Versi Flutter CI belum dikunci

File: [`.github/workflows/ci.yml`](../../../.github/workflows/ci.yml)

Action Flutter hanya menggunakan channel stable tanpa versi tertentu. Perubahan
versi pada runner dapat menyebabkan hasil CI berbeda dari komputer pengembang.

Usulan perbaikan:

```yaml
- name: Set up Flutter
  uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.35.0'
    channel: stable
    cache: true
```

Versi tersebut harus disesuaikan dengan versi Flutter yang digunakan proyek.

### 5. SARAN - README mengklaim pemeriksaan hijau tanpa bukti CI valid

File: [`README.md`](../README.md)

README menandai `flutter analyze` dan `flutter test` sebagai berhasil, padahal
workflow CI belum benar dan test masih menguji counter lama. Status tersebut
sebaiknya belum dicentang sebelum CI berhasil.

Usulan sementara:

```markdown
- [ ] Analisis Flutter bersih dengan `flutter analyze`.
- [ ] Pengujian widget berjalan hijau dengan `flutter test`.
- [ ] Workflow CI berhasil pada Pull Request.
```

Setelah CI berhasil, status dapat diubah menjadi `[x]` dan dilengkapi tautan
atau bukti run CI.

## Kesimpulan

Perubahan `debugPrint` pada
[`main.dart`](../../../Minggu01/my_first_app/lib/main.dart) sudah benar dan
tidak menimbulkan masalah arsitektur.

Kandidat PR belum siap di-merge sebelum tiga blocker berikut diperbaiki:

1. Mengarahkan workflow ke `Minggu01/my_first_app`.
2. Menjalankan `flutter pub get`.
3. Memperbarui test agar sesuai dengan UI profil mahasiswa.

Konteks feature-first Clean Architecture, Riverpod, GoRouter, SQLite, dan Dio
belum tercermin pada perubahan yang direview. Diff ini hanya mencakup aplikasi
Flutter sederhana, workflow CI, dan dokumentasi.
