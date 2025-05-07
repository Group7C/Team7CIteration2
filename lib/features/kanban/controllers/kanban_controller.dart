import 'package:flutter/material.dart';
import '../../../features/common/models/task_model.dart';
import '../../../features/common/services/task_service.dart';

class KanbanController extends ChangeNotifier {
  // Maps for organizing tasks by status
  final Map<String, List<Task>> _tasksByStatus = {
    'to_do': [],
    'in_progress': [],
    'complete': [],
  };

  // Getters for the task lists
  List<Task> get todoTasks => _tasksByStatus['to_do'] ?? [];
  List<Task> get inProgressTasks => _tasksByStatus['in_progress'] ?? [];
  List<Task> get completeTasks => _tasksByStatus['complete'] ?? [];

  // Status display names
  final Map<String, String> statusDisplayNames = {
    'to_do': 'To Do',
    'in_progress': 'In Progress',
    'complete': 'Complete',
  };

  // Flag to track loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Project ID (optional, for filtering by project)
  int? _currentProjectId;
  int? get currentProjectId => _currentProjectId;

  // Initialize tasks
  Future<void> initTasks({int? projectId, int? userId}) async {
    _isLoading = true;
    _currentProjectId = projectId;
    notifyListeners();

    try {
      List<Task> tasks = [];
      
      // Load tasks based on projectId or userId
      if (projectId != null) {
        print('Loading tasks for project ID: $projectId');
        tasks = await TaskService.getTasksByProject(projectId);
      } else if (userId != null) {
        print('Loading tasks for user ID: $userId');
        tasks = await TaskService.getTasksByUser(userId);
      } else {
        print('No projectId or userId provided, returning empty task list');
      }

      // Clear existing tasks
      _tasksByStatus.forEach((key, _) => _tasksByStatus[key] = []);

      // Sort tasks into the appropriate lists
      for (final task in tasks) {
        if (_tasksByStatus.containsKey(task.status)) {
          _tasksByStatus[task.status]!.add(task);
        } else {
          // If status doesn't match our columns, default to to_do
          _tasksByStatus['to_do']!.add(task);
        }
      }
    } catch (e) {
      print('Error loading tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method to move a task between statuses
  Future<bool> moveTask(Task task, String newStatus) async {
    try {
      // First optimistically update the UI for immediate feedback
      print('Moving task ${task.taskId} from ${task.status} to $newStatus');
      
      // Remove the task from its current status list
      _tasksByStatus[task.status]!.removeWhere((t) => t.taskId == task.taskId);
      
      // Create an updated task with the new status
      Task updatedTask = Task(
        taskId: task.taskId,
        taskName: task.taskName,
        parent: task.parent,
        weighting: task.weighting,
        tags: task.tags,
        priority: task.priority,
        startDate: task.startDate,
        endDate: task.endDate,
        description: task.description,
        members: task.members,
        notificationFrequency: task.notificationFrequency,
        status: newStatus, // Updated status
        projectUid: task.projectUid,
        projectName: task.projectName,
        assignedMembers: task.assignedMembers,
      );
      
      // Add the task to the new status list
      _tasksByStatus[newStatus]!.add(updatedTask);
      
      // Notify listeners to update the UI immediately
      notifyListeners();
      
      // Then update the backend
      print('Updating task status in backend');
      final success = await TaskService.updateTaskStatus(task.taskId, newStatus);
      
      if (success['success'] == true) {
        print('Backend update successful');
        return true;
      } else {
        // If backend update fails, revert the change
        print('Backend update failed: ${success['error'] ?? 'Unknown error'}');
        print('Reverting UI change');
        
        // Remove from new status list
        _tasksByStatus[newStatus]!.removeWhere((t) => t.taskId == task.taskId);
        
        // Add back to original status list
        _tasksByStatus[task.status]!.add(task);
        
        // Notify listeners again
        notifyListeners();
        
        return false;
      }
    } catch (e) {
      print('Error moving task: $e');
      // If an error occurs, refresh tasks to ensure UI is in sync with backend
      await refreshTasks();
      return false;
    }
  }

  // Refresh tasks
  Future<void> refreshTasks() async {
    if (_currentProjectId != null) {
      await initTasks(projectId: _currentProjectId);
    }
  }
  
  // Method to add a new task directly to the board
  void addNewTask(Task task) {
    // Add task to the appropriate status list (default to to_do for new tasks)
    String status = task.status.isNotEmpty ? task.status : 'to_do';
    
    if (_tasksByStatus.containsKey(status)) {
      _tasksByStatus[status]!.add(task);
      notifyListeners();
      print('KanbanController: Added new task ${task.taskId} to $status column');
    } else {
      print('KanbanController: Invalid status ${task.status}');
    }
  }
}