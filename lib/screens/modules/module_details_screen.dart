import 'package:flutter/material.dart';
import '../../app/app_state.dart';
import '../../data/module.dart';
import '../../widgets/topic_row.dart'; // ← добавили

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
        final progressPercent = (m.progress * 100).toStringAsFixed(0);

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
            onPressed: () => _addItem(context),
            icon: const Icon(Icons.add),
            label: const Text('Тема/практика'),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              Card(
                child: ListTile(
                  leading: CircularProgressIndicator(value: m.progress),
                  title: Text('Прогресс: $progressPercent%'),
                  subtitle: Text('Тип: ${_type(m.type)} • Часы: ${m.hours} • Статус: ${_status(m.status)}'),
                ),
              ),
              _section(
                context: context,
                title: 'Теория',
                items: m.topics,
                onToggle: (i, v) => state.toggleTopic(moduleId, true, i, v),
                onDelete: (i) => state.deleteTopic(moduleId, true, i),
              ),
              _section(
                context: context,
                title: 'Практика',
                items: m.practices,
                onToggle: (i, v) => state.toggleTopic(moduleId, false, i, v),
                onDelete: (i) => state.deleteTopic(moduleId, false, i),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _section({
    required BuildContext context,
    required String title,
    required List<TopicItem> items,
    required void Function(int index, bool value) onToggle,
    required void Function(int index) onDelete,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            ListTile(title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700))),
            const Divider(height: 1),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Пока пусто'),
              ),
            for (int i = 0; i < items.length; i++)
              TopicRow(
                key: ValueKey('${title}_$i'),
                item: items[i],
                onToggle: (v) => onToggle(i, v),
                onDelete: () => onDelete(i),
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
            onPressed: () {
              if (c.text.trim().isNotEmpty) state.renameModule(m.id, c.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _addItem(BuildContext context) {
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
              // Делегируем контейнеру состояния
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
