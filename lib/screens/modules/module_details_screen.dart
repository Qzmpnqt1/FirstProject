import 'package:flutter/material.dart';
import '../../app/app_state.dart';
import '../../app/app_colors.dart';
import '../../data/module.dart';

class ModuleDetailsScreen extends StatelessWidget {
  final AppState state;
  final String moduleId;
  const ModuleDetailsScreen({super.key, required this.state, required this.moduleId});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Module>>(
      valueListenable: state.modulesEx,
      builder: (_, list, __) {
        final m = list.firstWhere((e) => e.id == moduleId);
        return Scaffold(
          appBar: AppBar(
            title: Text(m.title),
            actions: [
              IconButton(
                tooltip: 'Переименовать',
                onPressed: () => _rename(context, m),
                icon: const Icon(Icons.edit_rounded),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _addItem(context, m),
            icon: const Icon(Icons.add),
            label: const Text('Тема/практика'),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              _header(m),
              const SizedBox(height: 10),
              _section('Теория', m.topics, (i, v) => state.toggleTopic(moduleId, true, i, v), (i) => state.deleteTopic(moduleId, true, i)),
              const SizedBox(height: 8),
              _section('Практика', m.practices, (i, v) => state.toggleTopic(moduleId, false, i, v), (i) => state.deleteTopic(moduleId, false, i)),
            ],
          ),
        );
      },
    );
  }

  Widget _header(Module m) {
    final p = (m.progress * 100).toStringAsFixed(0);
    return Card(
      child: ListTile(
        leading: CircularProgressIndicator(value: m.progress),
        title: Text('Прогресс: $p%'),
        subtitle: Text('Тип: ${_type(m.type)} • Часы: ${m.hours} • Статус: ${_status(m.status)}'),
      ),
    );
  }

  Widget _section(
      String title,
      List<TopicItem> items,
      void Function(int index, bool value) onToggle,
      void Function(int index) onDelete,
      ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.list_alt_rounded, color: AppColors.primary),
              title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
            const Divider(height: 1),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Пока пусто'),
              ),
            for (int i = 0; i < items.length; i++)
              CheckboxListTile(
                value: items[i].done,
                onChanged: (v) => onToggle(i, v ?? false),
                title: Text(items[i].title),
                secondary: IconButton(
                  tooltip: 'Удалить',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => onDelete(i),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _rename(BuildContext context, Module m) {
    final c = TextEditingController(text: m.title);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Переименовать модуль'),
        content: TextField(controller: c, decoration: const InputDecoration(labelText: 'Название')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () { if (c.text.trim().isNotEmpty) state.renameModule(m.id, c.text.trim()); Navigator.pop(context); },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _addItem(BuildContext context, Module m) {
    final c = TextEditingController();
    bool isTopic = true;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Новый пункт'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: c, decoration: const InputDecoration(labelText: 'Название')),
            const SizedBox(height: 8),
            DropdownButtonFormField<bool>(
              value: isTopic,
              items: const [
                DropdownMenuItem(value: true, child: Text('Теория')),
                DropdownMenuItem(value: false, child: Text('Практика')),
              ],
              onChanged: (v) => isTopic = v ?? true,
              decoration: const InputDecoration(labelText: 'Тип'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () {
              if (c.text.trim().isEmpty) return;
              state.addTopic(moduleId, isTopic, c.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }

  String _type(ModuleType t) => switch (t) {
    ModuleType.lecture => 'лекция',
    ModuleType.practice => 'практика',
    ModuleType.lab => 'лабораторная',
  };

  String _status(ModuleStatus s) => switch (s) {
    ModuleStatus.notStarted => 'не начат',
    ModuleStatus.inProgress => 'в процессе',
    ModuleStatus.completed => 'завершён',
  };
}
