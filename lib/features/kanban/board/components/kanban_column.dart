// A single column in the kanban board that can receive dropped tasks
import 'package:flutter/material.dart';
import '../models/kanban_task.dart';
import 'task_card.dart';
import '../../../../features/tasks/modals/edit_task_modal.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class KanbanColumn extends StatelessWidget {
  final String title;
  final String status;
  final List<KanbanTask> tasks;
  final Function(String taskId, String newStatus) onTaskMoved;
  final String? projectId;
  final String projectName;
  final Function? onTaskUpdated;

  const KanbanColumn({
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
                                showActions: true,
                              ),
                            ),
                            // What's left behind in original location while dragging
                            childWhenDragging: Opacity(
                              opacity: 0.3,
                              child: KanbanTaskCard(
                                task: task,
                                showActions: true,
                              ),
                            ),
                            // Normal card when not being dragged
                            child: KanbanTaskCard(
                              task: task,
                              showActions: true,
                              onEdit: (task) async {
                                // Fetch real project members before showing the modal
                                List<String> projectMembers = ['You'];
                                
                                try {
                                  if (projectId != null) {
                                    final response = await http.get(
                                      Uri.parse('http://127.0.0.1:5000/project/$projectId/members'),
                                    );
                                    
                                    if (response.statusCode == 200) {
                                      final List<dynamic> members = json.decode(response.body);
                                      // Extract usernames from the response
                                      projectMembers = members.map((member) => 
                                        member['username'] as String
                                      ).toList();
                                      
                                      // If list is empty, add a default user
                                      if (projectMembers.isEmpty) {
                                        projectMembers = ['You'];
                                      }
                                    }
                                  }
                                } catch (e) {
                                  print('Error fetching project members: $e');
                                }
                                
                                // Make sure the assignee is included in the project members
                                if (!projectMembers.contains(task.assigneeName)) {
                                  projectMembers.add(task.assigneeName);
                                }
                                
                                // Show the edit task modal when edit icon is clicked
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                  ),
                                  builder: (ctx) {
                                    return EditTaskModal(
                                      task: task,
                                      projectName: projectName,
                                      projectId: projectId,
                                      projectMembers: projectMembers,
                                      onTaskUpdated: (updatedTask) {
                                        // Refresh the task list
                                        if (onTaskUpdated != null) {
                                          onTaskUpdated!();
                                        }
                                        
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Task updated successfully!'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                              onDelete: (task) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Delete task: ${task.title}'),
                                    backgroundColor: Colors.red,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                                // Here you would implement delete functionality
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
}