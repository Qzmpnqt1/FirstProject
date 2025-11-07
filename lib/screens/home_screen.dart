import 'package:flutter/material.dart';
import '../app/app_colors.dart';
import '../app/app_state.dart';
import '../app/routes.dart';
import '../data/task.dart';
import '../data/auth_user.dart';

import 'home_page.dart';
import 'modules/modules_screen.dart';
import 'profile_page.dart';
import 'counter_page.dart';
import 'settings_page.dart';
import 'about_page.dart';

enum TopPage { home, modules, profile, counter, settings, about }

class HomeScreen extends StatelessWidget {
  final AppState state;
  final TopPage current;
  const HomeScreen({super.key, required this.state, required this.current});

  String get _title => switch (current) {
    TopPage.home => 'Главная',
    TopPage.modules => 'Модули',
    TopPage.profile => 'Профиль',
    TopPage.counter => 'Счётчик',
    TopPage.settings => 'Настройки',
    TopPage.about => 'О приложении',
  };

  Widget _page() => switch (current) {
    TopPage.home => HomePage(state: state),
    TopPage.modules => ModulesScreen(state: state),
    TopPage.profile => ProfilePage(state: state),
    TopPage.counter => CounterPage(state: state),
    TopPage.settings => SettingsPage(state: state),
    TopPage.about => AboutPage(state: state),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // ВАЖНО: на верхнем уровне не показываем «Назад»
        automaticallyImplyLeading: false,
        title: Text(_title),
        actions: [
          // Текущий пользователь
          ValueListenableBuilder<AuthUser?>(
            valueListenable: state.user,
            builder: (_, u, __) => u == null
                ? const SizedBox.shrink()
                : Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text(u.fullName),
                backgroundColor: AppColors.accentSoft,
              ),
            ),
          ),
          // Статистика задач
          ValueListenableBuilder<List<Task>>(
            valueListenable: state.tasks,
            builder: (_, tasks, __) {
              final done = tasks.where((t) => t.done).length;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Chip(
                  label: Text('Готово: $done'),
                  backgroundColor: AppColors.accentSoft,
                ),
              );
            },
          ),
          // Меню для горизонтальной навигации (pushReplacementNamed)
          PopupMenuButton<TopPage>(
            onSelected: (p) => _go(context, p),
            itemBuilder: (_) => const [
              PopupMenuItem(value: TopPage.home, child: Text('Главная')),
              PopupMenuItem(value: TopPage.modules, child: Text('Модули')),
              PopupMenuItem(value: TopPage.profile, child: Text('Профиль')),
              PopupMenuItem(value: TopPage.counter, child: Text('Счётчик')),
              PopupMenuItem(value: TopPage.settings, child: Text('Настройки')),
              PopupMenuItem(value: TopPage.about, child: Text('О приложении')),
            ],
            icon: const Icon(Icons.menu_rounded),
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE6FFFB), Color(0xFFF8FAFC)],
          ),
        ),
        child: SafeArea(child: _page()),
      ),
    );
  }

  void _go(BuildContext context, TopPage page) {
    if (page == current) return;
    final routeName = switch (page) {
      TopPage.home => AppRoutes.home,
      TopPage.modules => AppRoutes.modules,
      TopPage.profile => AppRoutes.profile,
      TopPage.counter => AppRoutes.counter,
      TopPage.settings => AppRoutes.settings,
      TopPage.about => AppRoutes.about,
    };
    Navigator.pushReplacementNamed(context, routeName);
  }
}
