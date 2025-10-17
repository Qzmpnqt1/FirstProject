import 'package:flutter/material.dart';
import '../../app/app_state.dart';
import '../../app/app_colors.dart';
import '../../data/module.dart';
import 'module_details_screen.dart';

class ModulesScreen extends StatelessWidget {
  final AppState state;
  const ModulesScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Учебные модули')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createModuleDialog(context),
        child: const Icon(Icons.add),
      ),
      body: ValueListenableBuilder<List<Module>>(
        valueListenable: state.modulesEx,
        builder: (_, list, __) {
          if (list.isEmpty) {
            return const Center(child: Text('Пока нет модулей — добавьте первый с помощью кнопки +'));
          }
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, i) {
              final m = list[i];
              return Dismissible(
                key: ValueKey(m.id),
                background: _bg(Alignment.centerLeft),
                secondaryBackground: _bg(Alignment.centerRight),
                onDismissed: (_) => state.deleteModuleEx(m.id),
                child: Card(
                  child: ListTile(
                    leading: Icon(
                      m.type == ModuleType.lecture
                          ? Icons.menu_book_rounded
                          : (m.type == ModuleType.practice ? Icons.task_alt_rounded : Icons.science_rounded),
                      color: AppColors.primary,
                    ),
                    title: Text(m.title),
                    subtitle: Text(
                      'Часы: ${m.hours} • Прогресс: ${(m.progress * 100).toStringAsFixed(0)}% • Статус: ${_status(m.status)}',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ModuleDetailsScreen(state: state, moduleId: m.id)),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _bg(Alignment a) => Container(
    decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(16)),
    alignment: a,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: const Icon(Icons.delete, color: Colors.white),
  );

  void _createModuleDialog(BuildContext context) {
    final title = TextEditingController();
    final hours = TextEditingController(text: '4');
    ModuleType type = ModuleType.lecture;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Новый модуль'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: title, decoration: const InputDecoration(labelText: 'Название')),
            const SizedBox(height: 8),
            DropdownButtonFormField<ModuleType>(
              value: type,
              items: const [
                DropdownMenuItem(value: ModuleType.lecture, child: Text('Лекция')),
                DropdownMenuItem(value: ModuleType.practice, child: Text('Практика')),
                DropdownMenuItem(value: ModuleType.lab, child: Text('Лабораторная')),
              ],
              onChanged: (v) => type = v ?? ModuleType.lecture,
              decoration: const InputDecoration(labelText: 'Тип'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: hours,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Часы'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () {
              final h = int.tryParse(hours.text) ?? 0;
              if (title.text.trim().isEmpty || h <= 0) return;
              state.addModuleEx(title.text.trim(), type, h);
              Navigator.pop(context);
            },
            child: const Text('Создать'),
          ),
        ],
      ),
    );
  }

  String _status(ModuleStatus s) => switch (s) {
    ModuleStatus.notStarted => 'не начат',
    ModuleStatus.inProgress => 'в процессе',
    ModuleStatus.completed => 'завершён',
  };
}
