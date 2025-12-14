/// Domain entity для отслеживания серии дней активности
class ActivityStreakEntity {
  final int currentStreak; // Текущая серия дней
  final int longestStreak; // Самая длинная серия
  final DateTime lastActivityDate; // Дата последней активности
  final Map<DateTime, int> dailyActivity; // Дата -> количество выполненных задач/модулей

  const ActivityStreakEntity({
    required this.currentStreak,
    required this.longestStreak,
    required this.lastActivityDate,
    required this.dailyActivity,
  });

  ActivityStreakEntity copyWith({
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActivityDate,
    Map<DateTime, int>? dailyActivity,
  }) =>
      ActivityStreakEntity(
        currentStreak: currentStreak ?? this.currentStreak,
        longestStreak: longestStreak ?? this.longestStreak,
        lastActivityDate: lastActivityDate ?? this.lastActivityDate,
        dailyActivity: dailyActivity ?? this.dailyActivity,
      );

  /// Проверка, был ли сегодня активный день
  bool get isTodayActive {
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);
    return dailyActivity.containsKey(todayKey) && dailyActivity[todayKey]! > 0;
  }

  /// Обновление streak на основе активности
  ActivityStreakEntity updateWithActivity(DateTime date, int activityCount) {
    final dateKey = DateTime(date.year, date.month, date.day);
    final updatedActivity = Map<DateTime, int>.from(dailyActivity);
    updatedActivity[dateKey] = (updatedActivity[dateKey] ?? 0) + activityCount;

    int newStreak = currentStreak;
    int newLongestStreak = longestStreak;

    // Проверка непрерывности streak
    final yesterday = date.subtract(const Duration(days: 1));
    final yesterdayKey = DateTime(yesterday.year, yesterday.month, yesterday.day);
    if (updatedActivity.containsKey(yesterdayKey) && updatedActivity[yesterdayKey]! > 0) {
      newStreak = currentStreak + 1;
    } else if (date.difference(lastActivityDate).inDays > 1) {
      newStreak = 1; // Начало новой серии
    } else {
      newStreak = currentStreak + 1;
    }

    if (newStreak > longestStreak) {
      newLongestStreak = newStreak;
    }

    return copyWith(
      currentStreak: newStreak,
      longestStreak: newLongestStreak,
      lastActivityDate: date,
      dailyActivity: updatedActivity,
    );
  }
}

