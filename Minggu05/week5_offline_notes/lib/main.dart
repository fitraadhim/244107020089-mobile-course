import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pages/notes_page.dart';
import 'pages/settings_page.dart';
import 'providers.dart';

void main() {
  runApp(const ProviderScope(child: OfflineNotesApp()));
}

class OfflineNotesApp extends ConsumerWidget {
  const OfflineNotesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkMode = ref.watch(darkModeProvider).value ?? false;
    return MaterialApp(
      title: 'Offline Notes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      home: const NotesPage(),
      routes: {'/settings': (_) => const SettingsPage()},
    );
  }
}
