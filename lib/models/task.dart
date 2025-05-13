// lib/models/task.dart
class Task {
  final String id;
  final String title;
  final String dueDate;
  final String assignee;
  final String status;

  Task({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.assignee,
    required this.status,
  });

  // copyWith creates a new Task with most properties from original task
  // but lets you selectively update specific fields [immutability pattern]
  // useful when updating a task without changing all its properties
  // e.g. task.copyWith(status: "completed") creates new Task with just status changed
  // so basically it's a shortcut to create a copy with just few changes instead of rewriting everything
  Task copyWith({
    String? id,
    String? title,
    String? dueDate,
    String? assignee,
    String? status,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      assignee: assignee ?? this.assignee,
      status: status ?? this.status,
    );
  }
}
