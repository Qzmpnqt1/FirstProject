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
  final dynamic description; // Может быть String или Map
  final List<String>? subjects;
  @JsonKey(name: 'first_publish_date')
  final String? firstPublishDate;
  final Map<String, dynamic>? authors;

  WorkDetailDto({
    this.title,
    this.description,
    this.subjects,
    this.firstPublishDate,
    this.authors,
  });

  factory WorkDetailDto.fromJson(Map<String, dynamic> json) =>
      _$WorkDetailDtoFromJson(json);

  Map<String, dynamic> toJson() => _$WorkDetailDtoToJson(this);

  /// Получить описание как строку
  String? get descriptionText {
    if (description == null) return null;
    if (description is String) return description as String;
    if (description is Map) {
      return (description as Map)['value'] as String?;
    }
    return description.toString();
  }
}

