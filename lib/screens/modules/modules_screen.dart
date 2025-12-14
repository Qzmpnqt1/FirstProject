import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/app_colors.dart';
import '../../presentation/bloc/app_cubit.dart';
import '../../presentation/bloc/app_state.dart';
import '../../domain/entities/module_entity.dart';
import '../../widgets/modules_list_view.dart';
import 'module_details_screen.dart';

class ModulesScreen extends StatefulWidget {
  const ModulesScreen({super.key});

  @override
  State<ModulesScreen> createState() => _ModulesScreenState();
}

class _ModulesScreenState extends State<ModulesScreen> {
  String _filterStatus = 'all'; // all, notStarted, inProgress, completed
  String _sortBy = 'priority'; // priority, deadline, progress, title
  bool _showOverdue = false;

  List<ModuleEntity> _filterAndSort(List<ModuleEntity> modules) {
    // Создаем изменяемую копию списка
    var filtered = List<ModuleEntity>.from(modules);

    // Фильтр по статусу
    if (_filterStatus != 'all') {
      final status = _filterStatus == 'notStarted'
          ? ModuleStatus.notStarted
          : (_filterStatus == 'inProgress' 
              ? ModuleStatus.inProgress 
              : (_filterStatus == 'paused' 
                  ? ModuleStatus.paused 
                  : ModuleStatus.completed));
      filtered = filtered.where((m) => m.status == status).toList();
    }

    // Фильтр просроченных
    if (_showOverdue) {
      filtered = filtered.where((m) => m.isOverdue).toList();
    }

    // Сортировка (создаем новый список для сортировки)
    final sorted = List<ModuleEntity>.from(filtered);
    switch (_sortBy) {
      case 'priority':
        sorted.sort((a, b) {
          final priorityOrder = {
            ModulePriority.urgent: 0,
            ModulePriority.high: 1,
            ModulePriority.medium: 2,
            ModulePriority.low: 3,
          };
          return priorityOrder[a.priority]!.compareTo(priorityOrder[b.priority]!);
        });
        break;
      case 'deadline':
        sorted.sort((a, b) {
          if (a.deadline == null && b.deadline == null) return 0;
          if (a.deadline == null) return 1;
          if (b.deadline == null) return -1;
          return a.deadline!.compareTo(b.deadline!);
        });
        break;
      case 'progress':
        sorted.sort((a, b) => b.progress.compareTo(a.progress));
        break;
      case 'title':
        sorted.sort((a, b) => a.title.compareTo(b.title));
        break;
    }

    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Учебные модули'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            tooltip: 'Фильтры',
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'modules_fab',
        onPressed: () => _createModuleDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Новый модуль'),
      ),
      body: SafeArea(
        child: BlocBuilder<AppCubit, AppState>(
          buildWhen: (previous, current) => previous.modulesEx != current.modulesEx,
          builder: (_, state) {
            final filtered = _filterAndSort(state.modulesEx);
            
            if (filtered.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.school_outlined, size: 64, color: AppColors.primary.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    Text(
                      state.modulesEx.isEmpty ? 'Нет модулей' : 'Нет модулей по фильтру',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.modulesEx.isEmpty
                          ? 'Создайте первый учебный модуль'
                          : 'Попробуйте изменить фильтры',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                if (_filterStatus != 'all' || _showOverdue)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: AppColors.primary.withOpacity(0.1),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Показано: ${filtered.length} из ${state.modulesEx.length}',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _filterStatus = 'all';
                              _showOverdue = false;
                            });
                          },
                          child: const Text('Сбросить'),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: ModulesListView(
                    modules: filtered,
              onOpen: (m) {
                if (m.id.isNotEmpty) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ModuleDetailsScreen(moduleId: m.id),
                    ),
                  );
                }
              },
              onDelete: (m) {
                if (m.id.isNotEmpty) {
                  context.read<AppCubit>().deleteModuleEx(m.id);
                }
              },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Фильтры и сортировка'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Статус:', style: TextStyle(fontWeight: FontWeight.bold)),
              RadioListTile<String>(
                title: const Text('Все'),
                value: 'all',
                groupValue: _filterStatus,
                onChanged: (v) => setDialogState(() => _filterStatus = v!),
              ),
              RadioListTile<String>(
                title: const Text('Не начат'),
                value: 'notStarted',
                groupValue: _filterStatus,
                onChanged: (v) => setDialogState(() => _filterStatus = v!),
              ),
              RadioListTile<String>(
                title: const Text('В процессе'),
                value: 'inProgress',
                groupValue: _filterStatus,
                onChanged: (v) => setDialogState(() => _filterStatus = v!),
              ),
              RadioListTile<String>(
                title: const Text('На паузе'),
                value: 'paused',
                groupValue: _filterStatus,
                onChanged: (v) => setDialogState(() => _filterStatus = v!),
              ),
              RadioListTile<String>(
                title: const Text('Завершён'),
                value: 'completed',
                groupValue: _filterStatus,
                onChanged: (v) => setDialogState(() => _filterStatus = v!),
              ),
              const Divider(),
              const Text('Сортировка:', style: TextStyle(fontWeight: FontWeight.bold)),
              RadioListTile<String>(
                title: const Text('По приоритету'),
                value: 'priority',
                groupValue: _sortBy,
                onChanged: (v) => setDialogState(() => _sortBy = v!),
              ),
              RadioListTile<String>(
                title: const Text('По дедлайну'),
                value: 'deadline',
                groupValue: _sortBy,
                onChanged: (v) => setDialogState(() => _sortBy = v!),
              ),
              RadioListTile<String>(
                title: const Text('По прогрессу'),
                value: 'progress',
                groupValue: _sortBy,
                onChanged: (v) => setDialogState(() => _sortBy = v!),
              ),
              RadioListTile<String>(
                title: const Text('По названию'),
                value: 'title',
                groupValue: _sortBy,
                onChanged: (v) => setDialogState(() => _sortBy = v!),
              ),
              const Divider(),
              CheckboxListTile(
                title: const Text('Только просроченные'),
                value: _showOverdue,
                onChanged: (v) => setDialogState(() => _showOverdue = v ?? false),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {});
                Navigator.pop(context);
              },
              child: const Text('Применить'),
            ),
          ],
        ),
      ),
    );
  }

  void _createModuleDialog(BuildContext context) {
    final title = TextEditingController();
    final hours = TextEditingController(text: '4');
    final description = TextEditingController();
    ModuleType type = ModuleType.lecture;
    ModulePriority priority = ModulePriority.medium;
    DateTime? deadline;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
        title: const Text('Новый модуль'),
          content: SingleChildScrollView(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
                TextField(
                  controller: title,
                  decoration: const InputDecoration(labelText: 'Название *'),
                  autofocus: true,
                ),
                const SizedBox(height: 12),
            DropdownButtonFormField<ModuleType>(
              value: type,
              items: const [
                DropdownMenuItem(value: ModuleType.lecture, child: Text('Лекция')),
                DropdownMenuItem(value: ModuleType.practice, child: Text('Практика')),
                DropdownMenuItem(value: ModuleType.lab, child: Text('Лабораторная')),
              ],
                  onChanged: (v) => setDialogState(() => type = v ?? ModuleType.lecture),
              decoration: const InputDecoration(labelText: 'Тип'),
            ),
                const SizedBox(height: 12),
            TextField(
              controller: hours,
              keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Часы *'),
            ),
                const SizedBox(height: 12),
                DropdownButtonFormField<ModulePriority>(
                  value: priority,
                  items: const [
                    DropdownMenuItem(value: ModulePriority.low, child: Text('Низкий')),
                    DropdownMenuItem(value: ModulePriority.medium, child: Text('Средний')),
                    DropdownMenuItem(value: ModulePriority.high, child: Text('Высокий')),
                    DropdownMenuItem(value: ModulePriority.urgent, child: Text('Срочный')),
                  ],
                  onChanged: (v) => setDialogState(() => priority = v ?? ModulePriority.medium),
                  decoration: const InputDecoration(labelText: 'Приоритет'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: description,
                  decoration: const InputDecoration(labelText: 'Описание (необязательно)'),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Дедлайн'),
                  subtitle: Text(deadline == null
                      ? 'Не установлен'
                      : '${deadline!.day}.${deadline!.month}.${deadline!.year}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 7)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setDialogState(() => deadline = picked);
                      }
                    },
                  ),
                ),
              ],
            ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          ElevatedButton(
            onPressed: () {
              final h = int.tryParse(hours.text) ?? 0;
              if (title.text.trim().isEmpty || h <= 0) return;
                context.read<AppCubit>().addModuleEx(
                      title.text.trim(),
                      type,
                      h,
                      deadline: deadline,
                      priority: priority,
                      description: description.text.trim().isEmpty ? null : description.text.trim(),
                    );
              Navigator.pop(context);
            },
            child: const Text('Создать'),
          ),
        ],
        ),
      ),
    );
  }
}
