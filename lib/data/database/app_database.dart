import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// Таблицы
class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
}

class Modules extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get type => text()();
  IntColumn get hours => integer()();
  TextColumn get status => text()();
  TextColumn get topicsJson => text()();
  TextColumn get practicesJson => text()();
}

class StudySessions extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get moduleTitle => text()();
  DateTimeColumn get scheduledAt => dateTime()();
  IntColumn get durationMinutes => integer()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
}

class AuthUsers extends Table {
  TextColumn get email => text()();
  TextColumn get fullName => text()();
}

class Passwords extends Table {
  TextColumn get email => text()();
  TextColumn get password => text()();
}

class Settings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get key => text().unique()();
  TextColumn get value => text()();
}

@DriftDatabase(tables: [Tasks, Modules, StudySessions, AuthUsers, Passwords, Settings])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Миграции при обновлении схемы
      },
    );
  }

  // Settings helpers
  Future<void> setSetting(String key, String value) async {
    await into(settings).insertOnConflictUpdate(
      SettingsCompanion.insert(key: key, value: value),
    );
  }

  Future<Setting?> getSetting(String key) {
    return (select(settings)..where((s) => s.key.equals(key))).getSingleOrNull();
  }

  // Tasks helpers
  Future<void> insertTask(TasksCompanion task) async {
    await into(tasks).insert(task);
  }

  Future<List<Task>> getAllTasks() async {
    return await (select(tasks)).get();
  }

  Future<void> deleteAllTasks() async {
    await delete(tasks).go();
  }

  // Modules helpers
  Future<void> insertModule(ModulesCompanion module) async {
    await into(modules).insertOnConflictUpdate(module);
  }

  Future<List<Module>> getAllModules() async {
    return await (select(modules)).get();
  }

  Future<void> deleteAllModules() async {
    await delete(modules).go();
  }

  // Sessions helpers
  Future<void> insertSession(StudySessionsCompanion session) async {
    await into(studySessions).insertOnConflictUpdate(session);
  }

  Future<List<StudySession>> getAllSessions() async {
    return await (select(studySessions)).get();
  }

  Future<void> deleteAllSessions() async {
    await delete(studySessions).go();
  }

  // Auth helpers
  Future<void> insertUser(AuthUsersCompanion user) async {
    await into(authUsers).insertOnConflictUpdate(user);
  }

  Future<AuthUser?> getUserByEmail(String email) async {
    return await (select(authUsers)..where((u) => u.email.equals(email))).getSingleOrNull();
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
    await (update(settings)..where((s) => s.key.equals('current_user_email'))).write(const SettingsCompanion(value: Value.absent()));
    await (update(settings)..where((s) => s.key.equals('current_user_fullName'))).write(const SettingsCompanion(value: Value.absent()));
  }

  Future<AuthUser?> getCurrentUser() async {
    final emailSetting = await getSetting('current_user_email');
    if (emailSetting == null) return null;
    return await getUserByEmail(emailSetting.value);
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app.db'));
    return NativeDatabase(file);
  });
}

