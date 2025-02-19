// lib/home/components/kanban_board/kanban_board.dart
import 'package:flutter/material.dart';
import '../../../data/temp_data.dart';
import '../../../models/task.dart';
import 'kanban_column.dart';

class KanbanBoard extends StatefulWidget {
  const KanbanBoard({super.key});

  @override
  State<KanbanBoard> createState() => _KanbanBoardState();
}

class _KanbanBoardState extends State<KanbanBoard> {
  void _onTaskMoved(String taskId, String newStatus) {
    setState(() {
      KanbanData.updateTaskStatus(taskId, newStatus);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: KanbanColumn(
            title: "To Do",
            status: "todo",
            tasks: KanbanData.getTasksByStatus("todo"),
            onTaskMoved: _onTaskMoved,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: KanbanColumn(
            title: "In Progress",
            status: "in_progress",
            tasks: KanbanData.getTasksByStatus("in_progress"),
            onTaskMoved: _onTaskMoved,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: KanbanColumn(
            title: "Completed",
            status: "completed",
            tasks: KanbanData.getTasksByStatus("completed"),
            onTaskMoved: _onTaskMoved,
          ),
        ),
      ],
    );
  }
}
