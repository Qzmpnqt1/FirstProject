import 'package:flutter/material.dart';
import '../domain/entities/module_entity.dart';
import 'module_tile.dart';

class ModulesListView extends StatelessWidget {
  final List<ModuleEntity> modules;
  final ValueChanged<ModuleEntity> onOpen;
  final ValueChanged<ModuleEntity> onDelete;
  final EdgeInsetsGeometry padding;

  const ModulesListView({
    super.key,
    required this.modules,
    required this.onOpen,
    required this.onDelete,
    this.padding = const EdgeInsets.fromLTRB(12, 0, 12, 24),
  });

  @override
  Widget build(BuildContext context) {
    if (modules.isEmpty) {
      return const Center(child: Text('Пока нет модулей — добавьте первый'));
    }
    return ListView.builder(
      padding: padding,
      itemCount: modules.length,
      itemBuilder: (_, i) {
        final m = modules[i];
        return ModuleTile(
          tileKey: ValueKey(m.id),
          module: m,
          onOpen: () => onOpen(m),
          onDelete: () => onDelete(m),
        );
      },
    );
  }
}
