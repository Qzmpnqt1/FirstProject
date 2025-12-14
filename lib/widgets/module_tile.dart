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
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: onOpen,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_iconByType(module.type), color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        module.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
              Row(
                children: [
                  _StatusChip(
                    icon: Icons.access_time_rounded,
                    label: '${module.hours}ч',
                  ),
                  const SizedBox(width: 8),
                  _StatusChip(
                    icon: Icons.circle,
                    label: _statusName(module.status),
                    color: _getStatusColor(module.status),
                  ),
                  if (module.deadline != null) ...[
                    const SizedBox(width: 8),
                    _StatusChip(
                      icon: module.isOverdue ? Icons.warning_rounded : Icons.event_rounded,
                      label: module.daysUntilDeadline >= 0
                          ? '${module.daysUntilDeadline}д'
                          : 'Просрочен',
                      color: module.isOverdue ? Colors.red : AppColors.primary,
                    ),
                  ],
                  const SizedBox(width: 8),
                  _PriorityChip(priority: module.priority),
                ],
              ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: module.progress.clamp(0, 1),
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
              ],
            ),
          ),
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

  Color _getStatusColor(ModuleStatus s) => switch (s) {
    ModuleStatus.notStarted => Colors.grey,
    ModuleStatus.inProgress => AppColors.accent,
    ModuleStatus.completed => Colors.green,
  };
}

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _StatusChip({
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (color ?? AppColors.textSecondary).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color ?? AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color ?? AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  final ModulePriority priority;

  const _PriorityChip({required this.priority});

  @override
  Widget build(BuildContext context) {
    final (color, label, icon) = switch (priority) {
      ModulePriority.low => (Colors.grey, 'Низкий', Icons.arrow_downward_rounded),
      ModulePriority.medium => (Colors.blue, 'Средний', Icons.remove_rounded),
      ModulePriority.high => (Colors.orange, 'Высокий', Icons.arrow_upward_rounded),
      ModulePriority.urgent => (Colors.red, 'Срочный', Icons.priority_high_rounded),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
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
