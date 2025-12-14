# Сетевой слой приложения

## Структура

Сетевой слой реализован по принципам Clean Architecture: **Data → Domain → Presentation**

### Data Layer

#### `lib/data/datasources/remote/`
- `dio_client.dart` - Dio клиенты для OpenAlex и OpenLibrary
- `interceptors.dart` - LoggingInterceptor и ErrorInterceptor
- `exceptions.dart` - Исключения для сетевого слоя
- `open_alex_remote_data_source.dart` - Data source для OpenAlex API
- `open_library_remote_data_source.dart` - Data source для OpenLibrary API

#### `lib/data/api/`
- `open_alex_api.dart` - Retrofit интерфейс для OpenAlex API (3 метода)
- `open_library_api.dart` - Retrofit интерфейс для OpenLibrary API (2 метода)

#### `lib/data/models/remote/`
- `open_alex_dto.dart` - DTO модели для OpenAlex (ConceptDto, WorkDto, и т.д.)
- `open_library_dto.dart` - DTO модели для OpenLibrary (BookDocDto, WorkDetailDto)

#### `lib/data/repositories/`
- `study_catalog_repository_impl.dart` - Реализация репозитория каталога

#### `lib/data/di/`
- `network_container.dart` - Контейнер зависимостей для сетевого слоя

### Domain Layer

#### `lib/domain/entities/`
- `study_topic_entity.dart` - Сущность темы из OpenAlex
- `study_resource_entity.dart` - Сущность ресурса (книга/публикация)

#### `lib/domain/repositories/`
- `study_catalog_repository.dart` - Интерфейс репозитория каталога

#### `lib/domain/usecases/`
- `search_topics_use_case.dart` - Поиск тем
- `get_topic_detail_use_case.dart` - Детали темы
- `get_topic_works_use_case.dart` - Работы по теме
- `search_books_use_case.dart` - Поиск книг
- `get_book_detail_use_case.dart` - Детали книги

### Presentation Layer

#### `lib/presentation/screens/catalog/`
- `catalog_page.dart` - Экран каталога материалов с двумя вкладками

## API Endpoints

### OpenAlex API (https://api.openalex.org/)

1. **GET /concepts?search={query}&per_page=10** - Поиск концептов (тем)
2. **GET /concepts/{id}** - Детали концепта
3. **GET /works?filter=concept.id:{id}&per_page=10** - Работы по концепту

### OpenLibrary API (https://openlibrary.org/)

4. **GET /search.json?q={query}&limit=10** - Поиск книг
5. **GET /works/{workId}.json** - Детали работы (книги)

## Команды генерации

После добавления зависимостей выполните:

```bash
flutter pub get
```

Затем сгенерируйте код для Retrofit и json_serializable:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Или для автоматической регенерации при изменениях:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

## Интеграция

Сетевой слой интегрирован в приложение через:

1. **NetworkContainer** - создается в `MyApp._initializeStorages()`
2. **NetworkProvider** - InheritedWidget для доступа к контейнеру через контекст
3. **HomeScreen** - добавлен 8-й пункт навигации "Каталог"
4. **CatalogPage** - экран с двумя вкладками для поиска тем и книг

## Использование

1. Откройте приложение
2. Перейдите на вкладку "Каталог" в нижней навигации
3. Введите запрос в поле поиска (например, "machine learning", "flutter")
4. Переключайтесь между вкладками "Темы (OpenAlex)" и "Книги (OpenLibrary)"
5. Нажмите на элемент для просмотра деталей

## Важно

- Локальные хранилища (SharedPreferences, SecureStore, Drift, Hive) **не изменены**
- Сетевой слой работает **параллельно** с локальными хранилищами
- Все 5 запросов выполняются реально и отображаются в UI
- Ошибки обрабатываются через интерсепторы и отображаются пользователю

