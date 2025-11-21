import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../app/app_colors.dart';
import '../app/app_state.dart';
import '../data/study_session.dart';
import 'lists/lists_showcase_screen.dart';

const _homeBannerUrl =
    'https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4bb.png';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await precacheImage(CachedNetworkImageProvider(_homeBannerUrl), context);
      } catch (_) {}
    });
  }

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
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              children: [
              _HeroCard(counter: state.counter),
              const SizedBox(height: 16),
              _SummaryGrid(
                modulesTotal: state.modulesEx.length,
                modulesCompleted: modulesCompleted,
                tasksTotal: state.tasks.length,
                tasksDone: tasksDone,
                upcomingSessions: upcoming.length,
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.view_list_rounded, color: AppColors.primary),
                  title: const Text('Витрина списков (Column / ListView)'),
                  subtitle: const Text('Три подхода к отображению данных'),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ListsShowcaseScreen()),
                      );
                    },
                    child: const Text('Открыть'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ближайшие учебные события', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      if (upcoming.isEmpty)
                        const Text('Нет запланированных занятий. Перейдите во вкладку «Расписание».')
                      else
                        for (final session in upcoming.take(3))
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.event_note_rounded),
                            title: Text(session.title),
                            subtitle: Text(_formatSession(context, session)),
                          ),
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

  List<StudySession> _upcomingSessions(List<StudySession> sessions) {
    final now = DateTime.now();
    return sessions
        .where((s) => !s.completed && s.scheduledAt.isAfter(now))
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  String _formatSession(BuildContext context, StudySession session) {
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
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 90,
              width: double.infinity,
              child: CachedNetworkImage(
                imageUrl: _homeBannerUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: Colors.white24),
                errorWidget: (_, __, ___) => Container(
                  color: Colors.white24,
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image_rounded, color: Colors.white),
                ),
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
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.4,
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
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withOpacity(0.12),
              child: Icon(icon, color: color),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.labelLarge),
                Text(value, style: Theme.of(context).textTheme.headlineSmall),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
