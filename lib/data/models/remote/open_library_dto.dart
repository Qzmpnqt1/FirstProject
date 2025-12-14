import 'package:json_annotation/json_annotation.dart';

part 'open_library_dto.g.dart';

/// Ответ на поиск книг
@JsonSerializable()
class BookSearchResponseDto {
  final int? numFound;
  final int? start;
  final List<BookDocDto> docs;

  BookSearchResponseDto({
    this.numFound,
    this.start,
    required this.docs,
  });

  factory BookSearchResponseDto.fromJson(Map<String, dynamic> json) =>
      _$BookSearchResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BookSearchResponseDtoToJson(this);
}

/// Документ книги из поиска
@JsonSerializable()
class BookDocDto {
  final String key;
  final String? title;
  @JsonKey(name: 'author_name')
  final List<String>? authorName;
  @JsonKey(name: 'first_publish_year')
  final int? firstPublishYear;
  @JsonKey(name: 'isbn')
  final List<String>? isbn;

  BookDocDto({
    required this.key,
    this.title,
    this.authorName,
    this.firstPublishYear,
    this.isbn,
  });

  factory BookDocDto.fromJson(Map<String, dynamic> json) =>
      _$BookDocDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BookDocDtoToJson(this);
}

/// Детали работы (книги)
@JsonSerializable()
class WorkDetailDto {
  final String? title;
  @JsonKey(fromJson: _descriptionFromJson)
  final String? description; // Может быть String, Map или List
  final List<String>? subjects;
  @JsonKey(name: 'first_publish_date')
  final String? firstPublishDate;
  @JsonKey(fromJson: _authorsFromJson)
  final Map<String, dynamic>? authors;

  WorkDetailDto({
    this.title,
    this.description,
    this.subjects,
    this.firstPublishDate,
    this.authors,
  });

  factory WorkDetailDto.fromJson(Map<String, dynamic> json) {
    // Используем кастомные парсеры для полей, которые могут быть разных типов
    return WorkDetailDto(
      title: json['title'] as String?,
      description: _descriptionFromJson(json['description']),
      subjects: (json['subjects'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      firstPublishDate: json['first_publish_date'] as String?,
      authors: _authorsFromJson(json['authors']),
    );
  }

  Map<String, dynamic> toJson() => _$WorkDetailDtoToJson(this);

  /// Получить описание как строку
  String? get descriptionText => description;

  /// Кастомный парсер для description (может быть String, Map или List)
  static String? _descriptionFromJson(dynamic json) {
    if (json == null) return null;
    if (json is String) return json;
    if (json is Map) {
      return json['value'] as String?;
    }
    if (json is List && json.isNotEmpty) {
      // Если это список, берем первый элемент
      final first = json.first;
      if (first is String) return first;
      if (first is Map) return first['value'] as String?;
    }
    return json.toString();
  }

  /// Кастомный парсер для authors (может быть Map или List)
  static Map<String, dynamic>? _authorsFromJson(dynamic json) {
    if (json == null) return null;
    if (json is Map<String, dynamic>) return json;
    if (json is List) {
      // Если это список авторов, преобразуем в Map
      return {'authors': json};
    }
    return null;
  }
}

