// lib/main.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show ValueListenable;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Storage.init();
  runApp(const MyApp());
}

/// Хранилище (SharedPreferences)
class Storage {
  static late SharedPreferences _prefs;

  static const _kDark = 'dark_theme';
  static const _kCounter = 'counter';
  static const _kTasks = 'tasks_json';
  static const _kName = 'profile_name';
  static const _kRole = 'profile_role';
  static const _kNotif = 'settings_notifications';
  static const _kAnalyt = 'settings_analytics';

  static Future<void> init() async => _prefs = await SharedPreferences.getInstance();

  static bool getDark() => _prefs.getBool(_kDark) ?? false;
  static Future<void> setDark(bool v) => _prefs.setBool(_kDark, v);

  static int getCounter() => _prefs.getInt(_kCounter) ?? 0;
  static Future<void> setCounter(int v) => _prefs.setInt(_kCounter, v);

  static String getName() => _prefs.getString(_kName) ?? 'Амерханов Кирилл';
  static String getRole() => _prefs.getString(_kRole) ?? 'Разработчик';
  static Future<void> setName(String v) => _prefs.setString(_kName, v);
  static Future<void> setRole(String v) => _prefs.setString(_kRole, v);

  static bool getNotifications() => _prefs.getBool(_kNotif) ?? true;
  static bool getAnalytics() => _prefs.getBool(_kAnalyt) ?? false;
  static Future<void> setNotifications(bool v) => _prefs.setBool(_kNotif, v);
  static Future<void> setAnalytics(bool v) => _prefs.setBool(_kAnalyt, v);

  static List<Task> getTasks() {
    final raw = _prefs.getString(_kTasks);
    if (raw == null || raw.isEmpty) {
      return [
        Task('Изучить виджеты Text/Button/Row/Column'),
        Task('Сделать собственные Stateless/Stateful'),
        Task('Смену контента по BottomBar', done: true),
      ];
    }
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map(Task.fromJson).toList();
  }

  static Future<void> setTasks(List<Task> tasks) =>
      _prefs.setString(_kTasks, jsonEncode(tasks.map((e) => e.toJson()).toList()));
}

/// Общий state через ValueNotifier — просто и реактивно
class AppState {
  // Тема/настройки
  final themeDark = ValueNotifier<bool>(Storage.getDark());
  final notifications = ValueNotifier<bool>(Storage.getNotifications());
  final analytics = ValueNotifier<bool>(Storage.getAnalytics());

  // Профиль
  final name = ValueNotifier<String>(Storage.getName());
  final role = ValueNotifier<String>(Storage.getRole());

  // Данные
  final counter = ValueNotifier<int>(Storage.getCounter());
  final tasks = ValueNotifier<List<Task>>(Storage.getTasks());

  // --- операции с персистом ---
  Future<void> setDark(bool v) async { themeDark.value = v; await Storage.setDark(v); }
  Future<void> setNotifications(bool v) async { notifications.value = v; await Storage.setNotifications(v); }
  Future<void> setAnalytics(bool v) async { analytics.value = v; await Storage.setAnalytics(v); }

  Future<void> setName(String v) async { name.value = v; await Storage.setName(v); }
  Future<void> setRole(String v) async { role.value = v; await Storage.setRole(v); }

  Future<void> setCounter(int v) async { counter.value = v; await Storage.setCounter(v); }
  Future<void> incCounter() => setCounter(counter.value + 1);
  Future<void> decCounter() => setCounter(counter.value > 0 ? counter.value - 1 : 0);
  Future<void> resetCounter() => setCounter(0);

  Future<void> addTask(String title) async {
    final list = [Task(title), ...tasks.value];
    tasks.value = list;
    await Storage.setTasks(list);
  }

  Future<void> toggleTask(int index, bool done) async {
    final list = [...tasks.value];
    list[index] = list[index].copyWith(done: done);
    tasks.value = list;
    await Storage.setTasks(list);
  }

  Future<void> deleteTask(int index) async {
    final list = [...tasks.value]..removeAt(index);
    tasks.value = list;
    await Storage.setTasks(list);
  }

  Future<void> clearDone() async {
    final list = tasks.value.where((t) => !t.done).toList();
    tasks.value = list;
    await Storage.setTasks(list);
  }
}

