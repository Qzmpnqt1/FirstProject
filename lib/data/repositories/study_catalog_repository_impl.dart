import '../../domain/entities/study_resource_entity.dart';
import '../../domain/entities/study_topic_entity.dart';
import '../../domain/repositories/study_catalog_repository.dart';
import '../datasources/remote/open_alex_remote_data_source.dart';
import '../datasources/remote/open_library_remote_data_source.dart';
import '../models/remote/open_alex_dto.dart';
import '../models/remote/open_library_dto.dart';

/// Реализация репозитория каталога учебных материалов
class StudyCatalogRepositoryImpl implements StudyCatalogRepository {
  final OpenAlexRemoteDataSource _openAlexDataSource;
  final OpenLibraryRemoteDataSource _openLibraryDataSource;

  StudyCatalogRepositoryImpl(
    this._openAlexDataSource,
    this._openLibraryDataSource,
  );

  @override
  Future<List<StudyTopicEntity>> searchTopics(String query) async {
    final concepts = await _openAlexDataSource.searchConcepts(query);
    return concepts.map((dto) => _mapConceptToEntity(dto)).toList();
  }

  @override
  Future<StudyTopicEntity> getTopicDetail(String id) async {
    final concept = await _openAlexDataSource.getConceptDetail(id);
    return _mapConceptToEntity(concept);
  }

  @override
  Future<List<StudyResourceEntity>> getTopicWorks(String topicId) async {
    final works = await _openAlexDataSource.getWorksByConcept(topicId);
    return works.map((dto) => _mapWorkToEntity(dto)).toList();
  }

  @override
  Future<List<StudyResourceEntity>> searchBooks(String query) async {
    final books = await _openLibraryDataSource.searchBooks(query);
    return books.map((dto) => _mapBookDocToEntity(dto)).toList();
  }

  @override
  Future<StudyResourceEntity> getBookDetail(String workId) async {
    // Извлекаем только ID из ключа (убираем префикс /works/ если есть)
    final cleanWorkId = workId.startsWith('/works/')
        ? workId.substring(7) // Убираем '/works/'
        : workId.startsWith('works/')
            ? workId.substring(6) // Убираем 'works/'
            : workId;
    
    final detail = await _openLibraryDataSource.getWorkDetail(cleanWorkId);
    return _mapWorkDetailToEntity(workId, detail);
  }

  /// Маппинг ConceptDto -> StudyTopicEntity
  StudyTopicEntity _mapConceptToEntity(ConceptDto dto) {
    return StudyTopicEntity(
      id: dto.id,
      title: dto.displayName,
      description: dto.description,
      level: dto.level,
      worksCount: dto.worksCount,
      citedByCount: dto.citedByCount,
      source: 'OpenAlex',
    );
  }

  /// Маппинг WorkDto -> StudyResourceEntity
  StudyResourceEntity _mapWorkToEntity(WorkDto dto) {
    return StudyResourceEntity(
      id: dto.id,
      title: dto.displayName ?? 'Untitled',
      year: dto.publicationYear,
      citedByCount: dto.citedByCount,
      source: 'OpenAlex',
    );
  }

  /// Маппинг BookDocDto -> StudyResourceEntity
  StudyResourceEntity _mapBookDocToEntity(BookDocDto dto) {
    return StudyResourceEntity(
      id: dto.key,
      title: dto.title ?? 'Untitled',
      authors: dto.authorName,
      year: dto.firstPublishYear,
      source: 'OpenLibrary',
    );
  }

  /// Маппинг WorkDetailDto -> StudyResourceEntity
  StudyResourceEntity _mapWorkDetailToEntity(String workId, WorkDetailDto dto) {
    return StudyResourceEntity(
      id: workId,
      title: dto.title ?? 'Untitled',
      description: dto.descriptionText,
      subjects: dto.subjects,
      year: dto.firstPublishDate != null
          ? int.tryParse(dto.firstPublishDate!.substring(0, 4))
          : null,
      source: 'OpenLibrary',
    );
  }
}

