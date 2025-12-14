import '../entities/study_resource_entity.dart';
import '../repositories/study_catalog_repository.dart';

/// Use case для получения деталей книги
class GetBookDetailUseCase {
  final StudyCatalogRepository _repository;

  GetBookDetailUseCase(this._repository);

  Future<StudyResourceEntity> call(String workId) async {
    return await _repository.getBookDetail(workId);
  }
}


