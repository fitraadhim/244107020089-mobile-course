import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../messaging/push_service.dart'; // Pastikan path import ini sesuai struktur folder kamu
import '../routes.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug FCM & Notifikasi'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CARD DISPLAY TOKEN TERPOTONG (UNTUK REPORT/JOBSHEET)
            const _FcmTokenCard(),

            const SizedBox(height: 24),

            // CARD PANDUAN PENGUJIAN JOBSHEET
            const Text(
              'Status Checklist Jobsheet:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            const ChecklistCard(
              icon: Icons.check_circle_outline,
              color: Colors.green,
              title: '1. Tampilkan Token Terpotong',
              subtitle: 'Screenshot halaman ini untuk bukti laporan.',
            ),
            const ChecklistCard(
              icon: Icons.refresh,
              color: Colors.orange,
              title: '2. Uji onTokenRefresh',
              subtitle: 'Clear Data / Reinstall app, lalu cek perubahan token di atas.',
            ),
            const ChecklistCard(
              icon: Icons.send_to_mobile,
              color: Colors.blue,
              title: '3. Kirim via Firebase Console',
              subtitle: 'Tekan Home (App Background) lalu kirim notifikasi dari Console.',
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.push(AppRoutes.announcements),
                icon: const Icon(Icons.announcement_outlined),
                label: const Text('Buka Daftar Pengumuman'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kartu token dipisah ke widget sendiri: saat token FCM berubah hanya
/// kartu ini yang dibangun ulang dan hanya area ini yang di-repaint
/// (RepaintBoundary), bukan seluruh halaman.
class _FcmTokenCard extends StatelessWidget {
  const _FcmTokenCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.vibration_outlined, color: Colors.indigo),
                SizedBox(width: 8),
                Text(
                  'FCM Token (Debug Mode)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Token terpotong (12 karakter awal + ...) demi keamanan sesuai instruksi jobsheet:',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),

            // Mendengarkan perubahan token secara realtime dari ValueNotifier
            ValueListenableBuilder<String>(
              valueListenable: fcmTokenNotifier,
              builder: (context, tokenValue, child) {
                return RepaintBoundary(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.indigo.shade200),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: SelectableText(
                            tokenValue,
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 20),
                          tooltip: 'Salin Token',
                          onPressed: () => _copyToken(context, tokenValue),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  static void _copyToken(BuildContext context, String token) {
    Clipboard.setData(ClipboardData(text: token));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Token disalin ke clipboard!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

/// Kartu checklist dibuat const agar instance-nya dapat dipakai ulang
/// (canonicalized) dan tidak dibangun ulang setiap kali halaman dibangun.
class ChecklistCard extends StatelessWidget {
  const ChecklistCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    super.key,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: color, size: 28),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      ),
    );
  }
}
