import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../app/app_colors.dart';
import '../app/app_state.dart';
import '../data/auth_user.dart';
import '../data/task.dart';
import 'about_page.dart';
import 'counter_page.dart';
import 'home_page.dart';
import 'modules/modules_screen.dart';
import 'profile_page.dart';
import 'settings_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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
    final pages = const [
      HomePage(),
      ModulesScreen(),
      ProfilePage(),
      CounterPage(),
      SettingsPage(),
      AboutPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titleFor(_index)),
        actions: [
          BlocSelector<AppCubit, AppState, AuthUser?>(
            selector: (state) => state.user,
            builder: (_, user) => user == null
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Chip(
                      label: Text(user.fullName),
                      backgroundColor: AppColors.accentSoft,
                    ),
                  ),
          ),
          BlocSelector<AppCubit, AppState, List<Task>>(
            selector: (state) => state.tasks,
            builder: (_, tasks) {
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
