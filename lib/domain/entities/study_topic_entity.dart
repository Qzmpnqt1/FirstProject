/// Сущность темы для изучения из OpenAlex
class StudyTopicEntity {
  final String id;
  final String title;
  final String? description;
  final int? level;
  final int? worksCount;
  final int? citedByCount;
  final String source;

  StudyTopicEntity({
    required this.id,
    required this.title,
    this.description,
    this.level,
    this.worksCount,
    this.citedByCount,
    this.source = 'OpenAlex',
  });
}

