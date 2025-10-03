import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show ValueListenable;

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

class Task {
  final String title;
  final bool done;
  Task(this.title, {this.done = false});
  Task copyWith({String? title, bool? done}) => Task(title ?? this.title, done: done ?? this.done);
}

class AppState {
  final themeDark = ValueNotifier<bool>(false);
  final name = ValueNotifier<String>('Амерханов Кирилл');
  final role = ValueNotifier<String>('Разработчик');
  final counter = ValueNotifier<int>(0);
  final tasks = ValueNotifier<List<Task>>([
    Task('Изучить базовые виджеты'),
    Task('Сделать Stateless/Stateful', done: true),
  ]);

  void setDark(bool v) => themeDark.value = v;

  void setName(String v) => name.value = v;
  void setRole(String v) => role.value = v;

  void setCounter(int v) => counter.value = v;
  void inc() => setCounter(counter.value + 1);
  void dec() => setCounter(counter.value > 0 ? counter.value - 1 : 0);
  void reset() => setCounter(0);

  void addTask(String title) => tasks.value = [Task(title), ...tasks.value];
  void toggleTask(int idx, bool done) {
    final list = [...tasks.value];
    list[idx] = list[idx].copyWith(done: done);
    tasks.value = list;
  }
  void deleteTask(int idx) {
    final list = [...tasks.value]..removeAt(idx);
    tasks.value = list;
  }
  void clearDone() => tasks.value = tasks.value.where((t) => !t.done).toList();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final state = AppState();

  @override
  void initState() {
    super.initState();
    state.themeDark.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final light = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      scaffoldBackgroundColor: AppColors.surface,
      appBarTheme: const AppBarTheme(backgroundColor: AppColors.primary, foregroundColor: Colors.white, centerTitle: true),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.navBg, selectedItemColor: AppColors.accent, unselectedItemColor: AppColors.navUnselected, type: BottomNavigationBarType.fixed,
      ),
      cardTheme: const CardThemeData(color: Colors.white, elevation: 2, margin: EdgeInsets.all(16)),
    );

    final dark = ThemeData(
      brightness: Brightness.dark,
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF0E1A18), selectedItemColor: AppColors.accent, unselectedItemColor: AppColors.navUnselected,
      ),
      cardTheme: const CardThemeData(elevation: 2, margin: EdgeInsets.all(16)),
    );

    return MaterialApp(
      title: 'Практическая работа №3',
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
  int index = 0;

  String title(int i) => switch (i) {
    0 => 'Главная', 1 => 'Профиль', 2 => 'Счётчик', 3 => 'Настройки', _ => 'О приложении',
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
        title: Text(title(index)),
        actions: [
          ValueListenableBuilder<List<Task>>(
            valueListenable: widget.state.tasks,
            builder: (_, tasks, __) {
              final done = tasks.where((t) => t.done).length;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Chip(label: Text('Готово: $done'), backgroundColor: AppColors.accentSoft),
              );
            },
          )
        ],
      ),
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

class HomePage extends StatefulWidget {
  final AppState state;
  const HomePage({super.key, required this.state});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final input = TextEditingController();

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
          child: Row(
            children: [
              const Icon(Icons.school_rounded, color: Colors.white, size: 40),
              const SizedBox(width: 12),
              const Expanded(child: Text('Практическая работа №3', style: TextStyle(color: Colors.white))),
              ValueListenableBuilder<int>(
                valueListenable: widget.state.counter,
                builder: (_, v, __) => Chip(label: Text('Счётчик: $v', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.black26),
              ),
            ],
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: input,
                  decoration: const InputDecoration(hintText: 'Новая задача...', border: OutlineInputBorder()),
                  onSubmitted: (_) {
                    if (input.text.trim().isEmpty) return;
                    widget.state.addTask(input.text.trim());
                    input.clear();
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  if (input.text.trim().isEmpty) return;
                  widget.state.addTask(input.text.trim());
                  input.clear();
                },
                icon: const Icon(Icons.add), label: const Text('Добавить'),
              ),
            ]),
          ),
        ),
        ValueListenableBuilder<List<Task>>(
          valueListenable: widget.state.tasks,
          builder: (_, tasks, __) => Column(
            children: [
              for (var i = 0; i < tasks.length; i++)
                _TaskTile(
                  task: tasks[i],
                  onToggle: (v) => widget.state.toggleTask(i, v),
                  onDelete: () => widget.state.deleteTask(i),
                ),
              if (tasks.any((t) => t.done))
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: OutlinedButton.icon(onPressed: widget.state.clearDone, icon: const Icon(Icons.cleaning_services), label: const Text('Очистить выполненные')),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

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
        title: Text(task.title, style: TextStyle(decoration: task.done ? TextDecoration.lineThrough : null)),
        secondary: IconButton(icon: const Icon(Icons.delete_outline), onPressed: onDelete),
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  final AppState state;
  const ProfilePage({super.key, required this.state});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool edit = false;
  late final name = TextEditingController(text: widget.state.name.value);
  late final role = TextEditingController(text: widget.state.role.value);

  Future<void> save() async {
    widget.state.setName(name.text.trim());
    widget.state.setRole(role.text.trim());
    setState(() => edit = false);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const CircleAvatar(radius: 32, child: Icon(Icons.person)),
            const SizedBox(height: 12),
            ValueListenableBuilder2<String, String>(
              listenableA: widget.state.name,
              listenableB: widget.state.role,
              builder: (_, n, r, __) => edit
                  ? Column(children: [
                TextField(controller: name, decoration: const InputDecoration(labelText: 'ФИО', border: OutlineInputBorder())),
                const SizedBox(height: 8),
                TextField(controller: role, decoration: const InputDecoration(labelText: 'Роль', border: OutlineInputBorder())),
              ])
                  : Column(children: [Text(n, style: Theme.of(context).textTheme.titleLarge), Text(r)]),
            ),
            const SizedBox(height: 12),
            Row(mainAxisSize: MainAxisSize.min, children: [
              if (!edit)
                ElevatedButton.icon(onPressed: () => setState(() => edit = true), icon: const Icon(Icons.edit), label: const Text('Редактировать'))
              else ...[
                ElevatedButton.icon(onPressed: save, icon: const Icon(Icons.check), label: const Text('Сохранить')),
                const SizedBox(width: 8),
                OutlinedButton.icon(onPressed: () => setState(() => edit = false), icon: const Icon(Icons.close), label: const Text('Отмена')),
              ],
            ]),
          ]),
        ),
      ),
    );
  }
}

