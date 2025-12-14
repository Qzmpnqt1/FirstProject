import 'package:flutter/material.dart';
import '../../../domain/entities/study_resource_entity.dart';
import '../../../domain/entities/study_topic_entity.dart';
import '../../../domain/usecases/get_book_detail_use_case.dart';
import '../../../domain/usecases/get_topic_detail_use_case.dart';
import '../../../domain/usecases/get_topic_works_use_case.dart';
import '../../../domain/usecases/search_books_use_case.dart';
import '../../../domain/usecases/search_topics_use_case.dart';

class CatalogPage extends StatefulWidget {
  final SearchTopicsUseCase searchTopicsUseCase;
  final GetTopicDetailUseCase getTopicDetailUseCase;
  final GetTopicWorksUseCase getTopicWorksUseCase;
  final SearchBooksUseCase searchBooksUseCase;
  final GetBookDetailUseCase getBookDetailUseCase;

  const CatalogPage({
    super.key,
    required this.searchTopicsUseCase,
    required this.getTopicDetailUseCase,
    required this.getTopicWorksUseCase,
    required this.searchBooksUseCase,
    required this.getBookDetailUseCase,
  });

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  
  List<StudyTopicEntity> _topics = [];
  List<StudyResourceEntity> _books = [];
  bool _isLoadingTopics = false;
  bool _isLoadingBooks = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _topics = [];
        _books = [];
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    // Поиск тем
    if (_tabController.index == 0 || _topics.isEmpty) {
      setState(() => _isLoadingTopics = true);
      try {
        final topics = await widget.searchTopicsUseCase(query);
        setState(() {
          _topics = topics;
          _isLoadingTopics = false;
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'Ошибка поиска тем: ${e.toString()}';
          _isLoadingTopics = false;
        });
      }
    }

    // Поиск книг
    if (_tabController.index == 1 || _books.isEmpty) {
      setState(() => _isLoadingBooks = true);
      try {
        final books = await widget.searchBooksUseCase(query);
        setState(() {
          _books = books;
          _isLoadingBooks = false;
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'Ошибка поиска книг: ${e.toString()}';
          _isLoadingBooks = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Каталог материалов'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Темы (OpenAlex)', icon: Icon(Icons.topic_rounded)),
            Tab(text: 'Книги (OpenLibrary)', icon: Icon(Icons.book_rounded)),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Поиск',
                      hintText: 'Введите запрос...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _search,
                  icon: const Icon(Icons.search_rounded),
                  label: const Text('Найти'),
                ),
              ],
            ),
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTopicsTab(),
                _buildBooksTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicsTab() {
    if (_isLoadingTopics) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_topics.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.topic_rounded, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Введите запрос для поиска тем',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _topics.length,
      itemBuilder: (context, index) {
        final topic = _topics[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Icon(Icons.topic_rounded, color: Colors.blue.shade700),
            ),
            title: Text(topic.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (topic.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    topic.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  children: [
                    if (topic.level != null)
                      Chip(
                        label: Text('Уровень: ${topic.level}'),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    if (topic.worksCount != null)
                      Chip(
                        label: Text('Работ: ${topic.worksCount}'),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                  ],
                ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showTopicDetail(topic),
          ),
        );
      },
    );
  }

  Widget _buildBooksTab() {
    if (_isLoadingBooks) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_books.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_rounded, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Введите запрос для поиска книг',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _books.length,
      itemBuilder: (context, index) {
        final book = _books[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.shade100,
              child: Icon(Icons.book_rounded, color: Colors.green.shade700),
            ),
            title: Text(book.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (book.authors != null && book.authors!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('Авторы: ${book.authors!.join(', ')}'),
                ],
                if (book.year != null) ...[
                  const SizedBox(height: 4),
                  Text('Год: ${book.year}'),
                ],
              ],
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showBookDetail(book),
          ),
        );
      },
    );
  }

  Future<void> _showTopicDetail(StudyTopicEntity topic) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final detail = await widget.getTopicDetailUseCase(topic.id);
      final works = await widget.getTopicWorksUseCase(topic.id);

      if (!mounted) return;
      Navigator.pop(context); // Закрываем индикатор загрузки

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(detail.title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (detail.description != null) ...[
                  Text(
                    detail.description!,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                ],
                if (detail.level != null)
                  Text('Уровень: ${detail.level}'),
                if (detail.worksCount != null)
                  Text('Всего работ: ${detail.worksCount}'),
                if (detail.citedByCount != null)
                  Text('Цитирований: ${detail.citedByCount}'),
                const SizedBox(height: 16),
                const Divider(),
                const Text(
                  'Связанные работы:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (works.isEmpty)
                  const Text('Работы не найдены', style: TextStyle(fontStyle: FontStyle.italic))
                else
                  ...works.take(5).map((work) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              work.title,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            if (work.year != null) Text('Год: ${work.year}'),
                            if (work.citedByCount != null)
                              Text('Цитирований: ${work.citedByCount}'),
                          ],
                        ),
                      )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Закрыть'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Закрываем индикатор загрузки
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: ${e.toString()}')),
      );
    }
  }

  Future<void> _showBookDetail(StudyResourceEntity book) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final detail = await widget.getBookDetailUseCase(book.id);

      if (!mounted) return;
      Navigator.pop(context); // Закрываем индикатор загрузки

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(detail.title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (detail.authors != null && detail.authors!.isNotEmpty)
                  Text('Авторы: ${detail.authors!.join(', ')}'),
                if (detail.year != null) Text('Год: ${detail.year}'),
                if (detail.description != null) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Описание:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(detail.description!),
                ],
                if (detail.subjects != null && detail.subjects!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Темы:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: detail.subjects!
                        .take(10)
                        .map((s) => Chip(
                              label: Text(s),
                              padding: EdgeInsets.zero,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Закрыть'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Закрываем индикатор загрузки
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: ${e.toString()}')),
      );
    }
  }
}

