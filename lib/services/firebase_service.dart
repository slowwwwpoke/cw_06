import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class FirebaseService {
  final CollectionReference _tasks = FirebaseFirestore.instance.collection('tasks');

  Stream<List<Task>> getTasks() {
    return _tasks.snapshots().map((snapshot) => snapshot.docs
      .map((doc) => Task.fromMap(doc.id, doc.data() as Map<String, dynamic>))
      .toList());
  }

  Future<void> addTask(Task task) {
    return _tasks.add(task.toMap());
  }

  Future<void> updateTask(Task task) {
    return _tasks.doc(task.id).update(task.toMap());
  }

  Future<void> deleteTask(String id) {
    return _tasks.doc(id).delete();
  }
}
