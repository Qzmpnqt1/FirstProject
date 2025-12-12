import '../../domain/entities/module_entity.dart';
import '../models/task_model.dart';
import '../models/module_model.dart';
import '../models/auth_user_model.dart';
import '../models/study_session_model.dart';

/// Интерфейс для всех источников данных
abstract class DataSourceInterface {
  // Settings
  bool getDark();
  Future<void> setDark(bool v);
  int getCounter();
  Future<void> setCounter(int v);
  String getName();
  String getRole();
  String getProfileGroup();
  String getProfileGoal();
  String getProfileContacts();
  Future<void> setName(String v);
  Future<void> setRole(String v);
  Future<void> setProfileGroup(String v);
  Future<void> setProfileGoal(String v);
  Future<void> setProfileContacts(String v);
  bool getNotifications();
  bool getAnalytics();
  Future<void> setNotifications(bool v);
  Future<void> setAnalytics(bool v);

  // Tasks
  List<TaskModel> getTasks();
  Future<void> setTasks(List<TaskModel> tasks);

  // Modules
  List<String> getModules();
  Future<void> setModules(List<String> modules);
  List<ModuleModel> getModulesEx();
  Future<void> setModulesEx(List<ModuleModel> modules);

  // Sessions
  List<StudySessionModel> getSessions();
  Future<void> setSessions(List<StudySessionModel> sessions);

  // Auth
  AuthUserModel? getCurrentUser();
  Future<void> setCurrentUser(AuthUserModel? user);
  Future<bool> register(String fullName, String email, String password);
  Future<AuthUserModel?> login(String email, String password);
  Future<void> logout();
  
  // Инициализация
  static Future<void> init() async {}
}

