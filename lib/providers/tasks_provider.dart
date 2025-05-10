import 'package:flutter/material.dart';
import '../Objects/task.dart';

class TaskProvider extends ChangeNotifier {
  final List<Task> _tasks = [];

  // Simple getter for tasks
  List<Task> get tasks => _tasks;
  
  // Load mock tasks [For offline mode testing]
  void loadMockTasks(List<Task> mockTasks) {
    _tasks.clear();
    _tasks.addAll(mockTasks);
    notifyListeners();
  }

  void addTask(Task task) {
    print("Adding task to provider: ${task.title} with members: ${task.members}");
    _tasks.add(task);
    print("Task added to provider: ${task.title} with members: ${task.members}");
    notifyListeners();
  }

  void removeTask(Task task) {
    _tasks.remove(task);
    notifyListeners();
  }

  void updateTask(Task updatedTask) {
    int index = _tasks.indexWhere((task) => task.title == updatedTask.title);
    if (index != -1) {
      _tasks[index] = updatedTask;
      notifyListeners();
    }
  }

  Task? getTask(String title) {
    try {
      return _tasks.firstWhere((task) => task.title == title);
    } catch (e) {
      return null;
    }
  }

  // Update task using original title as identifier
  void updateTaskByOriginalTitle(String originalTitle, Task updatedTask) {
    int index = _tasks.indexWhere((task) => task.title == originalTitle);
    if (index != -1) {
      _tasks[index] = updatedTask;
      notifyListeners();
    }
  }
}