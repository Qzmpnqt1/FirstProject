import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../app/app_state.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Аналитика прогресса'),
      ),
      body: SafeArea(
        child: BlocBuilder<AppCubit, AppState>(
          builder: (_, state) {
            final modules = state.modulesEx;
            final tasks = state.tasks;
            final sessions = state.sessions;

            final totalTopics = modules.fold<int>(0, (sum, m) => sum + m.topics.length + m.practices.length);
            final completedTopics = modules.fold<int>(
              0,
              (sum, m) =>
                  sum + m.topics.where((t) => t.done).length + m.practices.where((t) => t.done).length,
            );
            final moduleProgress = totalTopics == 0 ? 0.0 : completedTopics / totalTopics;

            final doneTasks = tasks.where((t) => t.done).length;
            final taskProgress = tasks.isEmpty ? 0.0 : doneTasks / tasks.length;

            final completedSessions = sessions.where((s) => s.completed).length;
            final upcomingSessions = sessions.where((s) => !s.completed).length;

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
              children: [
              _AnalyticsCard(
                title: 'Продвижение по модулям',
                value: '${(moduleProgress * 100).toStringAsFixed(0)}%',
                description: 'Завершено $completedTopics из $totalTopics тем и практик',
                progress: moduleProgress,
              ),
              _AnalyticsCard(
                title: 'Задачи и чек-листы',
                value: tasks.isEmpty ? '0%' : '${(taskProgress * 100).toStringAsFixed(0)}%',
                description: tasks.isEmpty
                    ? 'Добавьте задачи для планирования'
                    : 'Выполнено $doneTasks из ${tasks.length}',
                progress: taskProgress,
                color: Colors.teal,
              ),
              _AnalyticsCard(
                title: 'Расписание',
                value: '$completedSessions выполнено',
                description: '$upcomingSessions предстоящих встреч',
                progress: sessions.isEmpty ? 0 : completedSessions / sessions.length,
                color: Colors.deepOrange,
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.lightbulb_outline_rounded),
                  title: const Text('Рекомендации'),
                  subtitle: Text(_buildRecommendations(tasks.isEmpty, upcomingSessions)),
                ),
              ),
            ],
            );
          },
        ),
      ),
    );
  }

  String _buildRecommendations(bool hasTasks, int upcomingSessions) {
    if (!hasTasks && upcomingSessions == 0) {
      return 'Создайте план задач и учебных встреч, чтобы контролировать прогресс.';
    }
    if (!hasTasks) {
      return 'Составьте чек-лист задач для ближайших модулей.';
    }
    if (upcomingSessions == 0) {
      return 'Запланируйте следующую учебную сессию, чтобы не выпадать из графика.';
    }
    return 'Продолжайте в том же духе и завершите текущие активные задачи.';
  }
}

class _AnalyticsCard extends StatelessWidget {
  final String title;
  final String value;
  final String description;
  final double progress;
  final Color color;

  const _AnalyticsCard({
    required this.title,
    required this.value,
    required this.description,
    required this.progress,
    this.color = Colors.indigo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: color)),
            const SizedBox(height: 4),
            Text(description),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress.clamp(0, 1),
              backgroundColor: color.withOpacity(0.15),
              color: color,
              minHeight: 8,
            ),
          ],
        ),
      ),
    );
  }
}

