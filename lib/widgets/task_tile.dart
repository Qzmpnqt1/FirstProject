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
        elevation: task.done ? 1 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: task.done ? AppColors.primary.withOpacity(0.05) : null,
          ),
          child: CheckboxListTile(
            value: task.done,
            onChanged: (v) => onToggle(v ?? false),
            title: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                decoration: task.done ? TextDecoration.lineThrough : null,
                color: task.done ? AppColors.textSecondary : AppColors.textPrimary,
                fontSize: 16,
              ),
              child: Text(task.title),
            ),
            secondary: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: task.done
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                task.done ? Icons.check_circle_rounded : Icons.checklist_rounded,
                color: task.done ? AppColors.primary : AppColors.primary,
                size: 20,
              ),
            ),
          ),
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