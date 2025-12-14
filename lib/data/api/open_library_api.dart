import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/remote/open_library_dto.dart';

part 'open_library_api.g.dart';

@RestApi(baseUrl: 'https://openlibrary.org/')
abstract class OpenLibraryApi {
  factory OpenLibraryApi(Dio dio, {String? baseUrl, ParseErrorLogger? errorLogger}) = _OpenLibraryApi;

  /// Поиск книг по запросу
  @GET('/search.json')
  Future<BookSearchResponseDto> searchBooks(
    @Query('q') String query,
    @Query('limit') int limit,
  );

  /// Получение деталей работы (книги) по workId
  @GET('/works/{workId}.json')
  Future<WorkDetailDto> getWorkDetail(
    @Path('workId') String workId,
  );
}

