import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/stats_provider.dart';

// ConsumerWidget dapat membaca dan bereaksi terhadap perubahan provider.
class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // watch membuat UI dibangun ulang setiap AsyncValue berubah.
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistik')),
      // when memastikan loading, error, dan success ditangani semuanya.
      body: statsAsync.when(
        // Spinner tampil selama request dua detik sedang berlangsung.
        loading: () => const Center(child: CircularProgressIndicator()),
        // Error menampilkan pesan dan tombol untuk memulai ulang provider.
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Gagal memuat statistik: $error'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.invalidate(statsProvider),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
        // Success menampilkan tepat tiga data dalam ListView.
        data: (stats) => ListView.builder(
          itemCount: stats.length,
          itemBuilder: (context, index) => ListTile(
            leading: const Icon(Icons.insights),
            title: Text(stats[index]),
          ),
        ),
      ),
    );
  }
}
