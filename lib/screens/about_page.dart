import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../app/app_colors.dart';
import '../app/app_state.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  static const String _version = '1.0.0';
  int _taps = 0;

  static const _aboutUrl =
      'https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4c4.png';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await precacheImage(CachedNetworkImageProvider(_aboutUrl), context);
      } catch (_) {}
    });
  }

  Future<void> _copyVersion() async {
    await Clipboard.setData(const ClipboardData(text: _version));
    if (!mounted) return;
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
          content: const Text('Молодец! Ты нашёл пасхалку. Удачи на защите!'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Ок')),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('О приложении')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          children: [
          Card(
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CachedNetworkImage(
                    imageUrl: _aboutUrl,
                    fit: BoxFit.contain,
                    placeholder: (_, __) => Container(color: const Color(0xFFE2E8F0)),
                    errorWidget: (_, __, ___) => const Icon(Icons.apps_rounded, color: AppColors.primary),
                  ),
                ),
              ),
              title: const Text('Практическая работа №3'),
              subtitle: const Text('Демонстрация Stateless/Stateful виджетов и смены контента'),
              onTap: _easterEggTap,
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.person_outline_rounded, color: AppColors.primary),
              title: BlocBuilder<AppCubit, AppState>(
                buildWhen: (previous, current) =>
                    previous.name != current.name || previous.role != current.role,
                builder: (_, state) => Text('${state.name} — ${state.role}'),
              ),
              subtitle: const Text('Данные берутся из экрана «Профиль»'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.checklist_rounded, color: AppColors.primary),
              title: BlocSelector<AppCubit, AppState, MapEntry<int, int>>(
                selector: (state) {
                  final done = state.tasks.where((t) => t.done).length;
                  return MapEntry(state.tasks.length, done);
                },
                builder: (_, stats) => Text('Задач: ${stats.key}, выполнено: ${stats.value}'),
              ),
              subtitle: const Text('Статистика синхронизирована с «Главной»'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.timer_rounded, color: AppColors.primary),
              title: BlocSelector<AppCubit, AppState, int>(
                selector: (state) => state.counter,
                builder: (_, value) => Text('Счётчик: $value'),
              ),
              subtitle: const Text('Общее значение из вкладки «Счётчик»'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline_rounded, color: AppColors.primary),
              title: const Text('Версия'),
              subtitle: Text(_version),
              trailing: OutlinedButton(
                onPressed: _copyVersion,
                child: const Text('Скопировать'),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}
