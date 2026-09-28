# Perbandingan Local Storage

| Kriteria | SharedPreferences | Hive | sqflite | Drift |
| --- | --- | --- | --- | --- |
| Query | Key-value sederhana | Lookup/filter sederhana | SQL, JOIN, index, transaksi | SQL type-safe dan query terkomposisi |
| Relasi | Tidak cocok | Manual | Didukung SQLite | Didukung SQLite dan deklarasi type-safe |
| Reaktivitas | Tidak ada stream database | Listener/ValueListenable | Perlu invalidasi atau wrapper | `watch()` menghasilkan stream |
| Type-safety | Rendah | Sedang melalui adapter | Mapping map ditulis manual | Tinggi melalui generated code |
| Boilerplate | Sangat kecil | Kecil-sedang | Sedang | Sedang-besar karena code generation |
| Testing | Mudah di-mock | Box/adapter mudah diuji | Fixture/database test | Query dan database test kuat |

## Keputusan Project

- **SharedPreferences** dipakai untuk `dark_mode`, `force_offline`, dan
  `last_opened_at` karena semuanya key-value sederhana.
- **sqflite** dipakai untuk catatan dan cache karena project memerlukan tabel,
  ordering `updated_at`, dirty flag, transaksi, serta kompatibilitas SQLite
  tanpa menambah code generation.
- **Drift** adalah kandidat migrasi jika aplikasi memerlukan banyak query,
  relasi, dan stream reaktif. Drift lebih type-safe, tetapi menambah setup
  `drift_dev`, `build_runner`, generated code, dan migrasi.
- **Hive** tidak dipilih karena kebutuhan query dan relasi project lebih cocok
  dengan SQLite.

Daftar catatan tidak disimpan di SharedPreferences karena serialisasi satu
koleksi besar akan menghilangkan query, index, transaksi, update per item, dan
kontrol migrasi.
