// A version of the KanbanColumn for the home page that doesn't show edit/delete buttons
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/kanban_task.dart';
import 'task_card.dart';
import '../../../../features/projects/screens/project_detail_screen.dart';

class HomeKanbanColumn extends StatelessWidget {
  final String title;
  final String status;
  final List<KanbanTask> tasks;
  final Function(String taskId, String newStatus) onTaskMoved;
  final String? projectId;
  final String projectName;
  final Function? onTaskUpdated;

  const HomeKanbanColumn({
    Key? key,
    required this.title,
    required this.status,
    required this.tasks,
    required this.onTaskMoved,
    this.projectId,
    this.projectName = 'Project',
    this.onTaskUpdated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Main container with border and styling
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.5),
          width: 1,
        ),
      ),
      // Wrap in drag target to accept tasks dropped here
      child: DragTarget<KanbanTask>(
        // Only accept tasks from different columns [avoid pointless moves]
        onWillAccept: (data) => data != null && data.status != status,
        
        // When a task is dropped here, change its status
        onAccept: (task) {
          debugPrint('Task ${task.id} dropped on $status column');
          onTaskMoved(task.id, status);
        },
        
        // The column UI that changes appearance when a task is dragged over
        builder: (context, candidateData, rejectedData) {
          return Container(
            padding: const EdgeInsets.all(12),
            // Highlight when a task is being dragged over this column
            decoration: BoxDecoration(
              color: candidateData.isNotEmpty
                  ? colorScheme.primaryContainer.withOpacity(0.2)
                  : null,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Column header with title and task count
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Column title
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Task count badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tasks.length.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const Divider(),
                
                // Task list or empty state
                if (tasks.isEmpty)
                  // Empty state message
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'No tasks',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ),
                  )
                else
                  // Scrollable list of draggable task cards
                  Expanded(
                    child: ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          // Make the card draggable
                          child: Draggable<KanbanTask>(
                            // Task data that will be passed when dropped
                            data: task,
                            // What shows while dragging (floating card)
                            feedback: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: KanbanTaskCard(
                                task: task,
                                showActions: false, // Never show actions on home page
                              ),
                            ),
                            // What's left behind in original location while dragging
                            childWhenDragging: Opacity(
                              opacity: 0.3,
                              child: KanbanTaskCard(
                                task: task,
                                showActions: false, // Never show actions on home page
                              ),
                            ),
                            // Normal card when not being dragged
                            child: KanbanTaskCard(
                              task: task,
                              showActions: false, // Never show actions on home page
                              onTap: (task) {
                                // Navigate to the project details screen when a task is tapped
                                _navigateToProject(context, task);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  // Navigate to project details when a task is tapped
  void _navigateToProject(BuildContext context, KanbanTask task) async {
    // Get project details from the task
    String projectName = task.projectName;
    String projectId = task.projectId;
    Color projectColor = task.projectColour;
    
    try {
      // Fetch more details about the project if needed
      final response = await http.get(
        Uri.parse('http://127.0.0.1:5000/project/$projectId'),
      );
      
      if (response.statusCode == 200) {
        final projectData = json.decode(response.body);
        
        // Navigate to project details screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectDetailScreen(
              projectName: projectData['name'] ?? projectName,
              deadline: DateTime.tryParse(projectData['deadline'] ?? '') ?? DateTime.now().add(const Duration(days: 7)),
              members: int.tryParse(projectData['members']?.toString() ?? '1') ?? 1,
              completedTasks: int.tryParse(projectData['completed_tasks']?.toString() ?? '0') ?? 0,
              totalTasks: int.tryParse(projectData['total_tasks']?.toString() ?? '0') ?? 0,
              color: projectColor,
              description: projectData['description'] ?? 'No description',
              joinCode: projectData['join_code'] ?? '',
              projectId: projectId,
            ),
          ),
        ).then((_) {
          // Refresh the tasks when returning from project details
          if (onTaskUpdated != null) {
            onTaskUpdated!();
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load project details'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}