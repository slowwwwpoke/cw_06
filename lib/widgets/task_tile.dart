import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/firebase_service.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final FirebaseService firebaseService;

  const TaskTile({super.key, required this.task, required this.firebaseService});

  Color _priorityColor(String p) {
    switch (p) {
      case 'High': return Colors.red;
      case 'Medium': return Colors.orange;
      case 'Low': return Colors.green;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: task.isCompleted,
        onChanged: (val) {
          firebaseService.updateTask(task..isCompleted = val!);
        },
      ),
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _priorityColor(task.priority),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(task.priority, style: TextStyle(color: Colors.white)),
          ),
          SizedBox(width: 8),
          Expanded(child: Text(task.name)),
        ],
      ),
      subtitle: task.dueDate != null ? Text('Due: ${task.dueDate!.toLocal().toString().split(' ')[0]}') : null,
      trailing: IconButton(
        icon: Icon(Icons.delete),
        onPressed: () => firebaseService.deleteTask(task.id),
      ),
    );
  }
}
