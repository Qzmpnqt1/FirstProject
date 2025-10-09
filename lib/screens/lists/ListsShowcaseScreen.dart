import 'package:flutter/material.dart';
import '../../app/app_state.dart';
import '../../app/app_colors.dart';

class ListsShowcaseScreen extends StatefulWidget {
  final AppState state;
  const ListsShowcaseScreen({super.key, required this.state});

  @override
  State<ListsShowcaseScreen> createState() => _ListsShowcaseScreenState();
}

class _ListsShowcaseScreenState extends State<ListsShowcaseScreen> with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 3, vsync: this);
  final input = TextEditingController();

  @override
  void dispose() {
    input.dispose();
    _tab.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final text = input.text.trim();
    if (text.isEmpty) return;
    await widget.state.addModule(text);
    input.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Списки учебных модулей'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: 'Column'),
            Tab(text: 'ListView.builder'),
            Tab(text: 'ListView.separated'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Панель добавления
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: input,
                    decoration: const InputDecoration(
                      hintText: 'Новый модуль...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                    ),
                    onSubmitted: (_) => _add(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _add,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Добавить'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                _ColumnList(state: widget.state),
                _BuilderList(state: widget.state),
                _SeparatedList(state: widget.state),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ------------- 1) Column + SingleChildScrollView -------------
class _ColumnList extends StatelessWidget {
  final AppState state;
  const _ColumnList({required this.state});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: state.modules,
      builder: (_, modules, __) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
          child: Column(
            children: [
              for (int i = 0; i < modules.length; i++)
                Dismissible(
                  key: ValueKey('col_${modules[i]}_$i'), // КЛЮЧ — решает проблему «удаления не последнего»
                  background: _bg(Alignment.centerLeft),
                  secondaryBackground: _bg(Alignment.centerRight),
                  onDismissed: (_) => state.deleteModuleAt(i),
                  child: Card(
                    child: ListTile(
                      leading: const Icon(Icons.menu_book_rounded, color: AppColors.primary),
                      title: Text(modules[i]),
                      trailing: IconButton(
                        tooltip: 'Удалить',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => state.deleteModuleAt(i),
                      ),
                    ),
                  ),
                ),
              if (modules.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Пусто. Добавьте первый модуль выше.'),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _bg(Alignment a) => Container(
    decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(16)),
    alignment: a,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: const Icon(Icons.delete, color: Colors.white),
  );
}

// ------------- 2) ListView.builder -------------
class _BuilderList extends StatelessWidget {
  final AppState state;
  const _BuilderList({required this.state});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: state.modules,
      builder: (_, modules, __) {
        if (modules.isEmpty) {
          return const Center(child: Text('Пусто. Добавьте модуль.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
          itemCount: modules.length,
          itemBuilder: (_, i) => Dismissible(
            key: ValueKey('b_${modules[i]}_$i'),
            background: _bg(Alignment.centerLeft),
            secondaryBackground: _bg(Alignment.centerRight),
            onDismissed: (_) => state.deleteModuleAt(i),
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.library_books_rounded, color: AppColors.primary),
                title: Text(modules[i]),
                trailing: IconButton(
                  tooltip: 'Удалить',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => state.deleteModuleAt(i),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _bg(Alignment a) => Container(
    decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(16)),
    alignment: a,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: const Icon(Icons.delete, color: Colors.white),
  );
}

// ------------- 3) ListView.separated -------------
class _SeparatedList extends StatelessWidget {
  final AppState state;
  const _SeparatedList({required this.state});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: state.modules,
      builder: (_, modules, __) {
        if (modules.isEmpty) {
          return const Center(child: Text('Пусто. Добавьте модуль.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
          itemCount: modules.length,
          separatorBuilder: (_, __) => const SizedBox(height: 6),
          itemBuilder: (_, i) => Dismissible(
            key: ValueKey('s_${modules[i]}_$i'),
            background: _bg(Alignment.centerLeft),
            secondaryBackground: _bg(Alignment.centerRight),
            onDismissed: (_) => state.deleteModuleAt(i),
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.school_rounded, color: AppColors.primary),
                title: Text(modules[i]),
                subtitle: Text('Модуль №${i + 1} из ${modules.length}'),
                trailing: IconButton(
                  tooltip: 'Удалить',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => state.deleteModuleAt(i),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _bg(Alignment a) => Container(
    decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(16)),
    alignment: a,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: const Icon(Icons.delete, color: Colors.white),
  );
}
