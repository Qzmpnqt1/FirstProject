import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_state.dart';
import 'app_colors.dart';
import 'app_router.dart';

class MyAppGoRouter extends StatefulWidget {
  const MyAppGoRouter({super.key});

  @override
  State<MyAppGoRouter> createState() => _MyAppGoRouterState();
}

class _MyAppGoRouterState extends State<MyAppGoRouter> {
  final AppState state = AppState();
  late final AppRouter _appRouter = AppRouter(state);
  late final GoRouter _router = _appRouter.router;

  @override
  void initState() {
    super.initState();
    state.themeDark.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final light = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        background: AppColors.surface,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        margin: EdgeInsets.all(16),
      ),
    );

    final dark = ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary, brightness: Brightness.dark),
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        margin: EdgeInsets.all(16),
      ),
    );

    return MaterialApp.router(
      title: 'Практическая №7 — маршрутная навигация (go_router)',
      theme: light,
      darkTheme: dark,
      themeMode: state.themeDark.value ? ThemeMode.dark : ThemeMode.light,
      routerConfig: _router, // <-- всё, больше ничего не нужно
    );
  }
}