class CounterPage extends StatelessWidget {
  final AppState state;
  const CounterPage({super.key, required this.state});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Счётчик'),
            const SizedBox(height: 8),
            ValueListenableBuilder<int>(
              valueListenable: state.counter,
              builder: (_, v, __) => Text('$v', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
            ),
            Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(onPressed: state.dec, icon: const Icon(Icons.remove_circle)),
              ElevatedButton(onPressed: state.inc, child: const Text('Увеличить')),
              OutlinedButton(onPressed: state.reset, child: const Text('Сброс')),
            ]),
          ]),
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  final AppState state;
  const SettingsPage({super.key, required this.state});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        const _SettingsHeader(),
        ValueListenableBuilder<bool>(
          valueListenable: state.themeDark,
          builder: (_, val, __) => Card(
            child: SwitchListTile(
              value: val,
              onChanged: state.setDark,
              title: const Text('Тёмная тема'),
              subtitle: const Text('ThemeMode на всё приложение'),
              secondary: const Icon(Icons.dark_mode),
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.timer),
            title: const Text('Текущее значение счётчика'),
            subtitle: ValueListenableBuilder<int>(
              valueListenable: state.counter,
              builder: (_, v, __) => Text('Сейчас: $v'),
            ),
            trailing: Wrap(
              spacing: 8,
              children: [
                IconButton(onPressed: state.dec, icon: const Icon(Icons.remove_circle_outline)),
                IconButton(onPressed: state.inc, icon: const Icon(Icons.add_circle_outline)),
                ElevatedButton(onPressed: state.reset, child: const Text('Сброс')),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader({super.key});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Color(0xFFD1FAE5), Color(0xFFF0FDFA)]),
      borderRadius: BorderRadius.circular(16),
    ),
    child: const Text('Настройки приложения', style: TextStyle(fontWeight: FontWeight.w700)),
  );
}

class AboutPage extends StatefulWidget {
  final AppState state;
  const AboutPage({super.key, required this.state});
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
        Card(
          child: ListTile(
            leading: const Icon(Icons.person_outline),
            title: ValueListenableBuilder2<String, String>(
              listenableA: widget.state.name,
              listenableB: widget.state.role,
              builder: (_, name, role, __) => Text('$name — $role'),
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.checklist),
            title: ValueListenableBuilder<List<Task>>(
              valueListenable: widget.state.tasks,
              builder: (_, tasks, __) => Text('Задач: ${tasks.length}, выполнено: ${tasks.where((t) => t.done).length}'),
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.timer),
            title: ValueListenableBuilder<int>(
              valueListenable: widget.state.counter,
              builder: (_, v, __) => Text('Счётчик: $v'),
            ),
          ),
        ),
      ],
    );
  }
}

class ValueListenableBuilder2<A, B> extends StatelessWidget {
  final ValueListenable<A> listenableA;
  final ValueListenable<B> listenableB;
  final Widget Function(BuildContext, A, B, Widget?) builder;
  final Widget? child;
  const ValueListenableBuilder2({super.key, required this.listenableA, required this.listenableB, required this.builder, this.child});

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
