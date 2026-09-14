import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pages/stats_page.dart';

// Titik awal aplikasi yang menyediakan Riverpod untuk seluruh widget.
void main() {
  runApp(const ProviderScope(child: StatsApp()));
}

// Widget root yang menentukan tema dan halaman pertama aplikasi.
class StatsApp extends StatelessWidget {
  const StatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Prompt Challenge',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const StatsPage(),
    );
  }
}
