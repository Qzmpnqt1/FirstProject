# Реализация хранилищ данных в приложении

## ✅ Все типы хранилищ реализованы

### 1. SharedPreferences (Локальное хранилище)
**Файл:** `lib/data/datasources/local_storage_data_source.dart`

- ✅ Полная реализация через класс `LocalStorageDataSource`
- ✅ Использует пакет `shared_preferences`
- ✅ Хранит данные в формате JSON
- ✅ Реализует интерфейс `DataSourceInterface`
- ✅ Поддерживает все операции: настройки, задачи, модули, сессии, аутентификацию

**Особенности:**
- Простое key-value хранилище
- Подходит для небольших объемов данных
- Данные хранятся в виде строк JSON
- Инициализация через `LocalStorageDataSource.init()`

---

### 2. Flutter Secure Store (Безопасное хранилище)
**Файл:** `lib/data/datasources/secure_store_data_source.dart`

- ✅ Полная реализация через класс `SecureStoreDataSource`
- ✅ Использует пакет `flutter_secure_storage`
- ✅ Шифрование данных на уровне платформы
- ✅ Реализует интерфейс `DataSourceInterface`
- ✅ Поддерживает все операции с кэшированием для производительности

**Особенности:**
- Зашифрованное хранилище для чувствительных данных
- Android: использует EncryptedSharedPreferences
- iOS: использует Keychain с настройками доступности
- Кэширование данных в памяти для быстрого доступа
- Инициализация через `SecureStoreDataSource.init()`

---

### 3. SQL хранилище (Drift)
**Файл:** `lib/data/datasources/drift_data_source.dart`
**База данных:** `lib/data/database/app_database.dart`

- ✅ Полная реализация через класс `DriftDataSource`
- ✅ Использует пакет `drift` (обертка над SQLite)
- ✅ Определены таблицы: Tasks, Modules, StudySessions, AuthUsers, Passwords, Settings
- ✅ Реализует интерфейс `DataSourceInterface`
- ✅ Миграции базы данных
- ✅ Кэширование для синхронного доступа

**Структура базы данных:**
```dart
- Tasks: id (auto increment), title, done
- Modules: id, title, type, hours, status, topicsJson, practicesJson
- StudySessions: id, title, moduleTitle, scheduledAt, durationMinutes, completed
- AuthUsers: email, fullName
- Passwords: email, password
- Settings: id (auto increment), key (unique), value
```

**Особенности:**
- Типобезопасные запросы через кодогенерацию
- Миграции через `MigrationStrategy`
- Кэширование данных в памяти
- Инициализация через `DriftDataSource.init()`

---

### 4. NoSQL хранилище (Hive)
**Файл:** `lib/data/datasources/hive_data_source.dart`

- ✅ Полная реализация через класс `HiveDataSource`
- ✅ Использует пакет `hive` и `hive_flutter`
- ✅ Хранилище на основе ключ-значение (Boxes)
- ✅ Реализует интерфейс `DataSourceInterface`
- ✅ Поддерживает все операции

**Структура Boxes:**
```dart
- tasks_box: для задач
- modules_box: для модулей (legacy)
- modules_ex_box: для расширенных модулей
- sessions_box: для учебных сессий
- auth_box: для аутентификации
- settings_box: для настроек
```

**Особенности:**
- Быстрое локальное хранилище
- Поддержка адаптеров для типизированных моделей
- Инициализация через `HiveDataSource.init()`
- Данные хранятся в бинарном формате

---

## Стратегия выбора хранилища

**Файл:** `lib/data/datasources/storage_strategy.dart`

- ✅ Реализован класс `StorageStrategy`
- ✅ Enum `StorageType` для выбора типа хранилища
- ✅ Метод `getDataSource()` для получения нужного источника данных
- ✅ Метод `getDefaultType()` для получения типа по умолчанию

**Использование:**
```dart
// Выбор хранилища
final strategy = StorageStrategy(StorageType.sharedPreferences);
final dataSource = await strategy.getDataSource();

// Доступные типы:
// - StorageType.sharedPreferences
// - StorageType.secureStore
// - StorageType.drift
// - StorageType.hive
```

---

## Инициализация в приложении

**Файл:** `lib/main.dart`

Все хранилища инициализируются при запуске приложения:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализация всех типов хранилищ
  await LocalStorageDataSource.init();
  await SecureStoreDataSource.init();
  await HiveDataSource.init();
  // Drift инициализируется при создании AppDatabase
  
  runApp(const MyApp());
}
```

**Файл:** `lib/app/my_app.dart`

Приложение использует стратегию для выбора активного хранилища:

```dart
final strategy = StorageStrategy(StorageStrategy.getDefaultType());
final dataSource = await strategy.getDataSource();
```

---

## Единый интерфейс

**Файл:** `lib/data/datasources/data_source_interface.dart`

Все хранилища реализуют единый интерфейс `DataSourceInterface`, что позволяет:

- ✅ Легко переключаться между типами хранилищ
- ✅ Использовать один и тот же код для работы с данными
- ✅ Тестировать с разными хранилищами
- ✅ Реализовать паттерн Repository для абстракции

**Методы интерфейса:**
- Настройки: `getDark()`, `setDark()`, `getCounter()`, `setCounter()`, и т.д.
- Профиль: `getName()`, `setName()`, `getRole()`, и т.д.
- Задачи: `getTasks()`, `setTasks()`
- Модули: `getModules()`, `getModulesEx()`, `setModules()`, `setModulesEx()`
- Сессии: `getSessions()`, `setSessions()`
- Аутентификация: `getCurrentUser()`, `setCurrentUser()`, `register()`, `login()`, `logout()`

---

## Сравнение хранилищ

| Характеристика | SharedPreferences | Secure Store | Drift (SQL) | Hive (NoSQL) |
|----------------|-------------------|--------------|-------------|--------------|
| **Безопасность** | Низкая | Высокая | Средняя | Средняя |
| **Производительность** | Средняя | Средняя | Высокая | Очень высокая |
| **Сложность запросов** | Простые | Простые | Сложные (SQL) | Простые |
| **Типобезопасность** | Нет | Нет | Да | Частично |
| **Миграции** | Ручные | Ручные | Автоматические | Ручные |
| **Размер данных** | Малый | Малый | Большой | Большой |
| **Структурированность** | Низкая | Низкая | Высокая | Средняя |

---

## Рекомендации по использованию

1. **SharedPreferences** - для простых настроек и небольших данных
2. **Secure Store** - для паролей, токенов и других чувствительных данных
3. **Drift (SQL)** - для сложных запросов и структурированных данных
4. **Hive (NoSQL)** - для быстрого доступа к большим объемам данных

---

## Статус реализации: ✅ ПОЛНОСТЬЮ РЕАЛИЗОВАНО

Все четыре типа хранилищ полностью реализованы и готовы к использованию.

