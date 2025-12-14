import '../entities/study_resource_entity.dart';
import '../repositories/study_catalog_repository.dart';

/// Use case для получения работ по теме
class GetTopicWorksUseCase {
  final StudyCatalogRepository _repository;

  GetTopicWorksUseCase(this._repository);

  Future<List<StudyResourceEntity>> call(String topicId) async {
    return await _repository.getTopicWorks(topicId);
  }
}

