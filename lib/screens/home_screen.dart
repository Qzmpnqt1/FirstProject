import 'package:flutter/material.dart';
import '../app/app_state.dart';
import '../app/app_colors.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'counter_page.dart';
import 'settings_page.dart';
import 'about_page.dart';
import '../data/task.dart';
import '../data/auth_user.dart'; // добавлено
import 'modules/modules_screen.dart'; // добавлено

class HomeScreen extends StatefulWidget {
  final AppState state;
  const HomeScreen({super.key, required this.state});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  String _titleFor(int i) => switch (i) {
    0 => 'Главная',
    1 => 'Модули',
    2 => 'Профиль',
    3 => 'Счётчик',
    4 => 'Настройки',
    _ => 'О приложении',
  };

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(state: widget.state),
      ModulesScreen(state: widget.state), // новая страница
      ProfilePage(state: widget.state),
      CounterPage(state: widget.state),
      SettingsPage(state: widget.state),
      AboutPage(state: widget.state),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titleFor(_index)),
        actions: [
          // показ текущего пользователя
          ValueListenableBuilder<AuthUser?>(
            valueListenable: widget.state.user,
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
          // статистика задач
          ValueListenableBuilder<List<Task>>(
            valueListenable: widget.state.tasks,
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
        child: SafeArea(
          child: IndexedStack(index: _index, children: pages),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Главная"),
          BottomNavigationBarItem(icon: Icon(Icons.school_rounded), label: "Модули"),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: "Профиль"),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_rounded), label: "Счётчик"),
          BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: "Настройки"),
          BottomNavigationBarItem(icon: Icon(Icons.info_rounded), label: "О приложении"),
        ],
      ),
    );
  }
}
