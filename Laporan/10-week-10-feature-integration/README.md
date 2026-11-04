# Week 10 - AI Feature Integration

## Identitas dan fitur

Project: `Minggu10/campus_notify`  
Fitur: **Campus Assistant**, chat AI untuk pertanyaan informasi kampus.

Pengguna membuka fitur dari tombol **Buka Campus Assistant** di home, menulis
pertanyaan, lalu menerima jawaban Gemini jika API key tersedia. Tanpa key atau
ketika layanan gagal, aplikasi memakai fallback offline yang ramah.

## Implementasi

```text
lib/features/ai_assistant/
├── data/
│   ├── datasources/ai_assistant_datasource.dart
│   └── repositories/ai_assistant_repository_impl.dart
├── domain/
│   ├── entities/ai_reply.dart
│   ├── repositories/ai_assistant_repository.dart
│   └── usecases/ask_ai_assistant.dart
└── presentation/
    ├── pages/ai_assistant_page.dart
    └── providers/ai_assistant_providers.dart
```

Domain tidak bergantung pada Flutter, Dio, atau secure storage. API key hanya
dibaca melalui `flutter_secure_storage`; tidak ada secret di source code.

Pengguna memasukkan API key secara manual pada panel konfigurasi di halaman
Campus Assistant. Tombol **Simpan API key** menyimpannya ke secure storage.

## Prompt dan keputusan AI

Prompt sistem membatasi persona sebagai asisten kampus berbahasa Indonesia,
maksimal tiga kalimat, tidak meminta data pribadi, dan mengakui jika informasi
tidak tersedia. Prompt user dikirim dari pertanyaan yang sudah di-trim.

Log lengkap prompt mentah, output awal AI, keputusan terima/tolak, dan refleksi
tersedia di
[`Minggu10/campus_notify/docs/ai-log.md`](../../Minggu10/campus_notify/docs/ai-log.md).

| Saran | Keputusan | Alasan |
|---|---|---|
| Panggil Gemini langsung dari widget | Tolak | Melanggar pemisahan layer dan sulit diuji. |
| Hardcode API key | Tolak | Risiko kebocoran credential. |
| Gunakan repository + datasource | Terima | Memisahkan domain dari HTTP/storage. |
| Fallback offline | Terima | UX tetap berguna saat API down atau key belum ada. |

## Risiko, privasi, dan biaya

| Risiko | Mitigasi |
|---|---|
| Kebocoran API key | Secure storage dan tidak mencatat key. |
| Pengiriman data sensitif | Peringatan UI dan system prompt yang melarang password, token, NIM, dan alamat. |
| Biaya request | `maxOutputTokens: 180`, temperature 0.2, satu request per submit. |
| API down/timeout | Timeout Dio 20 detik, pesan berdasarkan status HTTP, dan fallback offline. |
| Respons tidak valid | Validasi struktur kandidat sebelum menampilkan text. |

## Bukti pengujian

```powershell
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
```

API key dapat dikonfigurasi saat menjalankan aplikasi melalui:

```powershell
flutter run --dart-define=GEMINI_API_KEY=API_KEY_KAMU
```

Nilai tersebut dibaca dari `String.fromEnvironment` dan tidak disimpan di
source code. Jika tidak diberikan, aplikasi mencoba membaca key dari secure
storage lalu memakai fallback offline.

Test yang ditambahkan:

- `ai_assistant_test.dart`: pertanyaan valid diteruskan ke repository dan
  pertanyaan kosong ditolak;
- `ai_assistant_widget_test.dart`: panduan privasi dan tombol kirim tersedia.

## Refleksi

1. Fitur chat dipilih karena sesuai dengan kebutuhan tanya-jawab informasi
   kampus dan mudah diberi fallback.
2. Privasi dilindungi dengan secure storage, larangan pada prompt sistem, dan
   peringatan eksplisit pada UI.
3. Fallback offline memberi petunjuk menu pengumuman atau menjelaskan bahwa key
   AI belum dikonfigurasi.
4. Pelajaran UX utama: status mode offline perlu terlihat agar pengguna tidak
   menganggap jawaban lokal sebagai jawaban real-time dari model.
