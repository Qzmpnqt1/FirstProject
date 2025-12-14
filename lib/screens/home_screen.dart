import 'package:flutter/material.dart';
import 'analytics_page.dart';
import 'home_page.dart';
import 'modules/modules_screen.dart';
import 'profile_page.dart';
import 'schedule_page.dart';
import 'settings_page.dart';
import 'tasks_page.dart';
import '../app/network_provider.dart';
import '../presentation/screens/catalog/catalog_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final networkContainer = NetworkProvider.of(context);
    
    final pages = [
      const HomePage(),
      const TasksPage(),
      const ModulesScreen(),
      const SchedulePage(),
      const AnalyticsPage(),
      const ProfilePage(),
      const SettingsPage(),
      if (networkContainer != null)
        CatalogPage(
          searchTopicsUseCase: networkContainer.searchTopicsUseCase,
          getTopicDetailUseCase: networkContainer.getTopicDetailUseCase,
          getTopicWorksUseCase: networkContainer.getTopicWorksUseCase,
          searchBooksUseCase: networkContainer.searchBooksUseCase,
          getBookDetailUseCase: networkContainer.getBookDetailUseCase,
        )
      else
        const Scaffold(
          body: Center(
            child: Text('Сетевой слой не инициализирован'),
          ),
        ),
    ];

    return Scaffold(
      body: SafeArea(child: IndexedStack(index: _index, children: pages)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_rounded), label: 'Дашборд'),
          NavigationDestination(icon: Icon(Icons.checklist_rounded), label: 'Задачи'),
          NavigationDestination(icon: Icon(Icons.school_rounded), label: 'Модули'),
          NavigationDestination(icon: Icon(Icons.event_available_rounded), label: 'Расписание'),
          NavigationDestination(icon: Icon(Icons.analytics_rounded), label: 'Аналитика'),
          NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Профиль'),
          NavigationDestination(icon: Icon(Icons.settings_rounded), label: 'Настройки'),
          NavigationDestination(icon: Icon(Icons.library_books_rounded), label: 'Каталог'),
        ],
      ),
    );
  }
}
