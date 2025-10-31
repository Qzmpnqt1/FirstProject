import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_state.dart';

// Экраны
import '../screens/router_root_tabs.dart';
import '../screens/lists/lists_showcase_screen.dart';
import '../screens/modules/module_details_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';

/// Конфигурация go_router для всего приложения.
/// Здесь же прокидываем ссылку на AppState.
class AppRouter {
  final AppState state;

  AppRouter(this.state);

  late final GoRouter router = GoRouter(
    initialLocation: '/',
    // слушаем изменения авторизации — триггерим redirect
    refreshListenable: state.user,
    redirect: (context, s) {
      final loggedIn = state.user.value != null;
      final goingAuth = (s.fullPath ?? '').startsWith('/auth/');
      if (!loggedIn && !goingAuth) return '/auth/login';
      if (loggedIn && goingAuth) return '/';
      return null;
    },
    routes: <RouteBase>[
      // --- AUTH ---
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

      // --- ROOT (горизонтальные вкладки снизу, без кнопки "назад") ---
      GoRoute(
        path: '/',
        name: 'root',
        builder: (context, _) => RouterRootTabs(state: state),
      ),

      // --- Вертикальные переходы ---
      GoRoute(
        path: '/lists',
        name: 'lists',
        builder: (context, _) => ListsShowcaseScreen(state: state),
      ),
      GoRoute(
        path: '/modules/:id',
        name: 'module_details',
        builder: (context, s) {
          final id = s.pathParameters['id']!;
          return ModuleDetailsScreen(state: state, moduleId: id);
        },
      ),
    ],
  );
}
