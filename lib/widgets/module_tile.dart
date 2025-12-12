import 'package:flutter/material.dart';
import '../app/app_colors.dart';
import '../domain/entities/module_entity.dart';

class ModuleTile extends StatelessWidget {
  final ModuleEntity module;
  final VoidCallback onOpen;
  final VoidCallback onDelete;
  final Key? tileKey;

  const ModuleTile({
    super.key,
    required this.module,
    required this.onOpen,
    required this.onDelete,
    this.tileKey,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: tileKey ?? ValueKey(module.id),
      background: const _SwipeBg(left: true),
      secondaryBackground: const _SwipeBg(left: false),
      onDismissed: (_) => onDelete(),
      child: Card(
        child: ListTile(
          leading: Icon(_iconByType(module.type), color: AppColors.primary),
          title: Text(module.title),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Часы: ${module.hours} • Статус: ${_statusName(module.status)}'),
              const SizedBox(height: 6),
              LinearProgressIndicator(value: module.progress),
            ],
          ),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: onOpen,
        ),
      ),
    );
  }

  IconData _iconByType(ModuleType t) => switch (t) {
    ModuleType.lecture => Icons.menu_book_rounded,
    ModuleType.practice => Icons.task_alt_rounded,
    ModuleType.lab => Icons.science_rounded,
  };

  String _statusName(ModuleStatus s) => switch (s) {
    ModuleStatus.notStarted => 'не начат',
    ModuleStatus.inProgress => 'в процессе',
    ModuleStatus.completed => 'завершён',
  };
}

class _SwipeBg extends StatelessWidget {
  final bool left;
  const _SwipeBg({required this.left});
  @override
  Widget build(BuildContext context) => Container(
    alignment: left ? Alignment.centerLeft : Alignment.centerRight,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    decoration: BoxDecoration(
      color: Colors.redAccent,
      borderRadius: BorderRadius.circular(16),
    ),
    child: const Icon(Icons.delete, color: Colors.white),
  );
}
