import 'package:flutter_test/flutter_test.dart';

import 'package:ai_prompt_challenge/providers/stats_provider.dart';

void main() {
  test('notifier mengembalikan tiga statistik ketika berhasil', () async {
    // Roll 0.9 berada di atas 0.3 sehingga test selalu success.
    final notifier = StatsNotifier(failureRoll: 0.9, delay: Duration.zero);

    // build selesai tanpa menunggu delay dua detik pada test.
    final stats = await notifier.build();

    // Hasil success harus terdiri dari tiga item statistik.
    expect(stats, hasLength(3));
    expect(stats.first, contains('Pengguna aktif'));
  });

  test('notifier menghasilkan error ketika peluang gagal terpenuhi', () async {
    // Roll 0.1 berada di bawah 0.3 sehingga request selalu gagal.
    final notifier = StatsNotifier(failureRoll: 0.1, delay: Duration.zero);

    // build meneruskan exception yang nantinya menjadi AsyncError di provider.
    await expectLater(
      notifier.build(),
      throwsA(isA<Exception>()),
    );
  });
}
