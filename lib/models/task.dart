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
