import 'package:flutter/material.dart';
import '../models/task_model.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final bool isSubtask;
  final Function(bool?)? onChanged;
  final VoidCallback? onDelete;
  final VoidCallback? onAddSubtask;

  const TaskTile({
    required this.task,
    this.isSubtask = false,
    this.onChanged,
    this.onDelete,
    this.onAddSubtask,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: task.isDone,
        onChanged: onChanged,
      ),
      title: Text(
        task.title,
        style: TextStyle(
          decoration: task.isDone ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: task.details.isNotEmpty ? Text(task.details) : null,
      trailing: Wrap(
        spacing: 8,
        children: [
          if (!isSubtask)
            IconButton(
              icon: Icon(Icons.add),
              onPressed: onAddSubtask,
            ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
