# Распределение хранилищ по функциональным областям

## ✅ Реализовано: Разные части приложения используют разные хранилища

### Распределение хранилищ

| Функциональная область | Хранилище | Репозиторий | Обоснование |
|------------------------|-----------|-------------|-------------|
| **Настройки** | SharedPreferences | `SettingsRepositoryImpl` | Простые key-value настройки, не требуют сложных запросов |
| **Аутентификация** | Flutter Secure Store | `AuthRepositoryImpl` | Безопасное хранение паролей и токенов с шифрованием |
| **Задачи** | Drift (SQL) | `TasksRepositoryImpl` | Структурированные данные, возможность сложных запросов |
| **Модули** | Hive (NoSQL) | `ModulesRepositoryImpl` | Быстрый доступ к большим объемам данных |
| **Учебные сессии** | Drift (SQL) | `SessionsRepositoryImpl` | Структурированные данные с датами, возможность запросов по времени |

---

## Детали реализации

### 1. Настройки → SharedPreferences

**Файл:** `lib/data/repositories/settings_repository_impl.dart`

```dart
class SettingsRepositoryImpl implements SettingsRepository {
  final LocalStorageDataSource _dataSource;  // SharedPreferences
  // ...
}
```

**Используется для:**
- Тема приложения (темная/светлая)
- Настройки уведомлений
- Настройки аналитики
- Профиль пользователя (имя, роль, группа, цель, контакты)
- Счетчик

**Преимущества:**
- Простота использования
- Быстрый доступ
- Подходит для небольших данных

---

### 2. Аутентификация → Flutter Secure Store

**Файл:** `lib/data/repositories/auth_repository_impl.dart`

```dart
class AuthRepositoryImpl implements AuthRepository {
  final SecureStoreDataSource _dataSource;  // Flutter Secure Store
  // ...
}
```

**Используется для:**
- Хранение паролей пользователей
- Хранение токенов аутентификации
- Информация о текущем пользователе
- Регистрация и вход пользователей

**Преимущества:**
- Шифрование на уровне платформы
- Android: EncryptedSharedPreferences
- iOS: Keychain с настройками доступности
- Безопасность для чувствительных данных

---

### 3. Задачи → Drift (SQL)

**Файл:** `lib/data/repositories/tasks_repository_impl.dart`

```dart
class TasksRepositoryImpl implements TasksRepository {
  final DriftDataSource _dataSource;  // Drift (SQL)
  // ...
}
```

**Используется для:**
- Хранение задач пользователя
- Структурированные запросы (фильтрация, сортировка)
- Связи между задачами (подзадачи, привязка к модулям/сессиям)
- История выполнения задач

**Преимущества:**
- Типобезопасные запросы
- Сложные SQL-запросы
- Миграции базы данных
- Транзакции

**Таблица в БД:**
```sql
Tasks {
  id: INTEGER (auto increment)
  title: TEXT
  done: BOOLEAN
}
```

---

### 4. Модули → Hive (NoSQL)

**Файл:** `lib/data/repositories/modules_repository_impl.dart`

```dart
class ModulesRepositoryImpl implements ModulesRepository {
  final HiveDataSource _dataSource;  // Hive (NoSQL)
  // ...
}
```

**Используется для:**
- Хранение учебных модулей
- Темы и практики модулей
- Прогресс модулей
- Материалы модулей
- История прогресса

**Преимущества:**
- Очень быстрый доступ
- Хранение сложных объектов
- Бинарный формат (эффективное использование памяти)
- Подходит для больших объемов данных

**Box в Hive:**
- `modules_ex_box` - расширенные модули с полной информацией

---

### 5. Учебные сессии → Drift (SQL)

**Файл:** `lib/data/repositories/sessions_repository_impl.dart`

```dart
class SessionsRepositoryImpl implements SessionsRepository {
  final DriftDataSource _dataSource;  // Drift (SQL)
  // ...
}
```

**Используется для:**
- Хранение расписания занятий
- Запросы по датам и времени
- Проверка конфликтов в расписании
- Отметка посещаемости
- Привязка задач к сессиям

**Преимущества:**
- Запросы по датам (WHERE scheduledAt BETWEEN ...)
- Сортировка по времени
- Поиск конфликтов
- Структурированные данные

**Таблица в БД:**
```sql
StudySessions {
  id: TEXT
  title: TEXT
  moduleTitle: TEXT
  scheduledAt: DATETIME
  durationMinutes: INTEGER
  completed: BOOLEAN
}
```

---

## Инициализация в приложении

**Файл:** `lib/app/my_app.dart`

```dart
Future<void> _initializeStorages() async {
  // Инициализация всех хранилищ
  await LocalStorageDataSource.init();
  await SecureStoreDataSource.init();
  await HiveDataSource.init();
  
  // Создание экземпляров хранилищ
  final settingsStorage = LocalStorageDataSource();
  final authStorage = SecureStoreDataSource();
  await authStorage.loadCache();
  
  final db = await DriftDataSource.init();
  final tasksStorage = DriftDataSource(db);
  await tasksStorage.loadCache();
  
  final sessionsStorage = tasksStorage;  // Используем тот же экземпляр
  final modulesStorage = HiveDataSource();
  
  // Создание репозиториев с соответствующими хранилищами
  final settingsRepository = SettingsRepositoryImpl(settingsStorage);
  final authRepository = AuthRepositoryImpl(authStorage);
  final tasksRepository = TasksRepositoryImpl(tasksStorage);
  final modulesRepository = ModulesRepositoryImpl(modulesStorage);
  final sessionsRepository = SessionsRepositoryImpl(sessionsStorage);
}
```

---

## Преимущества такого подхода

1. **Оптимизация производительности**
   - Каждое хранилище используется для тех задач, для которых оно лучше всего подходит
   - Быстрые операции там, где нужна скорость
   - Структурированные запросы там, где нужна сложная логика

2. **Безопасность**
   - Чувствительные данные (пароли) хранятся в зашифрованном виде
   - Обычные настройки в простом хранилище

3. **Масштабируемость**
   - Легко заменить одно хранилище на другое для конкретной области
   - Независимость хранилищ друг от друга

4. **Гибкость**
   - Можно использовать разные стратегии для разных данных
   - Легко тестировать с разными хранилищами

---

## Схема архитектуры

```
┌─────────────────────────────────────────────────────────┐
│                     MyApp                                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │ SettingsRepo │  │  AuthRepo    │  │  TasksRepo   │  │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘  │
│         │                 │                  │          │
│  ┌──────▼───────┐  ┌──────▼───────┐  ┌──────▼───────┐  │
│  │SharedPrefs   │  │Secure Store  │  │Drift (SQL)   │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
│                                                          │
│  ┌──────────────┐  ┌──────────────┐                     │
│  │ ModulesRepo  │  │ SessionsRepo │                     │
│  └──────┬───────┘  └──────┬───────┘                     │
│         │                 │                               │
│  ┌──────▼───────┐  ┌──────▼───────┐                     │
│  │Hive (NoSQL) │  │Drift (SQL)   │                     │
│  └──────────────┘  └──────────────┘                     │
└─────────────────────────────────────────────────────────┘
```

---

## Статус: ✅ ПОЛНОСТЬЮ РЕАЛИЗОВАНО

Все хранилища распределены по функциональным областям и используются в соответствующих репозиториях.

