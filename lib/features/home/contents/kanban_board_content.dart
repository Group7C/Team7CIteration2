import 'package:flutter/material.dart';
import '../../../features/kanban/board/containers/user_kanban.dart';

class KanbanBoardContent extends StatelessWidget {
  final Map<String, KanbanColumn>? columns; // Made optional for compatibility

  const KanbanBoardContent({
    Key? key,
    this.columns, // Now optional
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Wrap the kanban board in an Expanded widget inside a Column
    // This ensures the kanban columns have proper height constraints
    return Column(
      children: [
        Expanded(
          child: Container(
            constraints: const BoxConstraints(
              minHeight: 300, // Minimum height to ensure visibility
            ),
            child: const UserKanban(),
          ),
        ),
      ],
    );
  }
}

// Keep the original classes for backward compatibility
class KanbanColumn {
  final List<TaskItem> tasks;
  final Color color;

  KanbanColumn({
    required this.tasks,
    required this.color,
  });
}

class TaskItem {
  final String title;
  final String project;
  final String dueDate;
  final String priority;
  final String assignee;
  final String? id;

  TaskItem({
    required this.title,
    required this.project,
    required this.dueDate,
    required this.priority,
    required this.assignee,
    this.id,
  });
}