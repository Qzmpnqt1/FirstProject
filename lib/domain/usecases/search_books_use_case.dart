import '../entities/study_resource_entity.dart';
import '../repositories/study_catalog_repository.dart';

/// Use case для поиска книг
class SearchBooksUseCase {
  final StudyCatalogRepository _repository;

  SearchBooksUseCase(this._repository);

  Future<List<StudyResourceEntity>> call(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }
    return await _repository.searchBooks(query.trim());
  }
}

