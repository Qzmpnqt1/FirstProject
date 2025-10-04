class Task {
  final String title;
  final bool done;
  Task(this.title, {this.done = false});
  Task copyWith({String? title, bool? done}) =>
      Task(title ?? this.title, done: done ?? this.done);
  Map<String, dynamic> toJson() => {'title': title, 'done': done};
  factory Task.fromJson(Map<String, dynamic> json) =>
      Task(json['title'] as String, done: json['done'] as bool? ?? false);
}