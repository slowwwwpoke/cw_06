import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference getUserTasksCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('tasks');
  }

  Future<List<Task>> fetchTasks(String userId) async {
    final snapshot = await getUserTasksCollection(userId).get();
    return Future.wait(snapshot.docs.map((doc) async {
      Task task = Task.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      task.subtasks = await fetchSubtasks(userId, doc.id);
      return task;
    }));
  }

  Future<List<Task>> fetchSubtasks(String userId, String taskId) async {
    final subSnapshot = await getUserTasksCollection(userId)
        .doc(taskId)
        .collection('subtasks')
        .get();

    return subSnapshot.docs
        .map((doc) => Task.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> addTask(String userId, Task task) async {
    await getUserTasksCollection(userId).add(task.toMap());
  }

  Future<void> updateTask(String userId, Task task) async {
    await getUserTasksCollection(userId).doc(task.id).update(task.toMap());
  }

  Future<void> deleteTask(String userId, String taskId) async {
    await getUserTasksCollection(userId).doc(taskId).delete();
  }

  Future<void> addSubtask(String userId, String taskId, Task subtask) async {
    await getUserTasksCollection(userId)
        .doc(taskId)
        .collection('subtasks')
        .add(subtask.toMap());
  }

  Future<void> updateSubtask(
      String userId, String parentTaskId, Task subtask) async {
    await getUserTasksCollection(userId)
        .doc(parentTaskId)
        .collection('subtasks')
        .doc(subtask.id)
        .update(subtask.toMap());
  }

  Future<void> deleteSubtask(
      String userId, String parentTaskId, String subtaskId) async {
    await getUserTasksCollection(userId)
        .doc(parentTaskId)
        .collection('subtasks')
        .doc(subtaskId)
        .delete();
  }

  Future<void> updateSubtaskCompletion(
      String userId, String parentTaskId, String subtaskId, bool isDone) async {
    await getUserTasksCollection(userId)
        .doc(parentTaskId)
        .collection('subtasks')
        .doc(subtaskId)
        .update({'isDone': isDone});
  }
}
