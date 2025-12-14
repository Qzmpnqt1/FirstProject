import '../../api/open_alex_api.dart';
import '../../models/remote/open_alex_dto.dart';
import '../../../domain/entities/study_resource_entity.dart';
import '../../../domain/entities/study_topic_entity.dart';

/// Data source для работы с OpenAlex API
class OpenAlexRemoteDataSource {
  final OpenAlexApi _api;

  OpenAlexRemoteDataSource(this._api);

  /// Поиск концептов
  Future<List<ConceptDto>> searchConcepts(String query) async {
    final response = await _api.searchConcepts(query, 10);
    return response.results;
  }

  /// Получение деталей концепта
  Future<ConceptDto> getConceptDetail(String id) async {
    return await _api.getConceptDetail(id);
  }

  /// Получение работ по концепту
  Future<List<WorkDto>> getWorksByConcept(String conceptId) async {
    final response = await _api.getWorksByConcept('concept.id:$conceptId', 10);
    return response.results;
  }
}


