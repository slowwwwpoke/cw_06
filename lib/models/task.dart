class Task {
  String id;
  String name;
  bool isCompleted;
  String priority; 
  DateTime? dueDate;
  List<Map<String, dynamic>> subTasks;

  Task({
    required this.id,
    required this.name,
    this.isCompleted = false,
    this.priority = 'Medium',
    this.dueDate,
    this.subTasks = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'isCompleted': isCompleted,
      'priority': priority,
      'dueDate': dueDate?.toIso8601String(),
      'subTasks': subTasks,
    };
  }

  factory Task.fromMap(String id, Map<String, dynamic> data) {
    return Task(
      id: id,
      name: data['name'],
      isCompleted: data['isCompleted'] ?? false,
      priority: data['priority'] ?? 'Medium',
      dueDate: data['dueDate'] != null ? DateTime.parse(data['dueDate']) : null,
      subTasks: List<Map<String, dynamic>>.from(data['subTasks'] ?? []),
    );
  }
}
