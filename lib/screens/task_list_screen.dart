import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/firebase_service.dart';
import '../widgets/task_tile.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  final String _userId = 'test_user'; // Replace with actual user auth later
  List<Task> _tasks = [];

  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await _firebaseService.fetchTasks(_userId);
    setState(() {
      _tasks = tasks;
    });
  }

  Future<void> _addTask() async {
    if (_taskController.text.isEmpty) return;
    final newTask = Task(
      title: _taskController.text,
      details: _detailsController.text,
    );
    await _firebaseService.addTask(_userId, newTask);
    _taskController.clear();
    _detailsController.clear();
    _loadTasks();
  }

  Future<void> _addSubtask(Task parentTask) async {
    final TextEditingController subtaskController = TextEditingController();
    final TextEditingController subDetailsController = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Add Subtask'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: subtaskController,
              decoration: InputDecoration(labelText: 'Subtask title'),
            ),
            TextField(
              controller: subDetailsController,
              decoration: InputDecoration(labelText: 'Subtask details'),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: Navigator.of(context).pop,
          ),
          ElevatedButton(
            child: Text('Add'),
            onPressed: () async {
              final subtask = Task(
                title: subtaskController.text,
                details: subDetailsController.text,
              );
              await _firebaseService.addSubtask(_userId, parentTask.id!, subtask);
              Navigator.of(context).pop();
              _loadTasks();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Task Manager')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          TextField(
            controller: _taskController,
            decoration: InputDecoration(labelText: 'Task title'),
          ),
          TextField(
            controller: _detailsController,
            decoration: InputDecoration(labelText: 'Task details'),
          ),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: _addTask,
            child: Text('Add Task'),
          ),
          Divider(),
          ..._tasks.map((task) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TaskTile(
                  task: task,
                  onChanged: (val) async {
                    task.isDone = val!;
                    await _firebaseService.updateTask(_userId, task);
                    _loadTasks();
                  },
                  onDelete: () async {
                    await _firebaseService.deleteTask(_userId, task.id!);
                    _loadTasks();
                  },
                  onAddSubtask: () => _addSubtask(task),
                ),
                ...task.subtasks.map((subtask) => Padding(
                      padding: EdgeInsets.only(left: 32),
                      child: TaskTile(
                        task: subtask,
                        isSubtask: true,
                        onChanged: (val) async {
                          subtask.isDone = val!;
                          await _firebaseService.updateSubtask(_userId, task.id!, subtask);
                          _loadTasks();
                        },
                        onDelete: () async {
                          await _firebaseService.deleteSubtask(_userId, task.id!, subtask.id!);
                          _loadTasks();
                        },
                      ),
                    )),
                Divider(),
              ],
            );
          }),
        ],
      ),
    );
  }
}
