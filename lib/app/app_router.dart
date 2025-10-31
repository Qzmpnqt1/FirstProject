import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_state.dart';

// Экраны верхнего уровня (ветви)
import '../screens/home_page.dart';
import '../screens/modules/modules_screen.dart';
import '../screens/profile_page.dart';
import '../screens/counter_page.dart';
import '../screens/settings_page.dart';

// Вертикальные экраны
import '../screens/lists/lists_showcase_screen.dart';
import '../screens/modules/module_details_screen.dart';

// Auth
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';

/// Конфигурация маршрутов для ВСЕГО приложения на go_router
class AppRouter {
  final AppState state;

  AppRouter(this.state);

  // Навигаторы для независимых стеков каждой вкладки
  final _homeKey = GlobalKey<NavigatorState>(debugLabel: 'homeNav');
  final _modulesKey = GlobalKey<NavigatorState>(debugLabel: 'modulesNav');
  final _profileKey = GlobalKey<NavigatorState>(debugLabel: 'profileNav');
  final _counterKey = GlobalKey<NavigatorState>(debugLabel: 'counterNav');
  final _settingsKey = GlobalKey<NavigatorState>(debugLabel: 'settingsNav');

  // Корневой навигатор (для модалок вне веток, если понадобятся)
  final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'rootNav');

  late final GoRouter router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/home',
    // слушаем авторизацию
    refreshListenable: state.user,
    redirect: (context, s) {
      final loggedIn = state.user.value != null;
      final goingAuth = (s.fullPath ?? '').startsWith('/auth/');
      if (!loggedIn && !goingAuth) return '/auth/login';
      if (loggedIn && goingAuth) return '/home';
      return null;
    },
    routes: [
      // ===== AUTH =====
      GoRoute(
        path: '/auth/login',
        name: 'login',
        builder: (context, _) => LoginScreen(state: state),
      ),
      GoRoute(
        path: '/auth/register',
        name: 'register',
        builder: (context, _) => RegisterScreen(state: state),
      ),

      // ===== ГОРИЗОНТАЛЬ: 5 ветвей через StatefulShellRoute =====
      StatefulShellRoute.indexedStack(
        builder: (context, stateMatch, navigationShell) =>
            _RootShell(state: state, shell: navigationShell),
        branches: [
          // --- Главная
          StatefulShellBranch(
            navigatorKey: _homeKey,
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, _) => HomePage(state: state),
                routes: [
                  // вертикальный переход из Главной
                  GoRoute(
                    path: 'lists',
                    name: 'lists',
                    builder: (context, _) => ListsShowcaseScreen(state: state),
                  ),
                ],
              ),
            ],
          ),

          // --- Модули
          StatefulShellBranch(
            navigatorKey: _modulesKey,
            routes: [
              GoRoute(
                path: '/modules',
                name: 'modules',
                builder: (context, _) => ModulesScreen(state: state),
                routes: [
                  GoRoute(
                    path: ':id',
                    name: 'module_details',
                    builder: (context, s) {
                      final id = s.pathParameters['id']!;
                      return ModuleDetailsScreen(state: state, moduleId: id);
                    },
                  ),
                ],
              ),
            ],
          ),

          // --- Профиль
          StatefulShellBranch(
            navigatorKey: _profileKey,
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, _) => ProfilePage(state: state),
              ),
            ],
          ),

          // --- Счётчик
          StatefulShellBranch(
            navigatorKey: _counterKey,
            routes: [
              GoRoute(
                path: '/counter',
                name: 'counter',
                builder: (context, _) => CounterPage(state: state),
              ),
            ],
          ),

          // --- Настройки
          StatefulShellBranch(
            navigatorKey: _settingsKey,
            routes: [
              GoRoute(
                path: '/settings',
                name: 'settings',
                builder: (context, _) => SettingsPage(state: state),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// Корневой Scaffold для горизонтальной навигации через go_router shell
class _RootShell extends StatelessWidget {
  final AppState state;
  final StatefulNavigationShell shell;

  const _RootShell({super.key, required this.state, required this.shell});

  String _titleFor(int i) => switch (i) {
    0 => 'Главная',
    1 => 'Модули',
    2 => 'Профиль',
    3 => 'Счётчик',
    _ => 'Настройки',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titleFor(shell.currentIndex))),
      body: shell, // содержимое текущей ветви
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (index) {
          // Переход по ветви без кнопки "назад"
          shell.goBranch(index, initialLocation: true);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Главная'),
          NavigationDestination(icon: Icon(Icons.school_rounded), label: 'Модули'),
          NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Профиль'),
          NavigationDestination(icon: Icon(Icons.add_circle_rounded), label: 'Счётчик'),
          NavigationDestination(icon: Icon(Icons.settings_rounded), label: 'Настройки'),
        ],
      ),
    );
  }
}
