import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// --------------------
/// Tables
/// --------------------

class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
}

class Modules extends Table {
  TextColumn get id => text().withLength(min: 1)();
  TextColumn get title => text()();
  TextColumn get type => text()();
  IntColumn get hours => integer()();
  TextColumn get status => text()();
  TextColumn get topicsJson => text()();
  TextColumn get practicesJson => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class StudySessions extends Table {
  TextColumn get id => text().withLength(min: 1)();

  TextColumn get title => text()();
  TextColumn get moduleTitle => text()();
  DateTimeColumn get scheduledAt => dateTime()();
  IntColumn get durationMinutes => integer()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();

  // Расширенные поля
  TextColumn get repeatType => text().withDefault(const Constant('none'))();
  DateTimeColumn get repeatUntil => dateTime().nullable()();
  BoolColumn get reminderEnabled => boolean().withDefault(const Constant(false))();
  IntColumn get reminderMinutesBefore => integer().withDefault(const Constant(15))();
  TextColumn get attendance => text().withDefault(const Constant('notSet'))();
  TextColumn get taskIdsJson => text().withDefault(const Constant('[]'))();

  @override
  Set<Column> get primaryKey => {id};
}

class AuthUsers extends Table {
  TextColumn get email => text()();
  TextColumn get fullName => text()();

  @override
  Set<Column> get primaryKey => {email};
}

class Passwords extends Table {
  TextColumn get email => text()();
  TextColumn get password => text()();

  @override
  Set<Column> get primaryKey => {email};
}

class Settings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get key => text().unique()();
  TextColumn get value => text()();
}

/// --------------------
/// Database
/// --------------------

