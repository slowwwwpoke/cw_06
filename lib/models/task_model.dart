class Task {
  String? id;
  String title;
  bool isDone;
  String details;
  List<Task> subtasks;

  Task({
    this.id,
    required this.title,
    this.isDone = false,
    this.details = '',
    this.subtasks = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isDone': isDone,
      'details': details,
    };
  }

  factory Task.fromMap(String id, Map<String, dynamic> map) {
    return Task(
      id: id,
      title: map['title'] ?? '',
      isDone: map['isDone'] ?? false,
      details: map['details'] ?? '',
    );
  }
}
