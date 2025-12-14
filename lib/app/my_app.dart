import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_colors.dart';
import '../data/datasources/local_storage_data_source.dart';
import '../data/datasources/secure_store_data_source.dart';
import '../data/datasources/drift_data_source.dart';
import '../data/datasources/hive_data_source.dart';
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
  // Разные хранилища для разных частей приложения
  LocalStorageDataSource? _settingsStorage;
  SecureStoreDataSource? _authStorage;
  DriftDataSource? _tasksStorage;
  DriftDataSource? _sessionsStorage;
  HiveDataSource? _modulesStorage;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeStorages();
  }

  Future<void> _initializeStorages() async {
    // Инициализация всех хранилищ
    await LocalStorageDataSource.init();
    await SecureStoreDataSource.init();
    await HiveDataSource.init();
    
    // Создание экземпляров хранилищ
    final settingsStorage = LocalStorageDataSource();
    final authStorage = SecureStoreDataSource();
    await authStorage.loadCache();
    
    final db = await DriftDataSource.init();
    final tasksStorage = DriftDataSource(db);
    await tasksStorage.loadCache();
    
    // Используем тот же экземпляр Drift для сессий (можно разделить, если нужно)
    final sessionsStorage = tasksStorage;
    
    final modulesStorage = HiveDataSource();
    
    setState(() {
      _settingsStorage = settingsStorage;
      _authStorage = authStorage;
      _tasksStorage = tasksStorage;
      _sessionsStorage = sessionsStorage;
      _modulesStorage = modulesStorage;
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized || 
        _settingsStorage == null || 
        _authStorage == null || 
        _tasksStorage == null || 
        _sessionsStorage == null || 
        _modulesStorage == null) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    // Инициализация репозиториев с соответствующими хранилищами
    // Settings → SharedPreferences
    final settingsRepository = SettingsRepositoryImpl(_settingsStorage!);
    // Auth → Secure Store
    final authRepository = AuthRepositoryImpl(_authStorage!);
    // Tasks → Drift (SQL)
    final tasksRepository = TasksRepositoryImpl(_tasksStorage!);
    // Modules → Hive (NoSQL)
    final modulesRepository = ModulesRepositoryImpl(_modulesStorage!);
    // Sessions → Drift (SQL)
    final sessionsRepository = SessionsRepositoryImpl(_sessionsStorage!);

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
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.dark,
            primary: AppColors.primary,
            secondary: AppColors.accent,
            surface: const Color(0xFF1E2A27),
            background: const Color(0xFF0F1412),
          ),
          scaffoldBackgroundColor: const Color(0xFF0F1412),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1E2A27),
            elevation: 2,
            foregroundColor: Colors.white,
            centerTitle: true,
            titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color(0xFF1E2A27),
            selectedItemColor: AppColors.accent,
            unselectedItemColor: Color(0xFF93A3AF),
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
          cardTheme: CardThemeData(
            color: const Color(0xFF1E2A27),
            elevation: 2,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
            margin: const EdgeInsets.all(16),
          ),
          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: Color(0xFFE2E8F0), fontSize: 16),
            titleLarge: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF1E2A27),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF374151)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF374151)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
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
