import 'package:flutter/material.dart';
import '../models/task/task.dart'; // Updated import path to new Task model

class TaskProvider extends ChangeNotifier {
  final List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  void addTask(Task task) {
    print("Adding member to provider: ${task.title} with members: ${task.members}");
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

}
