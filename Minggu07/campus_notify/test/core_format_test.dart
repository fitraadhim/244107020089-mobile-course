import 'package:campus_notify/core/failures.dart';
import 'package:campus_notify/core/format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats a date and time consistently', () {
    final date = DateTime(2026, 10, 11, 9, 5);

    expect(formatDate(date), '11/10/2026');
    expect(formatDateTime(date), '11/10/2026 09:05');
  });

  test('parses notification routes without a widget', () {
    expect(
      parseNotificationRoute(
        {'route': 'pengumuman/3'},
        fallback: '/',
      ),
      '/pengumuman/3',
    );
    expect(
      parseNotificationRoute({}, fallback: '/'),
      '/',
    );
  });

  test('exposes friendly Failure messages to presentation code', () {
    const failure = NetworkFailure('Koneksi tidak tersedia.');

    expect(failureMessage(failure), 'Koneksi tidak tersedia.');
    expect(failureMessage(Exception('raw error')), 'Terjadi kesalahan. Silakan coba lagi.');
  });
}
