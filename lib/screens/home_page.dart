import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../app/app_state.dart';
import '../app/app_colors.dart';
import '../data/task.dart';
import '../widgets/task_tile.dart';
import 'lists/lists_showcase_screen.dart';

class HomePage extends StatefulWidget {
  final AppState state;
  const HomePage({super.key, required this.state});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final input = TextEditingController();
  final search = TextEditingController();

  // Плоская иконка ноутбука (Twemoji, PNG)
  static const _homeBannerUrl =
      'https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4bb.png';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await precacheImage(CachedNetworkImageProvider(_homeBannerUrl), context);
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      children: [
        // Шапка
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.school_rounded, color: Colors.white, size: 40),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Практическая работа №3\nFlutter Widgets Showcase',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ),
                  ValueListenableBuilder<int>(
                    valueListenable: widget.state.counter,
                    builder: (_, v, __) => Chip(
                      label: Text('Счётчик: $v',
                          style: const TextStyle(color: Colors.white)),
                      backgroundColor: Colors.black26,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 8),
              // (1) Мини-баннер — «ноутбук/код»
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  height: 80,
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: _homeBannerUrl,
                    fit: BoxFit.contain,
                    placeholder: (_, __) => Container(color: Colors.white24),
                    errorWidget: (_, __, ___) => Container(
                      color: Colors.white24,
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image_rounded, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Списки витрина (как было)
        Card(
          child: ListTile(
            leading: const Icon(Icons.view_list_rounded, color: AppColors.primary),
            title: const Text('Витрина списков (Column / ListView)'),
            subtitle: const Text('Три подхода к спискам + добавление/удаление'),
            trailing: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ListsShowcaseScreen(state: widget.state),
                ));
              },
              child: const Text('Открыть'),
            ),
          ),
        ),

        // Поиск
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: search,
              decoration: InputDecoration(
                hintText: 'Поиск по задачам...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: search,
                  builder: (_, val, __) => val.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => search.clear(),
                  )
                      : const SizedBox.shrink(),
                ),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
        ),

        // Добавление
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: input,
                    decoration: const InputDecoration(
                      hintText: 'Новая задача...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    onSubmitted: (_) async {
                      if (input.text.trim().isEmpty) return;
                      await widget.state.addTask(input.text.trim());
                      input.clear();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (input.text.trim().isEmpty) return;
                    await widget.state.addTask(input.text.trim());
                    input.clear();
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Добавить'),
                ),
              ],
            ),
          ),
        ),

        // Список задач
        ValueListenableBuilder<List<Task>>(
          valueListenable: widget.state.tasks,
          builder: (_, tasks, __) {
            final query = search.text.trim().toLowerCase();
            final filtered = query.isEmpty
                ? tasks
                : tasks.where((t) => t.title.toLowerCase().contains(query)).toList();
            return Column(
              children: [
                for (var i = 0; i < filtered.length; i++)
                  TaskTile(
                    task: filtered[i],
                    onToggle: (v) async {
                      final idx = tasks.indexOf(filtered[i]);
                      if (idx != -1) await widget.state.toggleTask(idx, v);
                    },
                    onDelete: () async {
                      final idx = tasks.indexOf(filtered[i]);
                      if (idx != -1) await widget.state.deleteTask(idx);
                    },
                  ),
                if (tasks.any((t) => t.done))
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: OutlinedButton.icon(
                      onPressed: widget.state.clearDone,
                      icon: const Icon(Icons.cleaning_services_rounded),
                      label: const Text('Очистить выполненные'),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
