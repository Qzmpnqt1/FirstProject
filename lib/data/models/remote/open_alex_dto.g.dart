// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'open_alex_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConceptSearchResponseDto _$ConceptSearchResponseDtoFromJson(
        Map<String, dynamic> json) =>
    ConceptSearchResponseDto(
      results: (json['results'] as List<dynamic>)
          .map((e) => ConceptDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: json['meta'] == null
          ? null
          : MetaDto.fromJson(json['meta'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ConceptSearchResponseDtoToJson(
        ConceptSearchResponseDto instance) =>
    <String, dynamic>{
      'results': instance.results,
      'meta': instance.meta,
    };

ConceptDto _$ConceptDtoFromJson(Map<String, dynamic> json) => ConceptDto(
      id: json['id'] as String,
      displayName: json['display_name'] as String,
      description: json['description'] as String?,
      level: (json['level'] as num?)?.toInt(),
      worksCount: (json['works_count'] as num?)?.toInt(),
      citedByCount: (json['cited_by_count'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ConceptDtoToJson(ConceptDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'display_name': instance.displayName,
      'description': instance.description,
      'level': instance.level,
      'works_count': instance.worksCount,
      'cited_by_count': instance.citedByCount,
    };

WorkSearchResponseDto _$WorkSearchResponseDtoFromJson(
        Map<String, dynamic> json) =>
    WorkSearchResponseDto(
      results: (json['results'] as List<dynamic>)
          .map((e) => WorkDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: json['meta'] == null
          ? null
          : MetaDto.fromJson(json['meta'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$WorkSearchResponseDtoToJson(
        WorkSearchResponseDto instance) =>
    <String, dynamic>{
      'results': instance.results,
      'meta': instance.meta,
    };

WorkDto _$WorkDtoFromJson(Map<String, dynamic> json) => WorkDto(
      id: json['id'] as String,
      displayName: json['display_name'] as String?,
      publicationYear: (json['publication_year'] as num?)?.toInt(),
      citedByCount: (json['cited_by_count'] as num?)?.toInt(),
      type: json['type'] as String?,
    );

Map<String, dynamic> _$WorkDtoToJson(WorkDto instance) => <String, dynamic>{
      'id': instance.id,
      'display_name': instance.displayName,
      'publication_year': instance.publicationYear,
      'cited_by_count': instance.citedByCount,
      'type': instance.type,
    };

MetaDto _$MetaDtoFromJson(Map<String, dynamic> json) => MetaDto(
      count: (json['count'] as num?)?.toInt(),
      page: (json['page'] as num?)?.toInt(),
      perPage: (json['per_page'] as num?)?.toInt(),
    );

Map<String, dynamic> _$MetaDtoToJson(MetaDto instance) => <String, dynamic>{
      'count': instance.count,
      'page': instance.page,
      'per_page': instance.perPage,
    };
