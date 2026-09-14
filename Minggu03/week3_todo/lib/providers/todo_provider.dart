import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class Todo {
  Todo(this.title, {this.done = false});

  final String title;
  final bool done;

  Todo copyWith({String? title, bool? done}) =>
      Todo(title ?? this.title, done: done ?? this.done);
}

class TodoListNotifier extends Notifier<List<Todo>> {
  @override
  List<Todo> build() => [
        Todo('Belajar Riverpod'),
        Todo('Mencoba GoRouter'),
        Todo('Menulis unit test', done: true),
      ];

  void add(String title) => state = [...state, Todo(title)];

  void toggle(int index) {
    final todos = [...state];
    todos[index] = todos[index].copyWith(done: !todos[index].done);
    state = todos;
  }

  void remove(int index) {
    final todos = [...state]..removeAt(index);
    state = todos;
  }
}

final todoListProvider =
    NotifierProvider<TodoListNotifier, List<Todo>>(TodoListNotifier.new);

final incompleteTodosProvider = Provider<List<Todo>>((ref) {
  final todos = ref.watch(todoListProvider);
  return todos.where((todo) => !todo.done).toList(growable: false);
});

class StatsNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    await Future.delayed(const Duration(seconds: 2));

    if (Random().nextDouble() < 0.3) {
      throw Exception('Gagal mengambil statistik');
    }

    final todos = ref.read(todoListProvider);
    final incompleteTodos = ref.read(incompleteTodosProvider);
    final completedCount = todos.where((todo) => todo.done).length;

    return [
      'Total tugas: ${todos.length}',
      'Belum selesai: ${incompleteTodos.length}',
      'Selesai: $completedCount',
    ];
  }
}

final statsProvider =
    AsyncNotifierProvider<StatsNotifier, List<String>>(StatsNotifier.new);
