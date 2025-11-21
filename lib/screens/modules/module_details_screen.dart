import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/app_state.dart';
import '../../data/module.dart';
import '../../widgets/topic_row.dart';

class ModuleDetailsScreen extends StatelessWidget {
  final String moduleId;
  const ModuleDetailsScreen({super.key, required this.moduleId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      buildWhen: (previous, current) => previous.modulesEx != current.modulesEx,
      builder: (context, state) {
        Module? module;
        for (final m in state.modulesEx) {
          if (m.id == moduleId) {
            module = m;
            break;
          }
        }
        if (module == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Модуль удалён или не найден')),
          );
        }
        final m = module;
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
          body: SafeArea(
            child: ListView(
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
                title: 'Теория',
                items: m.topics,
                onToggle: (i, v) => context.read<AppCubit>().toggleTopic(moduleId, true, i, v),
                onDelete: (i) => context.read<AppCubit>().deleteTopic(moduleId, true, i),
              ),
              _section(
                title: 'Практика',
                items: m.practices,
                onToggle: (i, v) => context.read<AppCubit>().toggleTopic(moduleId, false, i, v),
                onDelete: (i) => context.read<AppCubit>().deleteTopic(moduleId, false, i),
              ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _section({
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

  void _rename(BuildContext context, Module module) {
    final controller = TextEditingController(text: module.title);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Переименовать модуль'),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'Название')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                context.read<AppCubit>().renameModule(module.id, text);
              }
              Navigator.pop(context);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _addItem(BuildContext context) {
    final controller = TextEditingController();
    bool isTopic = true;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Новый пункт'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: controller, decoration: const InputDecoration(labelText: 'Название')),
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
              final text = controller.text.trim();
              if (text.isEmpty) return;
              context.read<AppCubit>().addTopic(moduleId, isTopic, text);
              Navigator.pop(context);
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }

  String _type(ModuleType type) => switch (type) {
        ModuleType.lecture => 'лекция',
        ModuleType.practice => 'практика',
        ModuleType.lab => 'лабораторная',
      };

  String _status(ModuleStatus status) => switch (status) {
        ModuleStatus.notStarted => 'не начат',
        ModuleStatus.inProgress => 'в процессе',
        ModuleStatus.completed => 'завершён',
      };
}
