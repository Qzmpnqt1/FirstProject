import '../../api/open_library_api.dart';
import '../../models/remote/open_library_dto.dart';

/// Data source для работы с OpenLibrary API
class OpenLibraryRemoteDataSource {
  final OpenLibraryApi _api;

  OpenLibraryRemoteDataSource(this._api);

  /// Поиск книг
  Future<List<BookDocDto>> searchBooks(String query) async {
    final response = await _api.searchBooks(query, 10);
    return response.docs;
  }

  /// Получение деталей работы
  Future<WorkDetailDto> getWorkDetail(String workId) async {
    return await _api.getWorkDetail(workId);
  }
}