@DriftDatabase(tables: [Tasks, Modules, StudySessions, AuthUsers, Passwords, Settings])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// ВАЖНО: подняли версию, чтобы миграция пересоздала таблицы с PK
  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Если у тебя раньше уже была версия 2 и ты добавлял поля через ALTER,
        // этот блок можно оставить (он не мешает), но главное — from < 3.
        if (from < 2) {
          await m.database.customStatement(
              'ALTER TABLE study_sessions ADD COLUMN repeat_type TEXT NOT NULL DEFAULT \'none\'');
          await m.database.customStatement(
              'ALTER TABLE study_sessions ADD COLUMN repeat_until DATETIME');
          await m.database.customStatement(
              'ALTER TABLE study_sessions ADD COLUMN reminder_enabled INTEGER NOT NULL DEFAULT 0');
          await m.database.customStatement(
              'ALTER TABLE study_sessions ADD COLUMN reminder_minutes_before INTEGER NOT NULL DEFAULT 15');
          await m.database.customStatement(
              'ALTER TABLE study_sessions ADD COLUMN attendance TEXT NOT NULL DEFAULT \'notSet\'');
          await m.database.customStatement(
              'ALTER TABLE study_sessions ADD COLUMN task_ids_json TEXT NOT NULL DEFAULT \'[]\'');
        }

        if (from < 3) {
          // ---------- study_sessions: пересоздание с PRIMARY KEY(id)
          await m.database.customStatement('''
            CREATE TABLE study_sessions_new (
              id TEXT NOT NULL PRIMARY KEY,
              title TEXT NOT NULL,
              module_title TEXT NOT NULL,
              scheduled_at INTEGER NOT NULL,
              duration_minutes INTEGER NOT NULL,
              completed INTEGER NOT NULL DEFAULT 0,
              repeat_type TEXT NOT NULL DEFAULT 'none',
              repeat_until INTEGER,
              reminder_enabled INTEGER NOT NULL DEFAULT 0,
              reminder_minutes_before INTEGER NOT NULL DEFAULT 15,
              attendance TEXT NOT NULL DEFAULT 'notSet',
              task_ids_json TEXT NOT NULL DEFAULT '[]'
            );
          ''');

          // переносим данные (COALESCE на случай, если колонок ещё не было)
          await m.database.customStatement('''
            INSERT INTO study_sessions_new (
              id, title, module_title, scheduled_at, duration_minutes, completed,
              repeat_type, repeat_until, reminder_enabled, reminder_minutes_before, attendance, task_ids_json
            )
            SELECT
              id, title, module_title, scheduled_at, duration_minutes, completed,
              COALESCE(repeat_type, 'none'),
              repeat_until,
              COALESCE(reminder_enabled, 0),
              COALESCE(reminder_minutes_before, 15),
              COALESCE(attendance, 'notSet'),
              COALESCE(task_ids_json, '[]')
            FROM study_sessions;
          ''');

          await m.database.customStatement('DROP TABLE study_sessions;');
          await m.database.customStatement('ALTER TABLE study_sessions_new RENAME TO study_sessions;');

          // ---------- modules: пересоздание с PRIMARY KEY(id)
          await m.database.customStatement('''
            CREATE TABLE modules_new (
              id TEXT NOT NULL PRIMARY KEY,
              title TEXT NOT NULL,
              type TEXT NOT NULL,
              hours INTEGER NOT NULL,
              status TEXT NOT NULL,
              topics_json TEXT NOT NULL,
              practices_json TEXT NOT NULL
            );
          ''');

          await m.database.customStatement('''
            INSERT INTO modules_new (id, title, type, hours, status, topics_json, practices_json)
            SELECT id, title, type, hours, status, topics_json, practices_json
            FROM modules;
          ''');

          await m.database.customStatement('DROP TABLE modules;');
          await m.database.customStatement('ALTER TABLE modules_new RENAME TO modules;');

          // ---------- auth_users: пересоздание с PRIMARY KEY(email)
          await m.database.customStatement('''
            CREATE TABLE auth_users_new (
              email TEXT NOT NULL PRIMARY KEY,
              full_name TEXT NOT NULL
            );
          ''');

          await m.database.customStatement('''
            INSERT INTO auth_users_new (email, full_name)
            SELECT email, full_name
            FROM auth_users;
          ''');

          await m.database.customStatement('DROP TABLE auth_users;');
          await m.database.customStatement('ALTER TABLE auth_users_new RENAME TO auth_users;');

          // ---------- passwords: пересоздание с PRIMARY KEY(email)
          await m.database.customStatement('''
            CREATE TABLE passwords_new (
              email TEXT NOT NULL PRIMARY KEY,
              password TEXT NOT NULL
            );
          ''');

          await m.database.customStatement('''
            INSERT INTO passwords_new (email, password)
            SELECT email, password
            FROM passwords;
          ''');

          await m.database.customStatement('DROP TABLE passwords;');
          await m.database.customStatement('ALTER TABLE passwords_new RENAME TO passwords;');
        }
      },
    );
  }

  /// --------------------
  /// Settings helpers
  /// --------------------

  Future<void> setSetting(String key, String value) async {
    await into(settings).insertOnConflictUpdate(
      SettingsCompanion.insert(key: key, value: value),
    );
  }

  Future<Setting?> getSetting(String key) {
    return (select(settings)..where((s) => s.key.equals(key))).getSingleOrNull();
  }

  Future<void> removeSetting(String key) async {
    await (delete(settings)..where((s) => s.key.equals(key))).go();
  }

  /// --------------------
  /// Tasks helpers
  /// --------------------

  Future<void> insertTask(TasksCompanion task) async {
    await into(tasks).insert(task);
  }

  Future<List<Task>> getAllTasks() async {
    return (select(tasks)).get();
  }

  Future<void> deleteAllTasks() async {
    await delete(tasks).go();
  }

  /// --------------------
  /// Modules helpers
  /// --------------------

  Future<void> insertModule(ModulesCompanion module) async {
    await into(modules).insertOnConflictUpdate(module);
  }

  Future<List<Module>> getAllModules() async {
    return (select(modules)).get();
  }

  Future<void> deleteAllModules() async {
    await delete(modules).go();
  }

  /// --------------------
  /// Sessions helpers
  /// --------------------

  Future<void> insertSession(StudySessionsCompanion session) async {
    await into(studySessions).insertOnConflictUpdate(session);
  }

  Future<List<StudySession>> getAllSessions() async {
    return (select(studySessions)).get();
  }

  Future<void> deleteAllSessions() async {
    await delete(studySessions).go();
  }

  /// --------------------
  /// Auth helpers
  /// --------------------

  Future<void> insertUser(AuthUsersCompanion user) async {
    await into(authUsers).insertOnConflictUpdate(user);
  }

  Future<AuthUser?> getUserByEmail(String email) async {
    return (select(authUsers)..where((u) => u.email.equals(email))).getSingleOrNull();
  }

  Future<void> insertPassword(PasswordsCompanion password) async {
    await into(passwords).insertOnConflictUpdate(password);
  }

  Future<String?> getPasswordByEmail(String email) async {
    final pwd = await (select(passwords)..where((p) => p.email.equals(email))).getSingleOrNull();
    return pwd?.password;
  }

  Future<void> setCurrentUser(String email, String fullName) async {
    await setSetting('current_user_email', email);
    await setSetting('current_user_fullName', fullName);
  }

  Future<void> clearCurrentUser() async {
    await removeSetting('current_user_email');
    await removeSetting('current_user_fullName');
  }

  Future<AuthUser?> getCurrentUser() async {
    final emailSetting = await getSetting('current_user_email');
    if (emailSetting == null) return null;
    return getUserByEmail(emailSetting.value);
  }
}

/// --------------------
/// Connection
/// --------------------

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app.db'));
    return NativeDatabase(file);
  });
}
