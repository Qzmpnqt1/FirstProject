import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../app/app_colors.dart';
import '../domain/entities/module_entity.dart';
import '../presentation/bloc/app_cubit.dart';
import '../presentation/bloc/app_state.dart';

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

            // Статистика по оценкам
            final modulesWithGrades = modules.where((m) => m.grade != null).toList();
            final averageGrade = modulesWithGrades.isEmpty
                ? 0.0
                : modulesWithGrades.map((m) => m.grade!).reduce((a, b) => a + b) / modulesWithGrades.length;

            // Просроченные модули
            final overdueModules = modules.where((m) => m.isOverdue).length;

            // Модули по приоритету
            final urgentModules = modules.where((m) => m.priority == ModulePriority.urgent).length;
            final highPriorityModules = modules.where((m) => m.priority == ModulePriority.high).length;

            return RefreshIndicator(
              onRefresh: () async {
                // Перезагрузка данных через cubit
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
                children: [
                  _AnalyticsCard(
                    title: 'Продвижение по модулям',
                    value: '${(moduleProgress * 100).toStringAsFixed(0)}%',
                    description: 'Завершено $completedTopics из $totalTopics тем и практик',
                    progress: moduleProgress,
                    icon: Icons.school_rounded,
                  ),
                  _AnalyticsCard(
                    title: 'Задачи и чек-листы',
                    value: tasks.isEmpty ? '0%' : '${(taskProgress * 100).toStringAsFixed(0)}%',
                    description: tasks.isEmpty
                        ? 'Добавьте задачи для планирования'
                        : 'Выполнено $doneTasks из ${tasks.length}',
                    progress: taskProgress,
                    color: Colors.teal,
                    icon: Icons.checklist_rounded,
                  ),
                  _AnalyticsCard(
                    title: 'Расписание',
                    value: '$completedSessions выполнено',
                    description: '$upcomingSessions предстоящих встреч',
                    progress: sessions.isEmpty ? 0 : completedSessions / sessions.length,
                    color: Colors.deepOrange,
                    icon: Icons.event_available_rounded,
                  ),
                  if (modules.isNotEmpty) _ModulesBreakdown(modules: modules),
                  if (modulesWithGrades.isNotEmpty)
                    _AnalyticsCard(
                      title: 'Средняя оценка',
                      value: '${averageGrade.toStringAsFixed(1)}%',
                      description: 'Оценено ${modulesWithGrades.length} из ${modules.length} модулей',
                      progress: averageGrade / 100,
                      color: Colors.green,
                      icon: Icons.grade_rounded,
                    ),
                  if (overdueModules > 0)
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      color: Colors.red.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.warning_rounded, color: Colors.red.shade700, size: 32),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Просрочено модулей: $overdueModules',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Требуется срочное внимание',
                                    style: TextStyle(color: Colors.red.shade600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (urgentModules > 0 || highPriorityModules > 0)
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.flag_rounded, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Text(
                                  'Приоритетные модули',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (urgentModules > 0)
                              _PriorityStat(
                                label: 'Срочные',
                                count: urgentModules,
                                color: Colors.red,
                              ),
                            if (highPriorityModules > 0) ...[
                              const SizedBox(height: 8),
                              _PriorityStat(
                                label: 'Высокий приоритет',
                                count: highPriorityModules,
                                color: Colors.orange,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.lightbulb_outline_rounded, color: AppColors.accent),
                              const SizedBox(width: 8),
                              Text(
                                'Рекомендации',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _buildRecommendations(tasks.isEmpty, upcomingSessions, overdueModules),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _buildRecommendations(bool hasTasks, int upcomingSessions, int overdueModules) {
    if (overdueModules > 0) {
      return 'У вас есть $overdueModules просроченных модулей. Рекомендуется начать с них.';
    }
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
  final IconData icon;

  const _AnalyticsCard({
    required this.title,
    required this.value,
    required this.description,
    required this.progress,
    required this.icon,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress.clamp(0, 1),
                backgroundColor: color.withOpacity(0.15),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${(progress * 100).toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModulesBreakdown extends StatelessWidget {
  final List<ModuleEntity> modules;

  const _ModulesBreakdown({required this.modules});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pie_chart_rounded, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Прогресс по модулям',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...modules.take(5).map((module) {
              final progress = module.progress;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            module.title,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${(progress * 100).toStringAsFixed(0)}%',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0, 1),
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class _PriorityStat extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _PriorityStat({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const Spacer(),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

