// Project-specific kanban board container
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/kanban_task.dart';
import '../components/kanban_board.dart';
import '../utils/drag_drop_handler.dart';
import '../mock_data/mock_tasks.dart';
import '../../../../providers/tasks_provider.dart';
import '../../../../Objects/task.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProjectKanban extends StatefulWidget {
  final String projectId;
  final Color? projectColor;
  final List<Map<String, dynamic>>? tasks;
  
  const ProjectKanban({
    Key? key,
    required this.projectId,
    this.projectColor,
    this.tasks,
  }) : super(key: key);

  @override
  State<ProjectKanban> createState() => _ProjectKanbanState();
}

class _ProjectKanbanState extends State<ProjectKanban> {
  // State variables
  List<KanbanTask> _projectTasks = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadTasks();
  }
  
  @override
  void didUpdateWidget(ProjectKanban oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tasks != widget.tasks) {
      _loadTasks();
    }
  }
  
  // Load tasks for this project
  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      print('=== DEBUG KANBAN: Loading tasks ===');
      print('Project ID: ${widget.projectId}');
      print('Tasks provided: ${widget.tasks?.length ?? 0}');
      
      if (widget.tasks != null) {
        // Use provided tasks
        print('Converting provided tasks to KanbanTask objects...');
        _projectTasks = widget.tasks!.map((task) => KanbanTask(
          id: task['id'],
          title: task['title'],
          description: task['description'],
          dueDate: DateTime.parse(task['due_date']),
          status: task['status'],
          projectId: widget.projectId,
          projectName: task['project_name'] ?? widget.projectId,
          assigneeId: task['assignee_id'],
          assigneeName: task['assignee_username'],
          projectColour: widget.projectColor ?? Colors.blue,
        )).toList();
        
        print('Converted tasks:');
        for (var task in _projectTasks) {
          print('  - ${task.title} (${task.status})');
        }
      } else {
        print('No tasks provided, using mock data');
        _projectTasks = MockTasks.getTasksByProject(widget.projectId);
        
        if (widget.projectColor != null) {
          _projectTasks = _projectTasks.map((task) {
            return task.copyWith(projectColour: widget.projectColor!);
          }).toList();
        }
      }
      
      // Sort tasks by due date
      _projectTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      
      print('Total tasks loaded: ${_projectTasks.length}');
      
      // Group tasks by status for debugging
      final todoTasks = _projectTasks.where((t) => t.status == "todo").toList();
      final inProgressTasks = _projectTasks.where((t) => t.status == "in_progress").toList();
      final completedTasks = _projectTasks.where((t) => t.status == "completed").toList();
      
      print('Tasks by status:');
      print('  - Todo: ${todoTasks.length}');
      print('  - In Progress: ${inProgressTasks.length}');
      print('  - Completed: ${completedTasks.length}');
      
    } catch (e) {
      debugPrint('Error loading tasks: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  // Handle task movement between columns
  Future<void> _onTaskStatusChanged(String taskId, String newStatus) async {
    debugPrint('Task status change requested: $taskId -> $newStatus');
    
    // Update UI immediately for responsiveness
    setState(() {
      final index = _projectTasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        _projectTasks[index] = _projectTasks[index].copyWith(status: newStatus);
      }
    });
    
    try {
      // Call the API to update task status
      final response = await http.put(
        Uri.parse('http://127.0.0.1:5000/task/$taskId/status'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': newStatus}),
      );
      
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task moved to ${newStatus.replaceAll('_', ' ').toUpperCase()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        // Revert the UI change if the API call failed
        setState(() {
          final task = _projectTasks.firstWhere((t) => t.id == taskId);
          final originalTask = widget.tasks?.firstWhere((t) => t['id'] == taskId);
          if (originalTask != null) {
            final index = _projectTasks.indexWhere((t) => t.id == taskId);
            _projectTasks[index] = task.copyWith(status: originalTask['status']);
          }
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to move task'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error updating task status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
  
  // Method to refresh the kanban board
  void refreshBoard() {
    if (mounted) {
      _loadTasks();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Listen to the task provider for changes
    final taskProvider = Provider.of<TaskProvider>(context);
    final providerTasks = taskProvider.tasks;
    
    // Check if we need to refresh based on provider changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refreshBoard();
    });
    
    // Show loading spinner while data loads
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    // Combine mock tasks and provider tasks
    final List<KanbanTask> allTasks = [..._projectTasks];
    
    // Convert provider tasks to KanbanTask format and add to list
    for (final providerTask in providerTasks) {
      // Only add tasks that belong to this project
      if (providerTask.parentProject != null && 
          providerTask.parentProject!.replaceAll(' ', '').toLowerCase() == widget.projectId) {
        
        // Determine task status based on task properties (you might want to modify this logic)
        String taskStatus = 'todo';
        // Simple logic: if the start date is before now and end date is after now, it's in progress
        if (providerTask.startDate.isBefore(DateTime.now()) && 
            providerTask.endDate.isAfter(DateTime.now())) {
          taskStatus = 'in_progress';
        }
        // If end date is before now, it's completed
        else if (providerTask.endDate.isBefore(DateTime.now())) {
          taskStatus = 'completed';
        }
        
        // Check if task already exists in the list
        final existingIndex = allTasks.indexWhere((t) => t.title == providerTask.title);
        if (existingIndex == -1) {
          // Convert Task to KanbanTask
          final kanbanTask = KanbanTask(
            id: providerTask.title.replaceAll(' ', '_').toLowerCase(),
            title: providerTask.title,
            description: providerTask.description,
            dueDate: providerTask.endDate,
            status: taskStatus,
            projectId: widget.projectId,
            projectName: providerTask.parentProject ?? 'Unknown Project',
            assigneeId: providerTask.members.keys.isNotEmpty ? providerTask.members.keys.first : 'unknown',
            assigneeName: providerTask.members.keys.isNotEmpty ? providerTask.members.keys.first : 'Unassigned',
            projectColour: widget.projectColor ?? Colors.blue,
          );
          allTasks.add(kanbanTask);
        } else {
          // Update existing task if it's already in the list
          allTasks[existingIndex] = KanbanTask(
            id: providerTask.title.replaceAll(' ', '_').toLowerCase(),
            title: providerTask.title,
            description: providerTask.description,
            dueDate: providerTask.endDate,
            status: allTasks[existingIndex].status, // Preserve current status
            projectId: widget.projectId,
            projectName: providerTask.parentProject ?? 'Unknown Project',
            assigneeId: providerTask.members.keys.isNotEmpty ? providerTask.members.keys.first : 'unknown',
            assigneeName: providerTask.members.keys.isNotEmpty ? providerTask.members.keys.first : 'Unassigned',
            projectColour: widget.projectColor ?? Colors.blue,
          );
        }
      }
    }
    
    // Show empty state if no tasks
    if (allTasks.isEmpty) {
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
              'No tasks in this project yet',
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
    final todoTasks = allTasks.where((t) => t.status == "todo").toList();
    final inProgressTasks = allTasks.where((t) => t.status == "in_progress").toList();
    final completedTasks = allTasks.where((t) => t.status == "completed").toList();
    
    print('=== KANBAN BUILD ===');
    print('Displaying tasks: ${allTasks.length}');
    print('  - Todo: ${todoTasks.length}');
    print('  - In Progress: ${inProgressTasks.length}');
    print('  - Completed: ${completedTasks.length}');
    
    // Show the kanban board
    return KanbanBoard(
      todoTasks: todoTasks,
      inProgressTasks: inProgressTasks,
      completedTasks: completedTasks,
      onTaskStatusChanged: _onTaskStatusChanged,
    );
  }
}