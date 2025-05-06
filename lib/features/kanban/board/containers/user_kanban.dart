// Simple Kanban board for user tasks across projects
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/kanban_task.dart';
import '../components/home_kanban_board.dart';
import '../components/task_card.dart';
import '../../../../providers/tasks_provider.dart';
import '../../../../services/api_service.dart';
import '../../../../usser/usserObject.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserKanban extends StatefulWidget {
  final String? userId;
  
  const UserKanban({
    Key? key,
    this.userId,
  }) : super(key: key);

  @override
  State<UserKanban> createState() => _UserKanbanState();
}

class _UserKanbanState extends State<UserKanban> {
  List<KanbanTask> _userTasks = [];
  bool _isLoading = true;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _loadTasks();
  }
  
  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Get the current user's ID
      final usser = Provider.of<Usser>(context, listen: false);
      if (usser.usserID.isEmpty) {
        await usser.getID();
      }
      final userId = usser.usserID;
      
      // Fetch all projects for this user
      final projectsResponse = await http.get(
        Uri.parse('http://127.0.0.1:5000/get/user/projects?user_id=$userId'),
      );
      
      if (projectsResponse.statusCode != 200) {
        throw Exception('Failed to load projects');
      }
      
      final List<dynamic> projects = json.decode(projectsResponse.body);
      List<KanbanTask> allTasks = [];
      
      // For each project, fetch its tasks
      for (var project in projects) {
        final projectId = project['id'].toString();
        final projectName = project['name'] ?? 'Unknown Project';
        
        final tasksResponse = await http.get(
          Uri.parse('http://127.0.0.1:5000/project/$projectId/tasks'),
        );
        
        if (tasksResponse.statusCode == 200) {
          final List<dynamic> tasks = json.decode(tasksResponse.body);
          
          // Filter tasks assigned to the current user
          final userTasks = tasks.where((task) {
            final assigneeId = task['assignee_id']?.toString() ?? '';
            return assigneeId == userId;
          }).toList();
          
          // Convert API data to KanbanTask objects
          for (var taskData in userTasks) {
            DateTime dueDate;
            try {
              dueDate = taskData['due_date'] != null && taskData['due_date'].toString().isNotEmpty
                  ? DateTime.parse(taskData['due_date'].toString())
                  : DateTime.now().add(const Duration(days: 7));
            } catch (e) {
              dueDate = DateTime.now().add(const Duration(days: 7));
            }
            
            // Normalize status
            String status = 'todo';
            if (taskData['status'] != null) {
              final rawStatus = taskData['status'].toString().toLowerCase().trim();
              
              if (rawStatus.contains('progress') || rawStatus.contains('doing')) {
                status = 'in_progress';
              } else if (rawStatus.contains('done') || rawStatus.contains('complete')) {
                status = 'completed';
              } else if (rawStatus.contains('todo') || rawStatus.contains('not started')) {
                status = 'todo';
              }
            }
            
            // Get color based on project ID
            Color projectColor = _getProjectColor(taskData['project_id']);
            
            allTasks.add(KanbanTask(
              id: taskData['id'].toString(),
              title: taskData['title'] ?? 'Unnamed Task',
              description: taskData['description'] ?? '',
              dueDate: dueDate,
              status: status,
              projectId: projectId,
              projectName: projectName,
              assigneeId: userId,
              assigneeName: taskData['assignee_username'] ?? 'You',
              projectColour: projectColor,
            ));
          }
        }
      }
      
      // Sort tasks by due date
      allTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      
      setState(() {
        _userTasks = allTasks;
        _isLoading = false;
      });
      
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading tasks: $e';
        _isLoading = false;
      });
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
    // Update UI immediately for responsiveness
    setState(() {
      final index = _userTasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        _userTasks[index] = _userTasks[index].copyWith(status: newStatus);
      }
    });
    
    // Call the API to update the task status
    try {
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
        throw Exception('Failed to update task status');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating task: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
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
            const Text(
              'Error loading tasks',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
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
    
    // Show the kanban board with no edit/delete buttons
    return HomeKanbanBoard(
      todoTasks: todoTasks,
      inProgressTasks: inProgressTasks,
      completedTasks: completedTasks,
      onTaskStatusChanged: _onTaskStatusChanged,
      projectId: "all_projects",
      projectName: "All Tasks",
      onTaskUpdated: _loadTasks,
    );
  }
}