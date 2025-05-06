// Project-specific kanban board container
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/kanban_task.dart';
import '../components/kanban_board.dart';
import '../utils/drag_drop_handler.dart';
import '../mock_data/mock_tasks.dart';
import '../../../../providers/tasks_provider.dart';
import '../../../../models/task/task.dart'; // Updated import path to new Task model
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProjectKanban extends StatefulWidget {
  final String projectId;
  final Color? projectColor;
  final List<Map<String, dynamic>>? tasks;
  final Function(String, String)? onTaskStatusChanged;
  
  const ProjectKanban({
    Key? key,
    required this.projectId,
    this.projectColor,
    this.tasks,
    this.onTaskStatusChanged,
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
      if (widget.tasks != null) {
        // Use provided tasks
        _projectTasks = widget.tasks!.map((task) => KanbanTask(
          id: task['id'].toString(),  // Convert int to string
          title: task['title'],
          description: task['description'],
          dueDate: DateTime.parse(task['due_date']),
          status: task['status'],
          projectId: widget.projectId,
          projectName: task['project_name'] ?? widget.projectId,
          assigneeId: task['assignee_id']?.toString() ?? '',  // Convert int to string and handle null
          assigneeName: task['assignee_username'] ?? 'Unassigned',
          projectColour: widget.projectColor ?? Colors.blue,
        )).toList();
      } else {
        // Try to fetch tasks from the backend API if we have a numeric project ID
        if (int.tryParse(widget.projectId) != null) {
          try {
            print('Fetching tasks for project ${widget.projectId}');
            final response = await http.get(
              Uri.parse('http://127.0.0.1:5000/project/${widget.projectId}/tasks'),
            );
            
            if (response.statusCode == 200) {
              final List<dynamic> tasksData = json.decode(response.body);
              print('Received ${tasksData.length} tasks from API');
              
              _projectTasks = tasksData.map((task) => KanbanTask(
                id: task['id'].toString(),
                title: task['title'] ?? 'Untitled Task',
                description: task['description'] ?? '',
                dueDate: DateTime.tryParse(task['due_date'] ?? '') ?? DateTime.now(),
                status: task['status'] ?? 'todo',
                projectId: widget.projectId,
                projectName: task['project_name'] ?? widget.projectId,
                assigneeId: task['assignee_id']?.toString() ?? '',
                assigneeName: task['assignee_username'] ?? 'Unassigned',
                projectColour: widget.projectColor ?? Colors.blue,
              )).toList();
            } else {
              print('Failed to fetch tasks: ${response.statusCode} - ${response.body}');
              // Fall back to mock data if API fetch fails
              _projectTasks = MockTasks.getTasksByProject(widget.projectId);
            }
          } catch (e) {
            print('Error fetching tasks: $e');
            // Fall back to mock data if API fetch fails
            _projectTasks = MockTasks.getTasksByProject(widget.projectId);
          }
        } else {
          // Use mock data as fallback if project ID is not numeric
          _projectTasks = MockTasks.getTasksByProject(widget.projectId);
        }
        
        if (widget.projectColor != null) {
          _projectTasks = _projectTasks.map((task) {
            return task.copyWith(projectColour: widget.projectColor!);
          }).toList();
        }
      }
      
      // Sort tasks by due date
      _projectTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      
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
    // Don't rebuild immediately - wait for API response
    try {
      print('Updating task $taskId status to $newStatus');
      
      // Call the API to update task status
      final response = await http.put(
        Uri.parse('http://127.0.0.1:5000/task/$taskId/status'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': newStatus}),
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        // Find the task and update its status locally
        final taskIndex = _projectTasks.indexWhere((task) => task.id == taskId);
        if (taskIndex != -1) {
          setState(() {
            // Create an updated task with the new status
            _projectTasks[taskIndex] = _projectTasks[taskIndex].copyWith(status: newStatus);
          });
          
          // Call the callback if provided
          if (widget.onTaskStatusChanged != null) {
            widget.onTaskStatusChanged!(taskId, newStatus);
          }
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task moved to ${newStatus.replaceAll('_', ' ').toUpperCase()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
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
    // Show loading spinner while data loads
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    // Show empty state if no tasks
    if (_projectTasks.isEmpty) {
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
    final todoTasks = _projectTasks.where((t) => t.status == "todo").toList();
    final inProgressTasks = _projectTasks.where((t) => t.status == "in_progress").toList();
    final completedTasks = _projectTasks.where((t) => t.status == "completed").toList();
    
    // Show the kanban board
    return KanbanBoard(
      todoTasks: todoTasks,
      inProgressTasks: inProgressTasks,
      completedTasks: completedTasks,
      onTaskStatusChanged: _onTaskStatusChanged,
      projectId: widget.projectId,
      projectName: _projectTasks.isNotEmpty ? _projectTasks.first.projectName : 'Project',
      onTaskUpdated: refreshBoard,
    );
  }
}