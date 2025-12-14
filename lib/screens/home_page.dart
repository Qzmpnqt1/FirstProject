import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../app/app_colors.dart';
import '../presentation/bloc/app_cubit.dart';
import '../presentation/bloc/app_state.dart';
import '../domain/entities/study_session_entity.dart';
import '../domain/entities/module_entity.dart';
import 'lists/lists_showcase_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Дашборд обучения')),
      body: SafeArea(
        child: BlocBuilder<AppCubit, AppState>(
          builder: (context, state) {
            final upcoming = _upcomingSessions(state.sessions);
            final modulesCompleted = state.modulesEx.where((m) => m.progress >= 1).length;
            final tasksDone = state.tasks.where((t) => t.done).length;
            final overdueModules = state.modulesEx.where((m) => m.isOverdue).length;
            final urgentModules = state.modulesEx.where((m) => m.priority == ModulePriority.urgent).length;
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Opacity(opacity: value, child: _HeroCard(counter: state.settings.counter)),
                  );
                },
              ),
              const SizedBox(height: 16),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Opacity(opacity: value, child: _SummaryGrid(
                modulesTotal: state.modulesEx.length,
                modulesCompleted: modulesCompleted,
                tasksTotal: state.tasks.length,
                tasksDone: tasksDone,
                upcomingSessions: upcoming.length,
                    )),
                  );
                },
              ),
              if (overdueModules > 0 || urgentModules > 0) ...[
                const SizedBox(height: 16),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: overdueModules > 0 ? Colors.red.shade50 : Colors.orange.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          overdueModules > 0 ? Icons.warning_rounded : Icons.flag_rounded,
                          color: overdueModules > 0 ? Colors.red.shade700 : Colors.orange.shade700,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                overdueModules > 0
                                    ? 'Просрочено модулей: $overdueModules'
                                    : 'Срочных модулей: $urgentModules',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: overdueModules > 0 ? Colors.red.shade700 : Colors.orange.shade700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                overdueModules > 0
                                    ? 'Требуется срочное внимание'
                                    : 'Высокий приоритет',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: overdueModules > 0 ? Colors.red.shade600 : Colors.orange.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Показать уведомление о переходе к модулям
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Перейдите во вкладку "Модули" для просмотра'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: const Text('Посмотреть'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ListsShowcaseScreen()),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.view_list_rounded, color: AppColors.primary, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Витрина списков',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Три подхода к отображению данных',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.event_available_rounded, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Ближайшие учебные события',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (upcoming.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline_rounded, size: 20, color: AppColors.textSecondary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Нет запланированных занятий. Перейдите во вкладку «Расписание».',
                                  style: TextStyle(color: AppColors.textSecondary),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ...upcoming.take(3).map((session) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.event_note_rounded, size: 20, color: AppColors.primary),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      session.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatSession(context, session),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                    ],
                  ),
                ),
              ),
            ],
            );
          },
        ),
      ),
    );
  }

  List<StudySessionEntity> _upcomingSessions(List<StudySessionEntity> sessions) {
    final now = DateTime.now();
    return sessions
        .where((s) => !s.completed && s.scheduledAt.isAfter(now))
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  String _formatSession(BuildContext context, StudySessionEntity session) {
    final l10n = MaterialLocalizations.of(context);
    final date = l10n.formatMediumDate(session.scheduledAt);
    final time = l10n.formatTimeOfDay(TimeOfDay.fromDateTime(session.scheduledAt), alwaysUse24HourFormat: true);
    return '$date • $time • ${session.moduleTitle}';
  }
}

class _HeroCard extends StatelessWidget {
  final int counter;
  const _HeroCard({required this.counter});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.school_rounded, color: Colors.white, size: 38),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'План обучения под контролем',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                ),
              ),
              Chip(
                label: Text('Фокус: $counter', style: const TextStyle(color: Colors.white)),
                backgroundColor: Colors.black26,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: Colors.white.withOpacity(0.12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: (counter % 10) / 10,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation(AppColors.accent),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  final int modulesTotal;
  final int modulesCompleted;
  final int tasksTotal;
  final int tasksDone;
  final int upcomingSessions;

  const _SummaryGrid({
    required this.modulesTotal,
    required this.modulesCompleted,
    required this.tasksTotal,
    required this.tasksDone,
    required this.upcomingSessions,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int columns = 4;
        if (width < 720) {
          columns = 1;
        } else if (width < 1080) {
          columns = 2;
        }
        final aspectRatio = columns >= 4 ? 3.8 : (columns == 2 ? 2.8 : 4.2);
        return GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: aspectRatio,
          ),
          children: [
            _StatCard(
              icon: Icons.layers_rounded,
              title: 'Модули',
              value: '$modulesCompleted / $modulesTotal',
              subtitle: 'пройдено',
            ),
            _StatCard(
              icon: Icons.check_circle_rounded,
              title: 'Задачи',
              value: tasksTotal == 0 ? '0%' : '${(tasksDone / tasksTotal * 100).toStringAsFixed(0)}%',
              subtitle: '$tasksDone из $tasksTotal',
              color: Colors.teal,
            ),
            _StatCard(
              icon: Icons.event_available_rounded,
              title: 'Расписание',
              value: '$upcomingSessions',
              subtitle: 'встреч впереди',
              color: Colors.deepOrange,
            ),
            _StatCard(
              icon: Icons.show_chart_rounded,
              title: 'Активность',
              value: tasksTotal == 0 ? '--' : '$tasksDone из $tasksTotal',
              subtitle: 'контроль практики',
              color: Colors.purple,
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
