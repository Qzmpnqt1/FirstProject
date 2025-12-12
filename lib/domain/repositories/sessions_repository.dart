import '../entities/study_session_entity.dart';

/// Интерфейс репозитория для работы с учебными сессиями
abstract class SessionsRepository {
  Future<List<StudySessionEntity>> getSessions();
  Future<void> saveSessions(List<StudySessionEntity> sessions);
}

