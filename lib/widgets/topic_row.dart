import 'package:flutter/material.dart';
import '../data/module.dart';
import '../app/app_colors.dart';

class TopicRow extends StatelessWidget {
  final TopicItem item;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  const TopicRow({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: item.done,
      onChanged: (v) => onToggle(v ?? false),
      title: Text(item.title),
      secondary: IconButton(
        tooltip: 'Удалить',
        icon: const Icon(Icons.delete_outline, color: AppColors.textSecondary),
        onPressed: onDelete,
      ),
    );
  }
}
