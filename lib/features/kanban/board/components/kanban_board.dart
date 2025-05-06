// Kanban board - main task tracking interface [handles column layout and drag-drop task movement]
import 'package:flutter/material.dart';
import '../models/kanban_task.dart';
import 'kanban_column.dart';

class KanbanBoard extends StatelessWidget {
  // Task lists for each workflow stage [sorted by status]
  final List<KanbanTask> todoTasks;
  final List<KanbanTask> inProgressTasks;
  final List<KanbanTask> completedTasks;
  
  // Task moved callback [fires when tasks dragged between columns]
  final Function(String taskId, String newStatus) onTaskStatusChanged;
  
  // Project information and task update callback
  final String? projectId;
  final String projectName;
  final Function? onTaskUpdated;
  
  const KanbanBoard({
    Key? key,
    required this.todoTasks,
    required this.inProgressTasks,
    required this.completedTasks,
    required this.onTaskStatusChanged,
    this.projectId,
    this.projectName = 'Project',
    this.onTaskUpdated,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Three workflow columns laid out horizontally [standard kanban pattern]
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // To-do column [starting point for new tasks]
        Expanded(
          child: KanbanColumn(
            title: "To Do",
            tasks: todoTasks,
            status: "todo",
            onTaskMoved: onTaskStatusChanged,
            projectId: projectId,
            projectName: projectName,
            onTaskUpdated: onTaskUpdated,
          ),
        ),
        const SizedBox(width: 12),
        
        // In-progress column [tasks currently being worked on]
        Expanded(
          child: KanbanColumn(
            title: "In Progress",
            tasks: inProgressTasks,
            status: "in_progress",
            onTaskMoved: onTaskStatusChanged,
            projectId: projectId,
            projectName: projectName,
            onTaskUpdated: onTaskUpdated,
          ),
        ),
        const SizedBox(width: 12),
        
        // Completed column [finished tasks end up here]
        Expanded(
          child: KanbanColumn(
            title: "Completed",
            tasks: completedTasks,
            status: "completed",
            onTaskMoved: onTaskStatusChanged,
            projectId: projectId,
            projectName: projectName,
            onTaskUpdated: onTaskUpdated,
          ),
        ),
      ],
    );
  }
}