// lib/app/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_state.dart';
import '../screens/home_page.dart';
import '../screens/profile_page.dart';
import '../screens/counter_page.dart';
import '../screens/settings_page.dart';
import '../screens/about_page.dart';
import '../screens/modules/module_details_screen.dart';
import '../screens/modules/modules_screen.dart';
import '../screens/lists/lists_showcase_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';

/// Пути приложения
class AppPaths {
  static const login = '/login';
  static const register = '/login/register';

  static const home = '/home';
  static const modules = '/modules';
  static String module(String id) => '/module/$id';

  static const profile = '/profile';
  static const counter = '/counter';
  static const settings = '/settings';
  static const about = '/about';

  static const listsShowcase = '/lists';
}

/// Общий AppBar с «горизонтальным» переходом между разделами через pushReplacement
class AppTopNav extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final AppState state;
  const AppTopNav({super.key, required this.title, required this.state});

  void _go(BuildContext context, String route) {
    context.pushReplacement(route);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        PopupMenuButton<String>(
          tooltip: 'Разделы',
          onSelected: (v) => _go(context, v),
          itemBuilder: (_) => const [
            PopupMenuItem(value: AppPaths.home, child: Text('Главная')),
            PopupMenuItem(value: AppPaths.modules, child: Text('Модули')),
            PopupMenuItem(value: AppPaths.profile, child: Text('Профиль')),
            PopupMenuItem(value: AppPaths.counter, child: Text('Счётчик')),
            PopupMenuItem(value: AppPaths.settings, child: Text('Настройки')),
            PopupMenuItem(value: AppPaths.about, child: Text('О приложении')),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Скелет страницы с единым AppBar и градиентным фоном
class MainScaffold extends StatelessWidget {
  final String title;
  final AppState state;
  final Widget body;
  const MainScaffold({
    super.key,
    required this.title,
    required this.state,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopNav(title: title, state: state),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE6FFFB), Color(0xFFF8FAFC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(child: body),
      ),
    );
  }
}

/// Конфигурация маршрутизатора
class AppRouter {
  final AppState state;
  late final GoRouter router;

  AppRouter(this.state) {
    router = GoRouter(
      initialLocation: AppPaths.home,
      refreshListenable: state.user,
      redirect: (context, s) {
        final authed = state.user.value != null;
        final onAuth = s.fullPath == AppPaths.login || s.fullPath == AppPaths.register;

        if (!authed && !onAuth) return AppPaths.login;
        if (authed && onAuth) return AppPaths.home;
        return null;
      },
      routes: [
        // --- Auth ---
        GoRoute(
          path: AppPaths.login,
          builder: (_, __) => LoginScreen(state: state),
        ),
        GoRoute(
          path: AppPaths.register,
          builder: (_, __) => RegisterScreen(state: state),
        ),

        // --- Горизонтальные разделы ---
        GoRoute(
          path: AppPaths.home,
          builder: (_, __) => MainScaffold(
            title: 'Главная',
            state: state,
            body: HomePage(state: state),
          ),
        ),
        GoRoute(
          path: AppPaths.modules,
          builder: (_, __) => MainScaffold(
            title: 'Учебные модули',
            state: state,
            body: ModulesScreenBody(state: state),
          ),
        ),
        GoRoute(
          path: AppPaths.profile,
          builder: (_, __) => MainScaffold(
            title: 'Профиль',
            state: state,
            body: ProfilePage(state: state),
          ),
        ),
        GoRoute(
          path: AppPaths.counter,
          builder: (_, __) => MainScaffold(
            title: 'Счётчик',
            state: state,
            body: Center(child: CounterPage(state: state)),
          ),
        ),
        GoRoute(
          path: AppPaths.settings,
          builder: (_, __) => MainScaffold(
            title: 'Настройки',
            state: state,
            body: SettingsPage(state: state),
          ),
        ),
        GoRoute(
          path: AppPaths.about,
          builder: (_, __) => MainScaffold(
            title: 'О приложении',
            state: state,
            body: AboutPage(state: state),
          ),
        ),

        // --- Вертикальная навигация ---
        GoRoute(
          path: '/module/:id',
          builder: (context, s) => ModuleDetailsScreen(
            state: state,
            moduleId: s.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: AppPaths.listsShowcase,
          builder: (_, __) => Scaffold(
            appBar: AppTopNav(title: 'Списки (витрина)', state: state),
            body: ListsShowcaseScreen(state: state),
          ),
        ),
      ],
    );
  }
}
