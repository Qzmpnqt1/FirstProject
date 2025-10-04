import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app/app_state.dart';
import '../app/app_colors.dart';
import '../data/task.dart';
import '../widgets/multi_listenable_builder.dart';

class AboutPage extends StatefulWidget {
  final AppState state;
  const AboutPage({super.key, required this.state});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  static const String _version = '1.0.0';
  int _taps = 0;

  void _copyVersion() async {
    await Clipboard.setData(const ClipboardData(text: _version));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Версия скопирована в буфер обмена')),
    );
  }

  void _easterEggTap() {
    setState(() => _taps++);
    if (_taps >= 7) {
      _taps = 0;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('🎉 Пасхалка'),
          content:
          const Text('Молодец! Ты нашёл пасхалку. Удачи на защите!'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Ок')),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.apps_rounded, color: AppColors.primary),
            title: const Text('Практическая работа №3'),
            subtitle: const Text(
                'Демонстрация Stateless/Stateful виджетов и смены контента'),
          ),
        ),
        Card(
          child: ListTile(
            leading:
            const Icon(Icons.person_outline_rounded, color: AppColors.primary),
            title: ValueListenableBuilder2<String, String>(
              listenableA: widget.state.name,
              listenableB: widget.state.role,
              builder: (_, name, role, __) => Text('$name — $role'),
            ),
            subtitle: const Text('Данные берутся из экрана «Профиль»'),
          ),
        ),
        Card(
          child: ListTile(
            leading:
            const Icon(Icons.checklist_rounded, color: AppColors.primary),
            title: ValueListenableBuilder<List<Task>>(
              valueListenable: widget.state.tasks,
              builder: (_, tasks, __) {
                final done = tasks.where((t) => t.done).length;
                return Text('Задач: ${tasks.length}, выполнено: $done');
              },
            ),
            subtitle: const Text('Статистика синхронизирована с «Главной»'),
          ),
        ),
        Card(
          child: ListTile(
            leading:
            const Icon(Icons.timer_rounded, color: AppColors.primary),
            title: ValueListenableBuilder<int>(
              valueListenable: widget.state.counter,
              builder: (_, v, __) => Text('Счётчик: $v'),
            ),
            subtitle: const Text('Общее значение из вкладки «Счётчик»'),
          ),
        ),
        Card(
          child: ListTile(
            leading:
            const Icon(Icons.info_outline_rounded, color: AppColors.primary),
            title: const Text('Версия'),
            subtitle: Text(_version),
            onTap: _easterEggTap,
            trailing: OutlinedButton(
              onPressed: _copyVersion,
              child: const Text('Скопировать'),
            ),
          ),
        ),
      ],
    );
  }
}