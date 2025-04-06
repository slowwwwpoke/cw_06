class Task {
  String id;
  String name;
  bool isCompleted;
  String priority;
  DateTime? dueDate;
  List<String> subtasks;

  Task({
    required this.id,
    required this.name,
    this.isCompleted = false,
    this.priority = 'Medium',
    this.dueDate,
    this.subtasks = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'isCompleted': isCompleted,
      'priority': priority,
      'dueDate': dueDate?.toIso8601String(),
      'subtasks': subtasks,
    };
  }

  factory Task.fromMap(String id, Map<String, dynamic> map) {
    return Task(
      id: id,
      name: map['name'],
      isCompleted: map['isCompleted'] ?? false,
      priority: map['priority'] ?? 'Medium',
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      subtasks: List<String>.from(map['subtasks'] ?? []),
    );
  }
}
