import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../services/firebase_service.dart';
import '../widgets/task_tile.dart';

class TaskListScreen extends StatefulWidget {
  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _taskController = TextEditingController();

  String _priority = 'Medium';
  DateTime? _dueDate;

  String _sortOption = 'None';
  String _filterPriority = 'All';
  bool _showCompleted = false;

  List<Task> _applyFilters(List<Task> tasks) {
    var list = tasks;

    if (_filterPriority != 'All') {
      list = list.where((t) => t.priority == _filterPriority).toList();
    }
    if (_showCompleted) {
      list = list.where((t) => t.isCompleted).toList();
    }

    if (_sortOption == 'Priority') {
      list.sort((a, b) => _priorityToInt(a.priority).compareTo(_priorityToInt(b.priority)));
    } else if (_sortOption == 'Due Date') {
      list.sort((a, b) => (a.dueDate ?? DateTime(2100)).compareTo(b.dueDate ?? DateTime(2100)));
    } else if (_sortOption == 'Completion') {
      list.sort((a, b) => (a.isCompleted ? 1 : 0).compareTo(b.isCompleted ? 1 : 0));
    }

    return list;
  }

  int _priorityToInt(String p) {
    switch (p) {
      case 'High': return 0;
      case 'Medium': return 1;
      case 'Low': return 2;
      default: return 3;
    }
  }

  void _addTask() {
    if (_taskController.text.trim().isEmpty) return;

    final newTask = Task(
      id: '',
      name: _taskController.text.trim(),
      isCompleted: false,
      priority: _priority,
      dueDate: _dueDate,
      subtasks: [],
    );
    _firebaseService.addTask(newTask);
    _taskController.clear();
    _dueDate = null;
    _priority = 'Medium';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Task Manager')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              children: [
                TextField(controller: _taskController, decoration: InputDecoration(labelText: 'Task Name')),
                Row(
                  children: [
                    DropdownButton<String>(
                      value: _priority,
                      onChanged: (val) => setState(() => _priority = val!),
                      items: ['High', 'Medium', 'Low'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                    ),
                    SizedBox(width: 10),
                    TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) setState(() => _dueDate = date);
                      },
                      child: Text(_dueDate == null ? 'Pick Date' : DateFormat.yMd().format(_dueDate!)),
                    ),
                    Spacer(),
                    ElevatedButton(onPressed: _addTask, child: Text('Add')),
                  ],
                ),
              ],
            ),
          ),
          Divider(),
          Row(
            children: [
              DropdownButton<String>(
                value: _sortOption,
                onChanged: (val) => setState(() => _sortOption = val!),
                items: ['None', 'Priority', 'Due Date', 'Completion'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              ),
              DropdownButton<String>(
                value: _filterPriority,
                onChanged: (val) => setState(() => _filterPriority = val!),
                items: ['All', 'High', 'Medium', 'Low'].map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
              ),
              Checkbox(value: _showCompleted, onChanged: (val) => setState(() => _showCompleted = val!)),
              Text("Completed"),
            ],
          ),
          Expanded(
            child: StreamBuilder<List<Task>>(
              stream: _firebaseService.getTasks(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                final tasks = _applyFilters(snapshot.data!);
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, i) => TaskTile(task: tasks[i], firebaseService: _firebaseService),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
