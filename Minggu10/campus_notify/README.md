# Campus Notify - Week 10

## Fitur AI

Campus Notify memiliki **Campus Assistant**, chat AI yang dapat dibuka dari
home. Gemini 3.8 Flash dipakai jika API key tersedia melalui
`flutter_secure_storage`;
jika belum tersedia atau layanan gagal, aplikasi menggunakan fallback offline.

API key tidak disimpan di source code. Jangan kirim password, token, NIM,
alamat, atau data pribadi ke layanan AI.

API key dapat dimasukkan langsung pada panel **Konfigurasi API key Gemini** di
halaman Campus Assistant, lalu disimpan ke secure storage perangkat.

## Arsitektur dan verifikasi

Fitur mengikuti alur `presentation -> domain <- data` dan memakai Dio,
Riverpod, serta `flutter_secure_storage`. Prompt sistem, risiko, keputusan
AI, dan refleksi tersedia di [docs/ai-log.md](docs/ai-log.md).

```powershell
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
```
