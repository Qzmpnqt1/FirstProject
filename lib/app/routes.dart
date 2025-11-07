import 'package:flutter/material.dart';
import 'app_state.dart';

// Экраны
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home_screen.dart';
import '../screens/modules/module_details_screen.dart';

class AppRoutes {
  // Auth
  static const login = '/login';
  static const register = '/register';

  // Горизонтальные разделы
  static const home = '/home';
  static const modules = '/modules';
  static const profile = '/profile';
  static const counter = '/counter';
  static const settings = '/settings';
  static const about = '/about';

  // Вертикальная навигация внутри разделов
  static const moduleDetails = '/modules/details';
}

Route<dynamic> buildRoute(RouteSettings settings, AppState state) {
  switch (settings.name) {
  // === AUTH ===
    case AppRoutes.login:
      return MaterialPageRoute(builder: (_) => LoginScreen(state: state));
    case AppRoutes.register:
      return MaterialPageRoute(builder: (_) => RegisterScreen(state: state));

  // === TOP-LEVEL (горизонтальные) страницы ===
    case AppRoutes.home:
      return MaterialPageRoute(builder: (_) => HomeScreen(state: state, current: TopPage.home));
    case AppRoutes.modules:
      return MaterialPageRoute(builder: (_) => HomeScreen(state: state, current: TopPage.modules));
    case AppRoutes.profile:
      return MaterialPageRoute(builder: (_) => HomeScreen(state: state, current: TopPage.profile));
    case AppRoutes.counter:
      return MaterialPageRoute(builder: (_) => HomeScreen(state: state, current: TopPage.counter));
    case AppRoutes.settings:
      return MaterialPageRoute(builder: (_) => HomeScreen(state: state, current: TopPage.settings));
    case AppRoutes.about:
      return MaterialPageRoute(builder: (_) => HomeScreen(state: state, current: TopPage.about));

  // === Вертикальная навигация ===
    case AppRoutes.moduleDetails: {
      final args = settings.arguments as Map<String, dynamic>;
      final moduleId = args['moduleId'] as String;
      return MaterialPageRoute(
        builder: (_) => ModuleDetailsScreen(state: state, moduleId: moduleId),
      );
    }
  }

  // Fallback
  return MaterialPageRoute(
    builder: (_) => Scaffold(
      body: Center(child: Text('Unknown route: ${settings.name}')),
    ),
  );
}
