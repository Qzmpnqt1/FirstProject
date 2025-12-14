import '../entities/study_resource_entity.dart';
import '../entities/study_topic_entity.dart';

/// Репозиторий для работы с каталогом учебных материалов
abstract class StudyCatalogRepository {
  /// Поиск тем по запросу
  Future<List<StudyTopicEntity>> searchTopics(String query);

  /// Получение деталей темы
  Future<StudyTopicEntity> getTopicDetail(String id);

  /// Получение работ по теме
  Future<List<StudyResourceEntity>> getTopicWorks(String topicId);

  /// Поиск книг по запросу
  Future<List<StudyResourceEntity>> searchBooks(String query);

  /// Получение деталей книги
  Future<StudyResourceEntity> getBookDetail(String workId);
}

