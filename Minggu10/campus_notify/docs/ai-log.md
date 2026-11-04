# AI Development Log - Campus Assistant

Tanggal: 4 November 2026  
Fitur: chat AI Campus Assistant dengan fallback offline

## Konteks dan batasan

- Project: `campus_notify` feature-first Clean Architecture.
- Dependency yang sudah tersedia: Dio, Riverpod, dan
  `flutter_secure_storage`; tidak menambahkan package baru.
- API key tidak boleh ditulis di source code, log, atau request yang dibagikan
  ke repository.
- Domain tidak boleh mengimpor Flutter, Dio, atau secure storage.
- Fitur dibatasi pada satu layar chat, satu pertanyaan per request, respons
  ringkas, dan fallback offline yang aman.

## Prompt sistem

```text
Kamu adalah Campus Assistant yang ramah. Jawab dalam Bahasa Indonesia,
maksimal tiga kalimat, hanya berdasarkan informasi yang diberikan pengguna.
Jangan meminta atau mengungkap password, token, NIM, alamat, atau data pribadi.
Jika tidak tahu, katakan bahwa informasi belum tersedia.
```

Prompt ini dikirim sebagai `systemInstruction` ke Gemini jika API key tersedia.

## User prompt contoh

```text
Di mana saya bisa melihat pengumuman kampus?
```

## Prompt mentah untuk AI coding assistant

```text
Peran: senior Flutter developer.
Konteks: campus_notify memakai feature-first Clean Architecture, Riverpod,
Dio, dan flutter_secure_storage. Tambahkan satu fitur AI Campus Assistant
berupa chat sederhana.
Tugas: buat use case domain, repository contract, datasource Gemini opsional,
halaman chat, route, dan tombol dari home. Simpan API key hanya di secure
storage. Jika key tidak ada atau request gagal, tampilkan fallback offline
yang ramah dan jangan bocorkan error sensitif.
Batas: jangan hardcode secret, jangan mengimpor Dio/Flutter ke domain, jangan
mengubah repository pengumuman atau autentikasi, dan tambahkan unit test serta
widget test.
Output: kode, test, risiko privasi/biaya, dan cara verifikasi.
```

## Output awal dan keputusan

Output awal yang diusulkan adalah memanggil API langsung dari widget dan
menaruh URL serta API key di halaman chat. Usulan tersebut ditolak. Implementasi
akhir memisahkan UI, use case, repository, dan datasource; key dibaca dari
`flutter_secure_storage`; request gagal kembali ke mode offline.

| Area | Keputusan | Alasan dan bukti |
|---|---|---|
| Domain entity/use case | Terima + refactor | Murni Dart, hanya memvalidasi pertanyaan dan mengembalikan kontrak. |
| Gemini datasource | Terima + refactor | Dio dan secure storage hanya berada di data layer; output divalidasi sebelum ditampilkan. |
| Chat page | Terima + refactor | Widget hanya mengelola input, loading, dan pesan; tidak tahu detail HTTP. |
| API key hardcode | Tolak | Berisiko bocor; key hanya dibaca dari secure storage. |
| Mengirim data pribadi | Tolak | Prompt sistem melarangnya dan UI memberi peringatan sebelum chat. |

## Output AI dan fallback

Jika API key belum dikonfigurasi, pertanyaan jadwal atau pengumuman dijawab
dengan petunjuk lokal. Pertanyaan lain menjelaskan bahwa mode offline aktif.
Jika API gagal, UI menampilkan pesan ramah dan label `Mode offline`; exception
mentah tidak ditampilkan sebagai hasil sukses.

## Risiko dan mitigasi

| Risiko | Mitigasi |
|---|---|
| API key bocor | Secure storage; tidak ada key di source atau log. |
| Data pribadi terkirim | Peringatan UI dan system prompt yang melarang secret/data pribadi. |
| Biaya/rate limit | Respons maksimal 180 token, suhu rendah, satu request per submit. |
| API down/timeout | Timeout Dio dan fallback offline. |
| Respons kosong/format berubah | Validasi `candidates/content/parts/text`; fallback saat error. |

## Verifikasi

```text
flutter analyze
No issues found!

flutter test
All tests passed.
```

Uji manual:

1. Buka `Campus Assistant` dari halaman home.
2. Kirim `Di mana pengumuman kampus?` tanpa API key; pastikan respons mode
   offline tampil.
3. Kirim pertanyaan kosong; tidak ada request yang dikirim.
4. Dengan key yang disimpan aman, kirim pertanyaan biasa dan pastikan jawaban
   ringkas muncul.
