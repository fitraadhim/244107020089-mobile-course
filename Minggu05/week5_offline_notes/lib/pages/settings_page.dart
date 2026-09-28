import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkMode = ref.watch(darkModeProvider).value ?? false;
    final forceOffline = ref.watch(forceOfflineProvider).value ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark mode'),
            value: darkMode,
            onChanged: (_) => ref.read(darkModeProvider.notifier).toggle(),
          ),
          SwitchListTile(
            title: const Text('Force offline'),
            subtitle: const Text('Gunakan cache dan jangan akses jaringan'),
            value: forceOffline,
            onChanged: (value) => ref
                .read(forceOfflineProvider.notifier)
                .setEnabled(value),
          ),
        ],
      ),
    );
  }
}