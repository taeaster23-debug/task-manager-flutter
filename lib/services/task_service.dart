import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/task.dart';

class TaskService {
  final FirebaseFirestore _firestore;

  TaskService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _tasks(String uid) =>
      _firestore.collection('users').doc(uid).collection('tasks');

  Stream<List<Task>> watchTasks(String uid) {
    return _tasks(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _fromFirestore(doc))
            .toList());
  }

  Task _fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
      Task.fromJson(doc.id, doc.data());

  Future<void> addTask({
    required String uid,
    required String title,
    required String description,
    DateTime? dueDate,
  }) async {
    await _tasks(uid).add({
      'title': title.trim(),
      'description': description.trim(),
      'isCompleted': false,
      'dueDate': dueDate == null ? null : Timestamp.fromDate(dueDate),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateTask({
    required String uid,
    required Task task,
  }) async {
    await _tasks(uid).doc(task.id).update({
      'title': task.title.trim(),
      'description': task.description.trim(),
      'isCompleted': task.isCompleted,
      'dueDate': task.dueDate == null ? null : Timestamp.fromDate(task.dueDate!),
    });
  }

  Future<void> deleteTask({required String uid, required String taskId}) async {
    await _tasks(uid).doc(taskId).delete();
  }
}
