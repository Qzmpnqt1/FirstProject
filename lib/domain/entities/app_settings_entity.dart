/// Domain entity для настроек приложения
class AppSettingsEntity {
  final bool themeDark;
  final bool notifications;
  final bool analytics;
  final String name;
  final String role;
  final String group;
  final String goal;
  final String contacts;
  final int counter;

  const AppSettingsEntity({
    required this.themeDark,
    required this.notifications,
    required this.analytics,
    required this.name,
    required this.role,
    required this.group,
    required this.goal,
    required this.contacts,
    required this.counter,
  });

  AppSettingsEntity copyWith({
    bool? themeDark,
    bool? notifications,
    bool? analytics,
    String? name,
    String? role,
    String? group,
    String? goal,
    String? contacts,
    int? counter,
  }) =>
      AppSettingsEntity(
        themeDark: themeDark ?? this.themeDark,
        notifications: notifications ?? this.notifications,
        analytics: analytics ?? this.analytics,
        name: name ?? this.name,
        role: role ?? this.role,
        group: group ?? this.group,
        goal: goal ?? this.goal,
        contacts: contacts ?? this.contacts,
        counter: counter ?? this.counter,
      );
}

