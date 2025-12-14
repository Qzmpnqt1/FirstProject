// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'open_library_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookSearchResponseDto _$BookSearchResponseDtoFromJson(
        Map<String, dynamic> json) =>
    BookSearchResponseDto(
      numFound: (json['numFound'] as num?)?.toInt(),
      start: (json['start'] as num?)?.toInt(),
      docs: (json['docs'] as List<dynamic>)
          .map((e) => BookDocDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BookSearchResponseDtoToJson(
        BookSearchResponseDto instance) =>
    <String, dynamic>{
      'numFound': instance.numFound,
      'start': instance.start,
      'docs': instance.docs,
    };

BookDocDto _$BookDocDtoFromJson(Map<String, dynamic> json) => BookDocDto(
      key: json['key'] as String,
      title: json['title'] as String?,
      authorName: (json['author_name'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      firstPublishYear: (json['first_publish_year'] as num?)?.toInt(),
      isbn: (json['isbn'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$BookDocDtoToJson(BookDocDto instance) =>
    <String, dynamic>{
      'key': instance.key,
      'title': instance.title,
      'author_name': instance.authorName,
      'first_publish_year': instance.firstPublishYear,
      'isbn': instance.isbn,
    };

WorkDetailDto _$WorkDetailDtoFromJson(Map<String, dynamic> json) =>
    WorkDetailDto(
      title: json['title'] as String?,
      description: json['description'],
      subjects: (json['subjects'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      firstPublishDate: json['first_publish_date'] as String?,
      authors: json['authors'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$WorkDetailDtoToJson(WorkDetailDto instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'subjects': instance.subjects,
      'first_publish_date': instance.firstPublishDate,
      'authors': instance.authors,
    };
