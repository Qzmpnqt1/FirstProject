/// Domain entity для цели (дневной/недельной)
enum GoalType { daily, weekly }
enum GoalStatus { notStarted, inProgress, completed }

class GoalEntity {
  final String id;
  final String title;
  final GoalType type;
  final GoalStatus status;
  final DateTime targetDate;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? description;

  const GoalEntity({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.targetDate,
    required this.createdAt,
    this.completedAt,
    this.description,
  });

  GoalEntity copyWith({
    String? id,
    String? title,
    GoalType? type,
    GoalStatus? status,
    DateTime? targetDate,
    DateTime? createdAt,
    DateTime? completedAt,
    String? description,
  }) =>
      GoalEntity(
        id: id ?? this.id,
        title: title ?? this.title,
        type: type ?? this.type,
        status: status ?? this.status,
        targetDate: targetDate ?? this.targetDate,
        createdAt: createdAt ?? this.createdAt,
        completedAt: completedAt ?? this.completedAt,
        description: description ?? this.description,
      );
}

