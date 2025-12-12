import '../../domain/entities/study_session_entity.dart';
import '../../domain/repositories/sessions_repository.dart';
import '../datasources/local_storage_data_source.dart';
import '../models/study_session_model.dart';

/// Реализация репозитория для учебных сессий
class SessionsRepositoryImpl implements SessionsRepository {
  final LocalStorageDataSource _dataSource;

  SessionsRepositoryImpl(this._dataSource);

  @override
  Future<List<StudySessionEntity>> getSessions() async {
    final models = _dataSource.getSessions();
    return models;
  }

  @override
  Future<void> saveSessions(List<StudySessionEntity> sessions) async {
    final models = sessions.map((e) => StudySessionModel.fromEntity(e)).toList();
    await _dataSource.setSessions(models);
  }
}

