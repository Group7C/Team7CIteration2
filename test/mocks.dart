// test/mocks.dart
import 'package:flutter/material.dart';
import 'package:sevenc_iteration_two/Objects/task.dart';
import 'package:sevenc_iteration_two/projects/project_model.dart';
import 'package:sevenc_iteration_two/providers/projects_provider.dart';
import 'package:sevenc_iteration_two/providers/tasks_provider.dart';
import 'package:sevenc_iteration_two/usser/usserObject.dart';

class MockUsser extends ChangeNotifier implements Usser {
  @override
  String get id => 'mock-user-id';
  
  @override
  String get name => 'Mock User';
  
  @override
  String get email => 'mock@example.com';
  
  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
  };
  
  // Implement any other required methods with minimal functionality
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockProjectsProvider extends ChangeNotifier implements ProjectsProvider {
  final List<Project> _projects = [];
  
  @override
  List<Project> get projects => _projects;
  
  // Add minimal implementations for required methods
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockTaskProvider extends ChangeNotifier implements TaskProvider {
  final List<Task> _tasks = [];
  
  @override
  List<Task> get tasks => _tasks;
  
  @override
  Task? getTask(String title) {
    try {
      return _tasks.firstWhere((task) => task.title == title);
    } catch (e) {
      return null;
    }
  }
  
  @override
  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();
  }
  
  @override
  void removeTask(Task task) {
    _tasks.remove(task);
    notifyListeners();
  }
  
  // Add minimal implementations for other required methods
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}