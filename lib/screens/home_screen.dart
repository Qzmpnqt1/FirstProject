import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'analytics_page.dart';
import 'home_page.dart';
import 'modules/modules_screen.dart';
import 'profile_page.dart';
import 'schedule_page.dart';
import 'settings_page.dart';
import 'tasks_page.dart';
import 'about_page.dart';
import '../app/app_colors.dart';
import '../presentation/bloc/app_cubit.dart';
import '../presentation/bloc/app_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomePage(),
      const TasksPage(),
      const ModulesScreen(),
      const SchedulePage(),
      const AnalyticsPage(),
      const ProfilePage(),
      const SettingsPage(),
    ];

    return Scaffold(
      drawer: _buildDrawer(context),
      body: SafeArea(
        child: IndexedStack(
          index: _index,
          children: pages,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) {
          setState(() => _index = i);
        },
        animationDuration: const Duration(milliseconds: 300),
        height: 70,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Дашборд',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            selectedIcon: Icon(Icons.checklist_rounded),
            label: 'Задачи',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school_rounded),
            label: 'Модули',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event_available_rounded),
            label: 'Расписание',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics_rounded),
            label: 'Аналитика',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Профиль',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Настройки',
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: const Icon(Icons.person_rounded, size: 32, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.settings.name.isEmpty ? 'Пользователь' : state.settings.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (state.settings.role.isNotEmpty)
                      Text(
                        state.settings.role,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person_rounded, color: AppColors.primary),
                title: const Text('Профиль'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _index = 5);
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_rounded, color: AppColors.primary),
                title: const Text('Настройки'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _index = 6);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.info_outline_rounded, color: AppColors.primary),
                title: const Text('О приложении'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AboutPage()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
