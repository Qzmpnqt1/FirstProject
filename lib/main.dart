import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class AppColors {
  static const Color primary = Color(0xFF0F766E);
  static const Color navBg = Color(0xFF0B3B37);
  static const Color accent = Color(0xFFFFB703);
  static const Color surface = Color(0xFFF1F5F9);
  static const Color textPrimary = Color(0xFF0B1F2B);
  static const Color navUnselected = Color(0xFF93A3AF);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      scaffoldBackgroundColor: AppColors.surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.navBg,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.navUnselected,
        type: BottomNavigationBarType.fixed,
      ),
    );

    return MaterialApp(
      title: 'Практическая работа №3',
      theme: theme,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;

  final pages = const [
    Center(child: Text('Главная')),
    Center(child: Text('Профиль')),
    Center(child: Text('Счётчик')),
    Center(child: Text('Настройки')),
    Center(child: Text('О приложении')),
  ];

  String title(int i) => switch (i) {
    0 => 'Главная',
    1 => 'Профиль',
    2 => 'Счётчик',
    3 => 'Настройки',
    _ => 'О приложении',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title(index))),
      body: SafeArea(child: pages[index]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Главная'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Профиль'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_rounded), label: 'Счётчик'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Настройки'),
          BottomNavigationBarItem(icon: Icon(Icons.info_rounded), label: 'О приложении'),
        ],
      ),
    );
  }
}
