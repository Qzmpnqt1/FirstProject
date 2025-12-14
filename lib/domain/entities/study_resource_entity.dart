/// Сущность ресурса для изучения (книга/публикация)
class StudyResourceEntity {
  final String id;
  final String title;
  final List<String>? authors;
  final int? year;
  final String? description;
  final List<String>? subjects;
  final String source; // 'OpenLibrary' или 'OpenAlex'
  final int? citedByCount;

  StudyResourceEntity({
    required this.id,
    required this.title,
    this.authors,
    this.year,
    this.description,
    this.subjects,
    this.source = 'OpenLibrary',
    this.citedByCount,
  });
}


