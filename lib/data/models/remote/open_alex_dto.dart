import 'package:json_annotation/json_annotation.dart';

part 'open_alex_dto.g.dart';

/// Ответ на поиск концептов
@JsonSerializable()
class ConceptSearchResponseDto {
  final List<ConceptDto> results;
  final MetaDto? meta;

  ConceptSearchResponseDto({
    required this.results,
    this.meta,
  });

  factory ConceptSearchResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ConceptSearchResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ConceptSearchResponseDtoToJson(this);
}

/// Концепт (тема) из OpenAlex
@JsonSerializable()
class ConceptDto {
  final String id;
  @JsonKey(name: 'display_name')
  final String displayName;
  final String? description;
  final int? level;
  @JsonKey(name: 'works_count')
  final int? worksCount;
  @JsonKey(name: 'cited_by_count')
  final int? citedByCount;

  ConceptDto({
    required this.id,
    required this.displayName,
    this.description,
    this.level,
    this.worksCount,
    this.citedByCount,
  });

  factory ConceptDto.fromJson(Map<String, dynamic> json) =>
      _$ConceptDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ConceptDtoToJson(this);
}

/// Ответ на поиск работ
@JsonSerializable()
class WorkSearchResponseDto {
  final List<WorkDto> results;
  final MetaDto? meta;

  WorkSearchResponseDto({
    required this.results,
    this.meta,
  });

  factory WorkSearchResponseDto.fromJson(Map<String, dynamic> json) =>
      _$WorkSearchResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$WorkSearchResponseDtoToJson(this);
}

/// Работа (публикация) из OpenAlex
@JsonSerializable()
class WorkDto {
  final String id;
  @JsonKey(name: 'display_name')
  final String? displayName;
  @JsonKey(name: 'publication_year')
  final int? publicationYear;
  @JsonKey(name: 'cited_by_count')
  final int? citedByCount;
  final String? type;

  WorkDto({
    required this.id,
    this.displayName,
    this.publicationYear,
    this.citedByCount,
    this.type,
  });

  factory WorkDto.fromJson(Map<String, dynamic> json) =>
      _$WorkDtoFromJson(json);

  Map<String, dynamic> toJson() => _$WorkDtoToJson(this);
}

/// Метаданные ответа
@JsonSerializable()
class MetaDto {
  final int? count;
  final int? page;
  @JsonKey(name: 'per_page')
  final int? perPage;

  MetaDto({
    this.count,
    this.page,
    this.perPage,
  });

  factory MetaDto.fromJson(Map<String, dynamic> json) =>
      _$MetaDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MetaDtoToJson(this);
}

