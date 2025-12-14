/// Domain entity для фокус-сессии (Pomodoro)
enum FocusSessionType { pomodoro, custom }

class FocusSessionEntity {
  final String id;
  final FocusSessionType type;
  final int durationMinutes;
  final DateTime startTime;
  final DateTime? endTime;
  final bool completed;
  final String? taskId; // Привязка к задаче
  final String? moduleId; // Привязка к модулю
  final String? notes;

  const FocusSessionEntity({
    required this.id,
    required this.type,
    required this.durationMinutes,
    required this.startTime,
    this.endTime,
    this.completed = false,
    this.taskId,
    this.moduleId,
    this.notes,
  });

  FocusSessionEntity copyWith({
    String? id,
    FocusSessionType? type,
    int? durationMinutes,
    DateTime? startTime,
    DateTime? endTime,
    bool? completed,
    String? taskId,
    String? moduleId,
    String? notes,
  }) =>
      FocusSessionEntity(
        id: id ?? this.id,
        type: type ?? this.type,
        durationMinutes: durationMinutes ?? this.durationMinutes,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        completed: completed ?? this.completed,
        taskId: taskId ?? this.taskId,
        moduleId: moduleId ?? this.moduleId,
        notes: notes ?? this.notes,
      );

  int get actualDurationMinutes {
    if (endTime == null) return 0;
    return endTime!.difference(startTime).inMinutes;
  }
}

