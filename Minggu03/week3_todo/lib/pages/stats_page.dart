import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/todo_provider.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todoListProvider);
    final incompleteTodos = ref.watch(incompleteTodosProvider);
    final completedCount = todos.where((todo) => todo.done).length;
    final stats = [
      'Total tugas: ${todos.length}',
      'Belum selesai: ${incompleteTodos.length}',
      'Selesai: $completedCount',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Statistik ToDo')),
      body: ListView.builder(
        itemCount: stats.length,
        itemBuilder: (context, index) => ListTile(
          leading: const Icon(Icons.insights),
          title: Text(stats[index]),
        ),
      ),
    );
  }
}
