import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/task.dart';
import '../services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _service;
  StreamSubscription<List<Task>>? _subscription;
  List<Task> _tasks = [];
  bool _loading = false;
  String? _error;

  TaskProvider({TaskService? service}) : _service = service ?? TaskService();

  List<Task> get tasks => List.unmodifiable(_tasks);
  bool get loading => _loading;
  String? get error => _error;
  int get completedCount => _tasks.where((t) => t.isCompleted).length;
  int get pendingCount => _tasks.where((t) => !t.isCompleted).length;

  void startListening(String uid) {
    _subscription?.cancel();
    _error = null;
    _subscription = _service.watchTasks(uid).listen(
      (items) {
        _tasks = items;
        notifyListeners();
      },
      onError: (_) {
        _error = 'Could not load tasks. Check Firestore rules and connection.';
        notifyListeners();
      },
    );
  }

  Future<bool> addTask({
    required String uid,
    required String title,
    required String description,
    DateTime? dueDate,
  }) => _perform(() => _service.addTask(
        uid: uid,
        title: title,
        description: description,
        dueDate: dueDate,
      ));

  Future<bool> updateTask({required String uid, required Task task}) =>
      _perform(() => _service.updateTask(uid: uid, task: task));

  Future<bool> deleteTask({required String uid, required String taskId}) =>
      _perform(() => _service.deleteTask(uid: uid, taskId: taskId));

  Future<bool> toggleTask(String uid, Task task) => updateTask(
        uid: uid,
        task: Task(
          id: task.id,
          title: task.title,
          description: task.description,
          isCompleted: !task.isCompleted,
          dueDate: task.dueDate,
          createdAt: task.createdAt,
        ),
      );

  Future<bool> _perform(Future<void> Function() action) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await action();
      return true;
    } catch (_) {
      _error = 'Could not save the task. Please try again.';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
