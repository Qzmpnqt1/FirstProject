# Инструкция по регенерации кода Drift

После обновления схемы базы данных необходимо перегенерировать код Drift.

## Шаги:

1. Убедитесь, что все изменения в `app_database.dart` сохранены
2. Запустите команду:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
3. После успешной регенерации:
   - Раскомментируйте код в `drift_data_source.dart` в методах `loadCache()` и `setSessions()`
   - Убедитесь, что все поля доступны в классе `StudySession`

## Что было изменено:

1. Добавлены новые поля в таблицу `StudySessions`:
   - `repeatType` (TEXT)
   - `repeatUntil` (DATETIME, nullable)
   - `reminderEnabled` (INTEGER/BOOLEAN)
   - `reminderMinutesBefore` (INTEGER)
   - `attendance` (TEXT)
   - `taskIdsJson` (TEXT)

2. Версия схемы увеличена до 2

3. Добавлена миграция для обновления существующих баз данных

