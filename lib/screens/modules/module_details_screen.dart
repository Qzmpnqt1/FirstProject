import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/app_colors.dart';
import '../../presentation/bloc/app_cubit.dart';
import '../../presentation/bloc/app_state.dart';
import '../../domain/entities/module_entity.dart';
import '../../widgets/topic_row.dart';

class ModuleDetailsScreen extends StatelessWidget {
  final String moduleId;
  const ModuleDetailsScreen({super.key, required this.moduleId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      buildWhen: (previous, current) => previous.modulesEx != current.modulesEx,
      builder: (context, state) {
        ModuleEntity? module;
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
              PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: const ListTile(
                      leading: Icon(Icons.edit_rounded),
                      title: Text('Переименовать'),
                      contentPadding: EdgeInsets.zero,
                    ),
                    onTap: () => Future.delayed(
                      const Duration(milliseconds: 100),
                      () => _rename(context, m),
                    ),
                  ),
                  PopupMenuItem(
                    child: ListTile(
                      leading: const Icon(Icons.flag_rounded),
                      title: const Text('Приоритет'),
                      subtitle: Text(_priorityName(m.priority)),
                      contentPadding: EdgeInsets.zero,
                    ),
                    onTap: () => Future.delayed(
                      const Duration(milliseconds: 100),
                      () => _editPriority(context, m),
                    ),
                  ),
                ],
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'module_details_fab',
            onPressed: () => _addItem(context),
            icon: const Icon(Icons.add),
            label: const Text('Тема/практика'),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircularProgressIndicator(value: m.progress),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Прогресс: $progressPercent%',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text('Тип: ${_type(m.type)} • Часы: ${m.hours} • Статус: ${_status(m.status)}'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (m.deadline != null) ...[
                        const Divider(),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            m.isOverdue ? Icons.warning_rounded : Icons.event_rounded,
                            color: m.isOverdue ? Colors.red : AppColors.primary,
                          ),
                          title: Text(m.isOverdue ? 'Просрочен' : 'Дедлайн'),
                          subtitle: Text(
                            '${m.deadline!.day}.${m.deadline!.month}.${m.deadline!.year}'
                            '${m.daysUntilDeadline >= 0 ? ' (через ${m.daysUntilDeadline} дн.)' : ''}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editDeadline(context, m),
                          ),
                        ),
                      ],
                      if (m.grade != null) ...[
                        const Divider(),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.grade_rounded, color: AppColors.accent),
                          title: Text('Оценка: ${m.grade}%'),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editGrade(context, m),
                          ),
                        ),
                      ],
                      if (m.description != null && m.description!.isNotEmpty) ...[
                        const Divider(),
                        Text('Описание:', style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 4),
                        Text(m.description!),
                      ],
                    ],
                  ),
                ),
              ),
              if (m.notes != null && m.notes!.isNotEmpty)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.note_rounded, color: AppColors.primary),
                    title: const Text('Заметки'),
                    subtitle: Text(m.notes!),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editModuleNotes(context, m),
                    ),
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
    required List<TopicItemEntity> items,
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

  void _rename(BuildContext context, ModuleEntity module) {
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
    // TODO: Handle this case.
    ModuleStatus.paused => throw UnimplementedError(),
  };

  String _priorityName(ModulePriority priority) => switch (priority) {
    ModulePriority.low => 'Низкий',
    ModulePriority.medium => 'Средний',
    ModulePriority.high => 'Высокий',
    ModulePriority.urgent => 'Срочный',
  };

  void _editDeadline(BuildContext context, ModuleEntity module) {
    DateTime? newDeadline = module.deadline;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (_, setState) => AlertDialog(
          title: const Text('Изменить дедлайн'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(newDeadline == null
                    ? 'Не установлен'
                    : '${newDeadline!.day}.${newDeadline!.month}.${newDeadline!.year}'),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: newDeadline ?? DateTime.now().add(const Duration(days: 7)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() => newDeadline = picked);
                    }
                  },
                ),
              ),
              TextButton(
                onPressed: () => setState(() => newDeadline = null),
                child: const Text('Удалить дедлайн'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
            ElevatedButton(
              onPressed: () {
                context.read<AppCubit>().updateModuleDeadline(module.id, newDeadline);
                Navigator.pop(context);
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }

  void _editGrade(BuildContext context, ModuleEntity module) {
    final controller = TextEditingController(text: module.grade?.toString() ?? '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Изменить оценку'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Оценка (0-100)',
            helperText: 'Оставьте пустым, чтобы удалить',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () {
              final grade = controller.text.trim().isEmpty
                  ? null
                  : int.tryParse(controller.text.trim());
              if (grade != null && (grade < 0 || grade > 100)) return;
              context.read<AppCubit>().updateModuleGrade(module.id, grade);
              Navigator.pop(context);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _editModuleNotes(BuildContext context, ModuleEntity module) {
    final controller = TextEditingController(text: module.notes ?? '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Заметки к модулю'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Заметки',
            hintText: 'Введите заметки...',
          ),
          maxLines: 5,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () {
              context.read<AppCubit>().updateModuleNotes(
                    module.id,
                    controller.text.trim().isEmpty ? null : controller.text.trim(),
                  );
              Navigator.pop(context);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _editPriority(BuildContext context, ModuleEntity module) {
    ModulePriority selectedPriority = module.priority;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (_, setState) => AlertDialog(
          title: const Text('Изменить приоритет'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ModulePriority>(
                title: const Text('Низкий'),
                value: ModulePriority.low,
                groupValue: selectedPriority,
                onChanged: (v) => setState(() => selectedPriority = v!),
              ),
              RadioListTile<ModulePriority>(
                title: const Text('Средний'),
                value: ModulePriority.medium,
                groupValue: selectedPriority,
                onChanged: (v) => setState(() => selectedPriority = v!),
              ),
              RadioListTile<ModulePriority>(
                title: const Text('Высокий'),
                value: ModulePriority.high,
                groupValue: selectedPriority,
                onChanged: (v) => setState(() => selectedPriority = v!),
              ),
              RadioListTile<ModulePriority>(
                title: const Text('Срочный'),
                value: ModulePriority.urgent,
                groupValue: selectedPriority,
                onChanged: (v) => setState(() => selectedPriority = v!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
            ElevatedButton(
              onPressed: () {
                context.read<AppCubit>().updateModulePriority(module.id, selectedPriority);
                Navigator.pop(context);
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
}
