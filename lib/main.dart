import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class AppColors {
  static const Color primary = Color(0xFF0F766E);
  static const Color primaryDark = Color(0xFF115E59);
  static const Color navBg = Color(0xFF0B3B37);
  static const Color accent = Color(0xFFFFB703);
  static const Color navUnselected = Color(0xFF93A3AF);
  static const Color surface = Color(0xFFF1F5F9);
  static const Color textPrimary = Color(0xFF0B1F2B);
  static const Color textSecondary = Color(0xFF475569);
  static const Color accentSoft = Color(0xFFFFE08A);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      scaffoldBackgroundColor: AppColors.surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary, foregroundColor: Colors.white, centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.navBg, selectedItemColor: AppColors.accent, unselectedItemColor: AppColors.navUnselected, type: BottomNavigationBarType.fixed,
      ),
      cardTheme: const CardThemeData(color: Colors.white, elevation: 2, margin: EdgeInsets.all(16)),
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
    HomePage(),
    ProfilePage(),
    CounterPage(),
    SettingsPage(),
    AboutPage(),
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
      body: SafeArea(child: IndexedStack(index: index, children: pages)),
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

/// Главная (Stateful — примитивный список задач в памяти)
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class Task {
  final String title;
  final bool done;
  Task(this.title, {this.done = false});
  Task copyWith({String? title, bool? done}) => Task(title ?? this.title, done: done ?? this.done);
}

class _HomePageState extends State<HomePage> {
  final input = TextEditingController();
  final List<Task> tasks = [
    Task('Изучить базовые виджеты'),
    Task('Сделать Stateless/Stateful', done: true),
  ];

  void addTask() {
    final t = input.text.trim();
    if (t.isEmpty) return;
    setState(() => tasks.insert(0, Task(t)));
    input.clear();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Text('Практическая работа №3\nFlutter Widgets Showcase',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: input,
                    decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Новая задача...'),
                    onSubmitted: (_) => addTask(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(onPressed: addTask, icon: const Icon(Icons.add), label: const Text('Добавить')),
              ],
            ),
          ),
        ),
        for (var i = 0; i < tasks.length; i++)
          _TaskTile(
            task: tasks[i],
            onToggle: (v) => setState(() => tasks[i] = tasks[i].copyWith(done: v)),
            onDelete: () => setState(() => tasks.removeAt(i)),
          ),
      ],
    );
  }
}

/// Статический элемент списка задач (Stateless)
class _TaskTile extends StatelessWidget {
  final Task task;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;
  const _TaskTile({required this.task, required this.onToggle, required this.onDelete, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: CheckboxListTile(
        value: task.done,
        onChanged: (v) => onToggle(v ?? false),
        title: Text(
          task.title,
          style: TextStyle(decoration: task.done ? TextDecoration.lineThrough : null),
        ),
        secondary: IconButton(icon: const Icon(Icons.delete_outline), onPressed: onDelete),
      ),
    );
  }
}

/// Профиль (Stateful — редактирование ФИО/роли локально)
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool edit = false;
  final name = TextEditingController(text: 'Амерханов Кирилл');
  final role = TextEditingController(text: 'Разработчик');

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const CircleAvatar(radius: 32, child: Icon(Icons.person)),
            const SizedBox(height: 12),
            if (!edit) ...[
              Text(name.text, style: Theme.of(context).textTheme.titleLarge),
              Text(role.text),
              const SizedBox(height: 12),
              ElevatedButton.icon(onPressed: () => setState(() => edit = true), icon: const Icon(Icons.edit), label: const Text('Редактировать')),
            ] else ...[
              TextField(controller: name, decoration: const InputDecoration(labelText: 'ФИО', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              TextField(controller: role, decoration: const InputDecoration(labelText: 'Роль', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              Row(mainAxisSize: MainAxisSize.min, children: [
                ElevatedButton.icon(onPressed: () => setState(() => edit = false), icon: const Icon(Icons.check), label: const Text('Сохранить')),
                const SizedBox(width: 8),
                OutlinedButton.icon(onPressed: () => setState(() => edit = false), icon: const Icon(Icons.close), label: const Text('Отмена')),
              ]),
            ],
            const SizedBox(height: 12),
            const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _ProfileChip(icon: Icons.code, label: 'Flutter'),
              SizedBox(width: 8),
              _ProfileChip(icon: Icons.security, label: 'Dart'),
            ]),
          ]),
        ),
      ),
    );
  }
}

/// Чип навыка (Stateless)
class _ProfileChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ProfileChip({required this.icon, required this.label, super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: AppColors.accentSoft, borderRadius: BorderRadius.circular(999)),
      child: Row(children: [Icon(icon, size: 16), const SizedBox(width: 6), Text(label)]),
    );
  }
}

/// Счётчик (Stateless — пока локальные кнопки без общего состояния)
class CounterPage extends StatelessWidget {
  const CounterPage({super.key});
  @override
  Widget build(BuildContext context) {
    int value = 0;
    return StatefulBuilder(
      builder: (context, setState) => Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('$value', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
              Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(onPressed: () => setState(() => value = value > 0 ? value - 1 : 0), icon: const Icon(Icons.remove_circle)),
                ElevatedButton(onPressed: () => setState(() => value++), child: const Text('Увеличить')),
                OutlinedButton(onPressed: () => setState(() => value = 0), child: const Text('Сброс')),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}

/// Настройки (Stateless — визуальные заглушки)
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: const [
        _SettingsHeader(),
        Card(child: ListTile(leading: Icon(Icons.dark_mode), title: Text('Тёмная тема'), subtitle: Text('Заглушка'))),
        Card(child: ListTile(leading: Icon(Icons.timer), title: Text('Сбросить счётчик'), subtitle: Text('Заглушка'))),
      ],
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFD1FAE5), Color(0xFFF0FDFA)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text('Настройки приложения', style: TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}

/// О приложении (Stateful — пасхалка на тап)
class AboutPage extends StatefulWidget {
  const AboutPage({super.key});
  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  int taps = 0;
  void egg() {
    setState(() => taps++);
    if (taps >= 5) {
      taps = 0;
      showDialog(context: context, builder: (_) => const AlertDialog(title: Text('🎉 Пасхалка'), content: Text('Удачи на защите!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(child: ListTile(leading: const Icon(Icons.apps), title: const Text('Практическая работа №3'), onTap: egg)),
        const Card(child: ListTile(leading: Icon(Icons.info_outline), title: Text('Версия'), subtitle: Text('1.0.0'))),
      ],
    );
  }
}
