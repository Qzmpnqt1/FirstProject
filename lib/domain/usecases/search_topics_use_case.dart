import '../entities/study_topic_entity.dart';
import '../repositories/study_catalog_repository.dart';

/// Use case для поиска тем
class SearchTopicsUseCase {
  final StudyCatalogRepository _repository;

  SearchTopicsUseCase(this._repository);

  Future<List<StudyTopicEntity>> call(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }
    return await _repository.searchTopics(query.trim());
  }
}

