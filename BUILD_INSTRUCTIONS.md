# Инструкции по сборке и генерации кода

## Шаг 1: Установка зависимостей

```bash
flutter pub get
```

## Шаг 2: Генерация кода

После установки зависимостей необходимо сгенерировать код для:
- Retrofit API клиентов (`.g.dart` файлы)
- JSON сериализации (`.g.dart` файлы для DTO)

Выполните команду:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Или для автоматической регенерации при изменениях:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

## Что будет сгенерировано

1. `lib/data/api/open_alex_api.g.dart` - Реализация OpenAlexApi
2. `lib/data/api/open_library_api.g.dart` - Реализация OpenLibraryApi
3. `lib/data/models/remote/open_alex_dto.g.dart` - JSON сериализация для OpenAlex DTO
4. `lib/data/models/remote/open_library_dto.g.dart` - JSON сериализация для OpenLibrary DTO

## После генерации

После успешной генерации кода приложение должно:
- Компилироваться без ошибок
- Выполнять сетевые запросы к OpenAlex и OpenLibrary
- Отображать результаты в UI на экране "Каталог"

## Проверка работы

1. Запустите приложение
2. Перейдите на вкладку "Каталог"
3. Введите запрос (например, "machine learning" или "flutter")
4. Проверьте работу обеих вкладок:
   - "Темы (OpenAlex)" - должен показать список концептов
   - "Книги (OpenLibrary)" - должен показать список книг
5. Нажмите на элемент для просмотра деталей

## Структура сетевого слоя

```
lib/
├── data/
│   ├── api/                    # Retrofit интерфейсы
│   │   ├── open_alex_api.dart
│   │   └── open_library_api.dart
│   ├── datasources/remote/     # Dio клиенты и data sources
│   │   ├── dio_client.dart
│   │   ├── interceptors.dart
│   │   ├── exceptions.dart
│   │   ├── open_alex_remote_data_source.dart
│   │   └── open_library_remote_data_source.dart
│   ├── models/remote/          # DTO модели
│   │   ├── open_alex_dto.dart
│   │   └── open_library_dto.dart
│   ├── repositories/           # Реализация репозиториев
│   │   └── study_catalog_repository_impl.dart
│   └── di/                     # Dependency Injection
│       └── network_container.dart
├── domain/
│   ├── entities/               # Domain сущности
│   │   ├── study_topic_entity.dart
│   │   └── study_resource_entity.dart
│   ├── repositories/          # Интерфейсы репозиториев
│   │   └── study_catalog_repository.dart
│   └── usecases/              # Use cases
│       ├── search_topics_use_case.dart
│       ├── get_topic_detail_use_case.dart
│       ├── get_topic_works_use_case.dart
│       ├── search_books_use_case.dart
│       └── get_book_detail_use_case.dart
└── presentation/
    └── screens/catalog/       # UI экран
        └── catalog_page.dart
```