/// Цвета
class AppColors {
  static const Color primary = Color(0xFF0F766E);
  static const Color primaryDark = Color(0xFF115E59);
  static const Color surface = Color(0xFFF1F5F9);
  static const Color accent = Color(0xFFFFB703);
  static const Color accentSoft = Color(0xFFFFE08A);
  static const Color textPrimary = Color(0xFF0B1F2B);
  static const Color textSecondary = Color(0xFF475569);
  static const Color navBg = Color(0xFF0B3B37);
  static const Color navUnselected = Color(0xFF93A3AF);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppState state = AppState();

  @override
  void initState() {
    super.initState();
    // Когда меняется тема — перестраиваем MaterialApp
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
      title: 'Практическая работа №3. Амерханов К.А. ИКБО-11-22',
      theme: light,
      darkTheme: dark,
      themeMode: state.themeDark.value ? ThemeMode.dark : ThemeMode.light,
      home: HomeScreen(state: state),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final AppState state;
  const HomeScreen({super.key, required this.state});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  String _titleFor(int i) => switch (i) {
    0 => 'Главная',
    1 => 'Профиль',
    2 => 'Счётчик',
    3 => 'Настройки',
    _ => 'О приложении',
  };

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(state: widget.state),
      ProfilePage(state: widget.state),
      CounterPage(state: widget.state),
      SettingsPage(state: widget.state),
      AboutPage(state: widget.state),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titleFor(_index)),
        actions: [
          // Бейдж выполненных задач на всех экранах
          ValueListenableBuilder<List<Task>>(
            valueListenable: widget.state.tasks,
            builder: (_, tasks, __) {
              final done = tasks.where((t) => t.done).length;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Chip(
                  label: Text('Готово: $done'),
                  backgroundColor: AppColors.accentSoft,
                ),
              );
            },
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE6FFFB), Color(0xFFF8FAFC)],
          ),
        ),
        child: SafeArea(
          // IndexedStack сохраняет локальные состояния экранов
          child: IndexedStack(index: _index, children: pages),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Главная"),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: "Профиль"),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_rounded), label: "Счётчик"),
          BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: "Настройки"),
          BottomNavigationBarItem(icon: Icon(Icons.info_rounded), label: "О приложении"),
        ],
      ),
    );
  }
}

/// ====== МОДЕЛИ ======
class Task {
  final String title;
  final bool done;
  Task(this.title, {this.done = false});
  Task copyWith({String? title, bool? done}) =>
      Task(title ?? this.title, done: done ?? this.done);
  Map<String, dynamic> toJson() => {'title': title, 'done': done};
  factory Task.fromJson(Map<String, dynamic> json) =>
      Task(json['title'] as String, done: json['done'] as bool? ?? false);
}

/// ====== ЭКРАНЫ ======

