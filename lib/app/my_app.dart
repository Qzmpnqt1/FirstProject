import 'package:flutter/material.dart';
import 'app_state.dart';
import 'app_colors.dart';
import 'app_router.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppState state = AppState();
  late final AppRouter _router = AppRouter(state);

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
        elevation: 2,
        foregroundColor: Colors.white,
        centerTitle: true,
        titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.textPrimary,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        margin: EdgeInsets.all(16),
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: AppColors.textSecondary, fontSize: 16),
        titleLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 22),
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
      title: 'Практическая №7 (Маршруты). Амерханов К.А. ИКБО-11-22',
      theme: light,
      darkTheme: dark,
      themeMode: state.themeDark.value ? ThemeMode.dark : ThemeMode.light,
      routerConfig: _router.router,
    );
  }
}
