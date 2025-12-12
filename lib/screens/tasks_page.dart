import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../presentation/bloc/app_cubit.dart';
import '../presentation/bloc/app_state.dart';
import '../widgets/task_tile.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final TextEditingController input = TextEditingController();
  final TextEditingController search = TextEditingController();

  @override
  void dispose() {
    input.dispose();
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Задачи и чек-листы'),
        actions: [
          IconButton(
            tooltip: 'Очистить выполненные',
            onPressed: () => context.read<AppCubit>().clearDone(),
            icon: const Icon(Icons.cleaning_services_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Column(
            children: [
              TextField(
                controller: search,
                decoration: const InputDecoration(
                  hintText: 'Поиск по задачам...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: input,
                      decoration: const InputDecoration(
                        hintText: 'Новая задача...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      ),
                      onSubmitted: (_) => _createTask(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _createTask,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Добавить'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<AppCubit, AppState>(
                  buildWhen: (previous, current) => previous.tasks != current.tasks,
                  builder: (_, state) {
                    final tasks = state.tasks;
                    final query = search.text.trim().toLowerCase();
                    final filtered = query.isEmpty
                        ? tasks
                        : tasks.where((t) => t.title.toLowerCase().contains(query)).toList();
                    if (filtered.isEmpty) {
                      return const Center(child: Text('Задач нет. Добавьте первую выше.'));
                    }
                    return ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final task = filtered[i];
                        final sourceIndex = tasks.indexOf(task);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: TaskTile(
                            task: task,
                            onToggle: (value) {
                              if (sourceIndex != -1) {
                                context.read<AppCubit>().toggleTask(sourceIndex, value);
                              }
                            },
                            onDelete: () {
                              if (sourceIndex != -1) {
                                context.read<AppCubit>().deleteTask(sourceIndex);
                              }
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createTask() async {
    final text = input.text.trim();
    if (text.isEmpty) return;
    await context.read<AppCubit>().addTask(text);
    input.clear();
  }
}

