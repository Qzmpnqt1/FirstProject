import '../entities/study_topic_entity.dart';
import '../repositories/study_catalog_repository.dart';

/// Use case для получения деталей темы
class GetTopicDetailUseCase {
  final StudyCatalogRepository _repository;

  GetTopicDetailUseCase(this._repository);

  Future<StudyTopicEntity> call(String id) async {
    return await _repository.getTopicDetail(id);
  }
}

