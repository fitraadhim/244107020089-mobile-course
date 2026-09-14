// import 'dart:math';

// import 'package:flutter_riverpod/flutter_riverpod.dart';

// // Satu-satunya provider yang menyimpan state pengambilan statistik.
// final statsProvider =
//     AsyncNotifierProvider<StatsNotifier, List<String>>(StatsNotifier.new);

// // AsyncNotifier mengubah hasil asynchronous menjadi loading, error, atau data.
// class StatsNotifier extends AsyncNotifier<List<String>> {
//   // failureRoll hanya digunakan test agar peluang gagal dapat dipastikan.
//   StatsNotifier({this.failureRoll, this.delay = const Duration(seconds: 2)});

//   final double? failureRoll;
//   final Duration delay;

//   @override
//   Future<List<String>> build() async {
//     // Delay ini mensimulasikan request API selama dua detik.
//     await Future.delayed(delay);

//     // Nilai acak di bawah 0.3 membuat request gagal sekitar 30% waktu.
//     final roll = failureRoll ?? Random().nextDouble();
//     if (roll < 0.3) {
//       throw Exception('Gagal mengambil data statistik');
//     }

//     // Tiga data statistik yang ditampilkan ketika request berhasil.
//     return [
//       'Pengguna aktif: 128',
//       'Pesanan hari ini: 42',
//       'Pendapatan: Rp2,4 jt',
//     ];
//   }
// }
