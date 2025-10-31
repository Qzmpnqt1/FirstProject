import 'package:flutter/material.dart';
import '../app/app_colors.dart';
import '../app/app_state.dart';

// 5 предметных экранов
import 'home_page.dart';
import 'modules/modules_screen.dart';
import 'profile_page.dart';
import 'counter_page.dart';
import 'settings_page.dart';

class RouterRootTabs extends StatefulWidget {
  final AppState state;
  const RouterRootTabs({super.key, required this.state});

  @override
  State<RouterRootTabs> createState() => _RouterRootTabsState();
}

class _RouterRootTabsState extends State<RouterRootTabs>
    with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 5, vsync: this);

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

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
      appBar: AppBar(
        title: AnimatedBuilder(
          animation: _tab,
          builder: (_, __) => Text(_titleFor(_tab.index)),
        ),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFFE6FFFB), Color(0xFFF8FAFC)],
          ),
        ),
        child: TabBarView(
          controller: _tab,
          physics: const BouncingScrollPhysics(),
          children: [
            HomePage(state: widget.state),
            ModulesScreen(state: widget.state),
            ProfilePage(state: widget.state),
            CounterPage(state: widget.state),
            SettingsPage(state: widget.state),
          ],
        ),
      ),
      bottomNavigationBar: Material(
        color: AppColors.navBg,
        child: SafeArea(
          top: false,
          child: TabBar(
            controller: _tab,
            labelColor: AppColors.accent,
            unselectedLabelColor: AppColors.navUnselected,
            indicatorColor: AppColors.accent,
            tabs: const [
              Tab(icon: Icon(Icons.home_rounded), text: 'Главная'),
              Tab(icon: Icon(Icons.school_rounded), text: 'Модули'),
              Tab(icon: Icon(Icons.person_rounded), text: 'Профиль'),
              Tab(icon: Icon(Icons.add_circle_rounded), text: 'Счётчик'),
              Tab(icon: Icon(Icons.settings_rounded), text: 'Настройки'),
            ],
          ),
        ),
      ),
    );
  }
}
