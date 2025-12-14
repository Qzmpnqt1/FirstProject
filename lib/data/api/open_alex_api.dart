import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/remote/open_alex_dto.dart';

part 'open_alex_api.g.dart';

@RestApi(baseUrl: 'https://api.openalex.org/')
abstract class OpenAlexApi {
  factory OpenAlexApi(Dio dio, {String? baseUrl, ParseErrorLogger? errorLogger}) = _OpenAlexApi;

  /// Поиск концептов (тем) по запросу
  @GET('/concepts')
  Future<ConceptSearchResponseDto> searchConcepts(
    @Query('search') String query,
    @Query('per_page') int perPage,
  );

  /// Получение деталей концепта по ID
  @GET('/concepts/{id}')
  Future<ConceptDto> getConceptDetail(
    @Path('id') String id,
  );

  /// Получение работ (works) по концепту
  @GET('/works')
  Future<WorkSearchResponseDto> getWorksByConcept(
    @Query('filter') String filter,
    @Query('per_page') int perPage,
  );
}

