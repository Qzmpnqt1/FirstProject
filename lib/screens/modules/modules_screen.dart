import 'package:flutter/material.dart';
import '../../app/app_state.dart';
import '../../data/module.dart';
import '../../app/app_colors.dart';
import '../../widgets/modules_list_view.dart'; // ← добавили
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
          return ModulesListView(
            modules: list,
            onOpen: (m) => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ModuleDetailsScreen(state: state, moduleId: m.id),
              ),
            ),
            onDelete: (m) => state.deleteModuleEx(m.id),
          );
        },
      ),
    );
  }

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
}
