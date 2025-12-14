import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../app/app_colors.dart';
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
                      return _EmptyState(
                        icon: Icons.task_alt_rounded,
                        title: query.isEmpty ? 'Нет задач' : 'Ничего не найдено',
                        subtitle: query.isEmpty
                            ? 'Добавьте первую задачу, чтобы начать планирование'
                            : 'Попробуйте изменить поисковый запрос',
                      );
                    }
                    return ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final task = filtered[i];
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: Duration(milliseconds: 300 + (i * 50)),
                          curve: Curves.easeOut,
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(20 * (1 - value), 0),
                              child: Opacity(
                                opacity: value,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: TaskTile(
                                    task: task,
                                    onToggle: (value) {
                                      context.read<AppCubit>().toggleTask(task.id, value);
                                    },
                                    onDelete: () {
                                      context.read<AppCubit>().deleteTask(task.id);
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
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

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppColors.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

