import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/datasources/data_source_interface.dart';
import 'app_colors.dart';
import '../data/datasources/storage_strategy.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/modules_repository_impl.dart';
import '../data/repositories/sessions_repository_impl.dart';
import '../data/repositories/settings_repository_impl.dart';
import '../data/repositories/tasks_repository_impl.dart';
import '../presentation/bloc/app_cubit.dart';
import '../presentation/bloc/app_state.dart';
import 'auth_gate.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DataSourceInterface? _dataSource;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeDataSource();
  }

  Future<void> _initializeDataSource() async {
    // Можно выбрать тип хранилища через настройки или параметры
    final strategy = StorageStrategy(StorageStrategy.getDefaultType());
    final dataSource = await strategy.getDataSource();
    setState(() {
      _dataSource = dataSource;
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized || _dataSource == null) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    // Инициализация зависимостей
    final tasksRepository = TasksRepositoryImpl(_dataSource!);
    final modulesRepository = ModulesRepositoryImpl(_dataSource!);
    final sessionsRepository = SessionsRepositoryImpl(_dataSource!);
    final authRepository = AuthRepositoryImpl(_dataSource!);
    final settingsRepository = SettingsRepositoryImpl(_dataSource!);

    return BlocProvider(
      create: (_) => AppCubit(
        tasksRepository: tasksRepository,
        modulesRepository: modulesRepository,
        sessionsRepository: sessionsRepository,
        authRepository: authRepository,
        settingsRepository: settingsRepository,
      ),
      child: const _AppView(),
    );
  }
}

class _AppView extends StatelessWidget {
  const _AppView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      buildWhen: (previous, current) => previous.settings.themeDark != current.settings.themeDark,
      builder: (context, state) {
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
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: AppColors.navBg,
            selectedItemColor: AppColors.accent,
            unselectedItemColor: AppColors.navUnselected,
            selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            elevation: 8,
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
            titleLarge: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700),
          ),
        );

        final dark = ThemeData(
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary, brightness: Brightness.dark),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color(0xFF0E1A18),
            selectedItemColor: AppColors.accent,
            unselectedItemColor: AppColors.navUnselected,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            elevation: 8,
          ),
          cardTheme: const CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
            margin: EdgeInsets.all(16),
          ),
        );

        return MaterialApp(
          title: 'Практическая работа №6. Амерханов К.А. ИКБО-11-22',
          theme: light,
          darkTheme: dark,
          themeMode: state.settings.themeDark ? ThemeMode.dark : ThemeMode.light,
          home: const AuthGate(),
        );
      },
    );
  }
}
