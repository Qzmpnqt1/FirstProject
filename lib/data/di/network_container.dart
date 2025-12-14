import 'package:dio/dio.dart';
import '../api/open_alex_api.dart';
import '../api/open_library_api.dart';
import '../datasources/remote/dio_client.dart';
import '../datasources/remote/open_alex_remote_data_source.dart';
import '../datasources/remote/open_library_remote_data_source.dart';
import '../repositories/study_catalog_repository_impl.dart';
import '../../domain/repositories/study_catalog_repository.dart';
import '../../domain/usecases/get_book_detail_use_case.dart';
import '../../domain/usecases/get_topic_detail_use_case.dart';
import '../../domain/usecases/get_topic_works_use_case.dart';
import '../../domain/usecases/search_books_use_case.dart';
import '../../domain/usecases/search_topics_use_case.dart';

/// Контейнер зависимостей для сетевого слоя
class NetworkContainer {
  late final OpenAlexDioClient _openAlexDioClient;
  late final OpenLibraryDioClient _openLibraryDioClient;
  late final OpenAlexApi _openAlexApi;
  late final OpenLibraryApi _openLibraryApi;
  late final OpenAlexRemoteDataSource _openAlexDataSource;
  late final OpenLibraryRemoteDataSource _openLibraryDataSource;
  late final StudyCatalogRepository _catalogRepository;
  late final SearchTopicsUseCase _searchTopicsUseCase;
  late final GetTopicDetailUseCase _getTopicDetailUseCase;
  late final GetTopicWorksUseCase _getTopicWorksUseCase;
  late final SearchBooksUseCase _searchBooksUseCase;
  late final GetBookDetailUseCase _getBookDetailUseCase;

  NetworkContainer() {
    _initialize();
  }

  void _initialize() {
    // Dio клиенты
    _openAlexDioClient = OpenAlexDioClient();
    _openLibraryDioClient = OpenLibraryDioClient();

    // Retrofit API клиенты
    _openAlexApi = OpenAlexApi(_openAlexDioClient.dio);
    _openLibraryApi = OpenLibraryApi(_openLibraryDioClient.dio);

    // Data sources
    _openAlexDataSource = OpenAlexRemoteDataSource(_openAlexApi);
    _openLibraryDataSource = OpenLibraryRemoteDataSource(_openLibraryApi);

    // Repository
    _catalogRepository = StudyCatalogRepositoryImpl(
      _openAlexDataSource,
      _openLibraryDataSource,
    );

    // Use cases
    _searchTopicsUseCase = SearchTopicsUseCase(_catalogRepository);
    _getTopicDetailUseCase = GetTopicDetailUseCase(_catalogRepository);
    _getTopicWorksUseCase = GetTopicWorksUseCase(_catalogRepository);
    _searchBooksUseCase = SearchBooksUseCase(_catalogRepository);
    _getBookDetailUseCase = GetBookDetailUseCase(_catalogRepository);
  }

  // Getters для use cases
  SearchTopicsUseCase get searchTopicsUseCase => _searchTopicsUseCase;
  GetTopicDetailUseCase get getTopicDetailUseCase => _getTopicDetailUseCase;
  GetTopicWorksUseCase get getTopicWorksUseCase => _getTopicWorksUseCase;
  SearchBooksUseCase get searchBooksUseCase => _searchBooksUseCase;
  GetBookDetailUseCase get getBookDetailUseCase => _getBookDetailUseCase;
}