/// 1) Главная — задачи + связь со счётчиком
class HomePage extends StatefulWidget {
  final AppState state;
  const HomePage({super.key, required this.state});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final input = TextEditingController();
  final search = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              const Icon(Icons.school_rounded, color: Colors.white, size: 40),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Практическая работа №3\nFlutter Widgets Showcase',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
              ),
              // связь со счётчиком
              ValueListenableBuilder<int>(
                valueListenable: widget.state.counter,
                builder: (_, v, __) => Chip(
                  label: Text('Счётчик: $v',
                      style: const TextStyle(color: Colors.white)),
                  backgroundColor: Colors.black26,
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Поиск
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: search,
              decoration: InputDecoration(
                hintText: 'Поиск по задачам...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: search,
                  builder: (_, val, __) => val.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => search.clear(),
                  )
                      : const SizedBox.shrink(),
                ),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
        ),

        // Добавление
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: input,
                    decoration: const InputDecoration(
                      hintText: 'Новая задача...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    onSubmitted: (_) async {
                      if (input.text.trim().isEmpty) return;
                      await widget.state.addTask(input.text.trim());
                      input.clear();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (input.text.trim().isEmpty) return;
                    await widget.state.addTask(input.text.trim());
                    input.clear();
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Добавить'),
                ),
              ],
            ),
          ),
        ),

        // Список
        ValueListenableBuilder<List<Task>>(
          valueListenable: widget.state.tasks,
          builder: (_, tasks, __) {
            final query = search.text.trim().toLowerCase();
            final filtered = query.isEmpty
                ? tasks
                : tasks
                .where((t) => t.title.toLowerCase().contains(query))
                .toList();
            return Column(
              children: [
                for (var i = 0; i < filtered.length; i++)
                  _TaskTile(
                    task: filtered[i],
                    onToggle: (v) async {
                      final idx = tasks.indexOf(filtered[i]);
                      if (idx != -1) await widget.state.toggleTask(idx, v);
                    },
                    onDelete: () async {
                      final idx = tasks.indexOf(filtered[i]);
                      if (idx != -1) await widget.state.deleteTask(idx);
                    },
                  ),
                if (tasks.any((t) => t.done))
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: OutlinedButton.icon(
                      onPressed: widget.state.clearDone,
                      icon: const Icon(Icons.cleaning_services_rounded),
                      label: const Text('Очистить выполненные'),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _TaskTile extends StatelessWidget {
  final Task task;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;
  const _TaskTile(
      {required this.task, required this.onToggle, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('${task.title}_${task.done}'),
      background: _swipeBg(Alignment.centerLeft),
      secondaryBackground: _swipeBg(Alignment.centerRight),
      onDismissed: (_) => onDelete(),
      child: Card(
        child: CheckboxListTile(
          value: task.done,
          onChanged: (v) => onToggle(v ?? false),
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.done ? TextDecoration.lineThrough : null,
              color: task.done ? Colors.grey : null,
            ),
          ),
          secondary:
          const Icon(Icons.checklist_rounded, color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _swipeBg(Alignment a) => Container(
    decoration: BoxDecoration(
        color: Colors.redAccent, borderRadius: BorderRadius.circular(16)),
    alignment: a,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: const Icon(Icons.delete, color: Colors.white),
  );
}

/// 2) Профиль — моментальное сохранение и отражение
class ProfilePage extends StatefulWidget {
  final AppState state;
  const ProfilePage({super.key, required this.state});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool edit = false;
  late final TextEditingController name =
  TextEditingController(text: widget.state.name.value);
  late final TextEditingController role =
  TextEditingController(text: widget.state.role.value);

  Future<void> _save() async {
    await widget.state.setName(name.text.trim());
    await widget.state.setRole(role.text.trim());
    setState(() => edit = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Профиль сохранён')));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 3,
        child: Container(
          width: 360,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFFE0FBFC), Color(0xFFFDFCFB)]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.primary,
                child:
                Icon(Icons.person_rounded, color: Colors.white, size: 36),
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder2<String, String>(
                listenableA: widget.state.name,
                listenableB: widget.state.role,
                builder: (_, n, r, __) => edit
                    ? Column(
                  children: [
                    TextField(
                        controller: name,
                        decoration: const InputDecoration(
                            labelText: 'ФИО',
                            border: OutlineInputBorder())),
                    const SizedBox(height: 10),
                    TextField(
                        controller: role,
                        decoration: const InputDecoration(
                            labelText: 'Роль',
                            border: OutlineInputBorder())),
                  ],
                )
                    : Column(
                  children: [
                    Text(n, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text(r, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!edit)
                    ElevatedButton.icon(
                      onPressed: () => setState(() => edit = true),
                      icon: const Icon(Icons.edit_rounded),
                      label: const Text('Редактировать'),
                    )
                  else ...[
                    ElevatedButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Сохранить'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () => setState(() => edit = false),
                      icon: const Icon(Icons.close_rounded),
                      label: const Text('Отмена'),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _ProfileChip(icon: Icons.code_rounded, label: 'Flutter'),
                  SizedBox(width: 10),
                  _ProfileChip(icon: Icons.security_rounded, label: 'Dart'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ProfileChip({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
          color: AppColors.accentSoft,
          borderRadius: BorderRadius.circular(999)),
      child: Row(children: [
        Icon(icon, size: 18, color: AppColors.textPrimary),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600))
      ]),
    );
  }
}

/// 3) Счётчик — реагирует на любые изменения из настроек/главной
class CounterPage extends StatelessWidget {
  final AppState state;
  const CounterPage({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Счётчик',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              ValueListenableBuilder<int>(
                valueListenable: state.counter,
                builder: (_, v, __) => Container(
                  width: 120,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('$v',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      onPressed: state.decCounter,
                      icon: const Icon(Icons.remove_circle_rounded),
                      color: AppColors.primaryDark,
                      iconSize: 34),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                      onPressed: state.incCounter,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Увеличить')),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: state.resetCounter,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Сброс'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 4) Настройки — мгновенно переключают тему и управляют счётчиком
class SettingsPage extends StatelessWidget {
  final AppState state;
  const SettingsPage({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 88),
      children: [
        const _SettingsHeader(),
        ValueListenableBuilder<bool>(
          valueListenable: state.themeDark,
          builder: (_, val, __) => Card(
            child: SwitchListTile(
              value: val,
              onChanged: (v) => state.setDark(v),
              title: const Text('Тёмная тема'),
              subtitle: const Text('Переключение ThemeMode для всего приложения'),
              secondary:
              const Icon(Icons.dark_mode_rounded, color: AppColors.primary),
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.timer_rounded, color: AppColors.primary),
            title: const Text('Текущее значение счётчика'),
            subtitle: ValueListenableBuilder<int>(
              valueListenable: state.counter,
              builder: (_, v, __) => Text('Сейчас: $v'),
            ),
            trailing: Wrap(
              spacing: 6,
              children: [
                IconButton(
                  tooltip: 'Уменьшить',
                  onPressed: state.decCounter,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                IconButton(
                  tooltip: 'Увеличить',
                  onPressed: state.incCounter,
                  icon: const Icon(Icons.add_circle_outline),
                ),
                ElevatedButton(
                  onPressed: state.resetCounter,
                  child: const Text('Сброс'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFFD1FAE5), Color(0xFFF0FDFA)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: const [
          Icon(Icons.tune_rounded, color: AppColors.primary, size: 28),
          SizedBox(width: 10),
          Expanded(
              child: Text('Настройки приложения',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary))),
        ],
      ),
    );
  }
}

/// 5) О приложении — показывает актуальные данные из других экранов
class AboutPage extends StatefulWidget {
  final AppState state;
  const AboutPage({super.key, required this.state});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  static const String _version = '1.0.0';
  int _taps = 0;

  void _copyVersion() async {
    await Clipboard.setData(const ClipboardData(text: _version));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Версия скопирована в буфер обмена')),
    );
  }

  void _easterEggTap() {
    setState(() => _taps++);
    if (_taps >= 7) {
      _taps = 0;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('🎉 Пасхалка'),
          content:
          const Text('Молодец! Ты нашёл пасхалку. Удачи на защите!'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Ок')),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.apps_rounded, color: AppColors.primary),
            title: const Text('Практическая работа №3'),
            subtitle: const Text(
                'Демонстрация Stateless/Stateful виджетов и смены контента'),
          ),
        ),
        Card(
          child: ListTile(
            leading:
            const Icon(Icons.person_outline_rounded, color: AppColors.primary),
            title: ValueListenableBuilder2<String, String>(
              listenableA: widget.state.name,
              listenableB: widget.state.role,
              builder: (_, name, role, __) => Text('$name — $role'),
            ),
            subtitle: const Text('Данные берутся из экрана «Профиль»'),
          ),
        ),
        Card(
          child: ListTile(
            leading:
            const Icon(Icons.checklist_rounded, color: AppColors.primary),
            title: ValueListenableBuilder<List<Task>>(
              valueListenable: widget.state.tasks,
              builder: (_, tasks, __) {
                final done = tasks.where((t) => t.done).length;
                return Text('Задач: ${tasks.length}, выполнено: $done');
              },
            ),
            subtitle: const Text('Статистика синхронизирована с «Главной»'),
          ),
        ),
        Card(
          child: ListTile(
            leading:
            const Icon(Icons.timer_rounded, color: AppColors.primary),
            title: ValueListenableBuilder<int>(
              valueListenable: widget.state.counter,
              builder: (_, v, __) => Text('Счётчик: $v'),
            ),
            subtitle: const Text('Общее значение из вкладки «Счётчик»'),
          ),
        ),
        Card(
          child: ListTile(
            leading:
            const Icon(Icons.info_outline_rounded, color: AppColors.primary),
            title: const Text('Версия'),
            subtitle: Text(_version),
            onTap: _easterEggTap,
            trailing: OutlinedButton(
              onPressed: _copyVersion,
              child: const Text('Скопировать'),
            ),
          ),
        ),
      ],
    );
  }
}

/// ====== маленький хелпер для 2-х листенеров ======
class ValueListenableBuilder2<A, B> extends StatelessWidget {
  final ValueListenable<A> listenableA;
  final ValueListenable<B> listenableB;
  final Widget Function(BuildContext, A, B, Widget?) builder;
  final Widget? child;

  const ValueListenableBuilder2({
    super.key,
    required this.listenableA,
    required this.listenableB,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<A>(
      valueListenable: listenableA,
      builder: (context, a, _) => ValueListenableBuilder<B>(
        valueListenable: listenableB,
        builder: (context, b, __) => builder(context, a, b, child),
      ),
    );
  }
}
