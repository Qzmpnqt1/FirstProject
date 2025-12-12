import 'package:flutter/material.dart';
import '../app/app_colors.dart';
import '../domain/entities/task_entity.dart';

class TaskTile extends StatelessWidget {
  final TaskEntity task;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;
  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('${task.title}_${task.done}'),
      background: _swipeBg(Alignment.centerLeft),
      secondaryBackground: _swipeBg(Alignment.centerRight),
      onDismissed: (_) => onDelete(),
      child: Card(
        child: CheckboxListTile(
          value: task.done,
          onChanged: (v) => onToggle(v ?? false),
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.done ? TextDecoration.lineThrough : null,
              color: task.done ? Colors.grey : null,
            ),
          ),
          secondary:
          const Icon(Icons.checklist_rounded, color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _swipeBg(Alignment a) => Container(
    decoration: BoxDecoration(
        color: Colors.redAccent, borderRadius: BorderRadius.circular(16)),
    alignment: a,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: const Icon(Icons.delete, color: Colors.white),
  );
}