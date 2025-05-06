// Task data model for kanban board [core structure for drag-drop operations]
import 'package:flutter/material.dart';

/// Task entity that displays on kanban board and can be dragged between columns
class KanbanTask {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String status; // Valid values: "todo", "in_progress", "completed"
  final String projectId;
  final String projectName;
  final String assigneeId;
  final String assigneeName;
  final Color projectColour; // Colour associated with parent project

  KanbanTask({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
    required this.projectId,
    required this.projectName,
    required this.assigneeId,
    required this.assigneeName,
    required this.projectColour,
  });

  // Creates copy with modified properties [useful when updating status]
  KanbanTask copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? status,
    String? projectId,
    String? projectName,
    String? assigneeId,
    String? assigneeName,
    Color? projectColour,
  }) {
    return KanbanTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      assigneeId: assigneeId ?? this.assigneeId,
      assigneeName: assigneeName ?? this.assigneeName,
      projectColour: projectColour ?? this.projectColour,
    );
  }
  
  // Checks if task is overdue [compares due date with current date]
  bool get isOverdue => dueDate.isBefore(DateTime.now());
  
  // Returns nicely formatted status text [converts snake_case to Title Case]
  String get formattedStatus {
    switch (status) {
      case 'todo':
        return 'To Do';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      default:
        return status.replaceAll('_', ' ');
    }
  }
}