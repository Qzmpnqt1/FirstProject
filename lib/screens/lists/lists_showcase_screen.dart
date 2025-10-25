import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

  // Плоская иконка «книги»
  static const _modulesUrl =
      'https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4da.png';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await precacheImage(CachedNetworkImageProvider(_modulesUrl), context);
      } catch (_) {}
    });
  }

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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 32,
                height: 32,
                child: CachedNetworkImage(
                  imageUrl: _modulesUrl,
                  fit: BoxFit.contain,
                  placeholder: (_, __) => Container(color: Color(0xFFE2E8F0)),
                  errorWidget: (_, __, ___) => const Icon(Icons.menu_book_rounded),
                ),
              ),
            ),
          ),
        ],
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

// ----- остальной код списков (без изменений) -----
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
                  key: ValueKey('col_${modules[i]}_$i'),
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
