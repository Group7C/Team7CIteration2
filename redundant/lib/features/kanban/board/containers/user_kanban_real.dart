// User-specific kanban board that shows tasks across projects - uses real API data
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/kanban_task.dart';
import '../components/kanban_board.dart';
import '../components/task_card.dart';
import '../utils/drag_drop_handler.dart';
import '../../../../providers/tasks_provider.dart';
import '../../../../features/projects/screens/project_detail_screen.dart';
import '../../../../features/navigation/navigation_service.dart';
import '../../../../services/api_service.dart';
import '../../../../usser/usserObject.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserKanbanReal extends StatefulWidget {
  final String? userId; // Optional userId parameter
  
  const UserKanbanReal({
    Key? key,
    this.userId,
  }) : super(key: key);

  @override
  State<UserKanbanReal> createState() => _UserKanbanRealState();
}

class _UserKanbanRealState extends State<UserKanbanReal> {
  // State variables
  List<KanbanTask> _userTasks = [];
  bool _isLoading = true;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    // Load tasks on init
    _loadTasks();
  }
  
  // Load tasks for this user
  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Get all tasks for user's projects first
      final allUserTasks = await ApiService.fetchUserTasks(context);
      
      // Debug: Print raw task data to see what's coming from the API
      print("Raw tasks from API: ${allUserTasks.length} tasks");
      for (var task in allUserTasks) {
        print("Task ${task['id']}: ${task['title']} (status: ${task['status']}) - Project: ${task['project_name']}");
      }
      
      // Get the current user's ID
      final usser = context.read<Usser>();
      if (usser.usserID.isEmpty) {
        await usser.getID();
      }
      
      // Filter tasks assigned to the current user
      final filteredTasks = allUserTasks.where((task) {
        final assigneeId = task['assignee_id']?.toString() ?? '';
        final isAssigned = assigneeId == usser.usserID;
        print("Task ${task['title']} - assigned to user ${usser.usserID}? $isAssigned");
        return isAssigned;
      }).toList();
      
      print("Filtered tasks for current user: ${filteredTasks.length} tasks");
      
      // Convert API data to KanbanTask objects
      _userTasks = filteredTasks.map((taskData) {
        // Ensure we have a valid date object
        DateTime dueDate;
        try {
          dueDate = taskData['due_date'] != null && taskData['due_date'].toString().isNotEmpty
              ? DateTime.parse(taskData['due_date'].toString())
              : DateTime.now().add(const Duration(days: 7));
        } catch (e) {
          print("Error parsing date for task ${taskData['title']}: $e");
          dueDate = DateTime.now().add(const Duration(days: 7));
        }
        
        // IMPORTANT FIX: Ensure we have a valid status string
        // This is a key improvement - making sure we normalize statuses
        String status = 'todo'; // Default to 'todo'
        if (taskData['status'] != null) {
          final rawStatus = taskData['status'].toString().toLowerCase().trim();
          print("Raw status for task ${taskData['id']}: '$rawStatus'");
          
          // Normalize status values to match exactly what the Kanban board expects
          if (rawStatus == 'in progress' || rawStatus == 'inprogress' || rawStatus == 'in_progress') {
            status = 'in_progress';
          } else if (rawStatus == 'done' || rawStatus == 'complete' || rawStatus == 'completed') {
            status = 'completed';
          } else if (rawStatus == 'to do' || rawStatus == 'todo' || rawStatus == 'to-do' || rawStatus == 'not started') {
            status = 'todo';
          } else {
            status = 'todo'; // Fallback for unrecognized statuses
          }
          
          print("Normalized status: '$status'");
        }
        
        // Create KanbanTask object with normalized status
        return KanbanTask(
          id: taskData['id'].toString(),
          title: taskData['title'] ?? 'Unnamed Task',
          description: taskData['description'] ?? '',
          dueDate: dueDate,
          status: status, // Use normalized status
          projectId: taskData['project_id']?.toString() ?? '',
          projectName: taskData['project_name'] ?? 'Unknown Project',
          assigneeId: taskData['assignee_id']?.toString() ?? '',
          assigneeName: taskData['assignee_username'] ?? 'Unassigned',
          projectColour: _getProjectColor(taskData['project_id']),
        );
      }).toList();
      
      // Log the processed tasks for debugging
      print("Processed ${_userTasks.length} tasks for the user");
      for (var task in _userTasks) {
        print("Task: ${task.title} (${task.status}) - Project: ${task.projectName}");
      }
      
      // Sort tasks by due date
      _userTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      
    } catch (e) {
      debugPrint('Error loading tasks: $e');
      setState(() {
        _errorMessage = 'Failed to load tasks: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  // Get color based on project ID
  Color _getProjectColor(dynamic projectId) {
    const colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    
    if (projectId == null) return Colors.grey;
    
    try {
      final id = int.parse(projectId.toString());
      return colors[id % colors.length];
    } catch (e) {
      return Colors.grey;
    }
  }
  
  // Handle task movement between columns
  Future<void> _onTaskStatusChanged(String taskId, String newStatus) async {
    debugPrint('Task status change requested: $taskId -> $newStatus');
    
    // Update UI immediately for responsiveness
    setState(() {
      // Find and update the task in our local list
      final index = _userTasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        _userTasks[index] = _userTasks[index].copyWith(status: newStatus);
      }
    });
    
    // Call the API to update the task status
    try {
      final success = await ApiService.updateTaskStatus(taskId, newStatus);
      
      // Show feedback based on result
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success 
              ? 'Task moved to ${newStatus.replaceAll('_', ' ').toUpperCase()}'
              : 'Failed to move task'),
            duration: const Duration(seconds: 2),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating task: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Show loading spinner while data loads
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    // Show error message if loading failed
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.withOpacity(0.8),
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading tasks',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _loadTasks,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      );
    }
    
    // Show empty state if no tasks
    if (_userTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No tasks assigned to you',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _loadTasks,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      );
    }
    
    // Group tasks by status
    final todoTasks = _userTasks.where((t) => t.status == "todo").toList();
    final inProgressTasks = _userTasks.where((t) => t.status == "in_progress").toList();
    final completedTasks = _userTasks.where((t) => t.status == "completed").toList();
    
    // Display task counts for debugging
    print("Todo tasks: ${todoTasks.length}");
    print("In Progress tasks: ${inProgressTasks.length}");
    print("Completed tasks: ${completedTasks.length}");
    
    // Show the kanban board
    return CustomUserKanbanBoard(
      todoTasks: todoTasks,
      inProgressTasks: inProgressTasks,
      completedTasks: completedTasks,
      onTaskStatusChanged: _onTaskStatusChanged,
      onTaskTapped: _navigateToProject,
    );
  }
  
  // Navigate to the project details when a task is tapped
  Future<void> _navigateToProject(KanbanTask task) async {
    try {
      // Fetch the project details from the API
      final response = await http.get(
        Uri.parse('http://127.0.0.1:5000/project/${task.projectId}'),
      );

      if (response.statusCode == 200) {
        final projectData = json.decode(response.body);
        
        // Navigate to project details screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectDetailScreen(
              projectName: projectData['name'] ?? 'Unnamed Project',
              deadline: DateTime.parse(projectData['deadline']),
              members: projectData['members'] ?? 0,
              completedTasks: projectData['completed_tasks'] ?? 0,
              totalTasks: projectData['total_tasks'] ?? 0,
              color: task.projectColour,
              description: projectData['description'] ?? 'No description',
              joinCode: projectData['join_code'] ?? '',
              projectId: task.projectId,
            ),
          ),
        ).then((_) {
          // Refresh the tasks when returning from project details
          _loadTasks();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
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

// Custom Kanban Board for the user view that makes tasks clickable
class CustomUserKanbanBoard extends StatelessWidget {
  final List<KanbanTask> todoTasks;
  final List<KanbanTask> inProgressTasks;
  final List<KanbanTask> completedTasks;
  final Function(String taskId, String newStatus) onTaskStatusChanged;
  final Function(KanbanTask task) onTaskTapped;
  
  const CustomUserKanbanBoard({
    Key? key,
    required this.todoTasks,
    required this.inProgressTasks,
    required this.completedTasks,
    required this.onTaskStatusChanged,
    required this.onTaskTapped,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Three workflow columns laid out horizontally [standard kanban pattern]
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // To-do column
        Expanded(
          child: CustomUserKanbanColumn(
            title: "To Do",
            tasks: todoTasks,
            status: "todo",
            onTaskMoved: onTaskStatusChanged,
            onTaskTapped: onTaskTapped,
          ),
        ),
        const SizedBox(width: 12),
        
        // In-progress column
        Expanded(
          child: CustomUserKanbanColumn(
            title: "In Progress",
            tasks: inProgressTasks,
            status: "in_progress",
            onTaskMoved: onTaskStatusChanged,
            onTaskTapped: onTaskTapped,
          ),
        ),
        const SizedBox(width: 12),
        
        // Completed column
        Expanded(
          child: CustomUserKanbanColumn(
            title: "Completed",
            tasks: completedTasks,
            status: "completed",
            onTaskMoved: onTaskStatusChanged,
            onTaskTapped: onTaskTapped,
          ),
        ),
      ],
    );
  }
}

// Custom Kanban Column for user view with clickable tasks
class CustomUserKanbanColumn extends StatelessWidget {
  final String title;
  final String status;
  final List<KanbanTask> tasks;
  final Function(String taskId, String newStatus) onTaskMoved;
  final Function(KanbanTask task) onTaskTapped;

  const CustomUserKanbanColumn({
    Key? key,
    required this.title,
    required this.status,
    required this.tasks,
    required this.onTaskMoved,
    required this.onTaskTapped,
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
        // Only accept tasks from different columns
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
                                onTap: onTaskTapped,
                              ),
                            ),
                            // What's left behind in original location while dragging
                            childWhenDragging: Opacity(
                              opacity: 0.3,
                              child: KanbanTaskCard(
                                task: task,
                                onTap: onTaskTapped,
                              ),
                            ),
                            // Normal card when not being dragged
                            child: KanbanTaskCard(
                              task: task,
                              onTap: onTaskTapped,
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