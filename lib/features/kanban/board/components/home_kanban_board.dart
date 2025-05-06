// Kanban board for the home page - task tracking interface without edit/delete buttons
import 'package:flutter/material.dart';
import '../models/kanban_task.dart';
import 'home_kanban_column.dart';

class HomeKanbanBoard extends StatelessWidget {
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
  
  const HomeKanbanBoard({
    Key? key,
    required this.todoTasks,
    required this.inProgressTasks,
    required this.completedTasks,
    required this.onTaskStatusChanged,
    this.projectId,
    this.projectName = 'All Tasks',
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
          child: HomeKanbanColumn(
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
          child: HomeKanbanColumn(
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
          child: HomeKanbanColumn(
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