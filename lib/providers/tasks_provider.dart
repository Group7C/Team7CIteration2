import 'package:flutter/material.dart';
import '../Objects/task.dart';
import '../services/task_services.dart';

// manages tasks throughout the app
// [CRUD operations for both local and server data]
// coordinates task state between ui and database
class TaskProvider extends ChangeNotifier {
  final List<Task> _tasks = [];

  // provides access to tasks list
  List<Task> get tasks => _tasks;
  
  // loads sample tasks for offline mode or testing
  void loadMockTasks(List<Task> mockTasks) {
    _tasks.clear();
    _tasks.addAll(mockTasks);
    notifyListeners();
  }

  // adds task to local state
  void addTask(Task task) {
    print("=== Adding Task Locally ===");
    print("Task: ${task.title}");
    print("Members: ${task.members}");
    _tasks.add(task);
    notifyListeners();
  }

  // removes task from local state
  void removeTask(Task task) {
    print("=== Removing Task Locally ===");
    print("Task: ${task.title}");
    _tasks.remove(task);
    notifyListeners();
  }

  // updates existing task in local state
  void updateTask(Task updatedTask) {
    print("=== Updating Task Locally ===");
    print("Task: ${updatedTask.title}");
    int index = _tasks.indexWhere((task) => task.title == updatedTask.title);
    if (index != -1) {
      _tasks[index] = updatedTask;
      notifyListeners();
    }
  }

  // finds task by title if it exists
  Task? getTask(String title) {
    try {
      return _tasks.firstWhere((task) => task.title == title);
    } catch (e) {
      return null;
    }
  }

  // updates task when title might have changed
  // [matches by original title instead of current]
  void updateTaskByOriginalTitle(String originalTitle, Task updatedTask) {
    print("=== Updating Task By Original Title ===");
    print("Original title: $originalTitle");
    print("New title: ${updatedTask.title}");
    int index = _tasks.indexWhere((task) => task.title == originalTitle);
    if (index != -1) {
      _tasks[index] = updatedTask;
      notifyListeners();
    }
  }
  
  // fetches all tasks for all user's projects
  // [intended to load everything at once]
  Future<void> fetchTasks(String userId) async {
    print("=== Fetching All Tasks For User ===");
    print("User ID: $userId");
    
    try {
      // needs to loop through user's projects
      // requires projectsProvider to load projects first
      
      print("Need to implement getting project UUIDs for user");
      
      // placeholder for demo - would need project uuids from projects provider
      List<String> projectUuids = [];
      
      print("Projects found: ${projectUuids.length}");
      
      _tasks.clear();
      
      // get tasks for each project user belongs to
      for (String uuid in projectUuids) {
        print("Fetching tasks for project: $uuid");
        List<Task> projectTasks = await TaskServices.getTasks(uuid);
        _tasks.addAll(projectTasks);
      }
      
      print("Total tasks loaded: ${_tasks.length}");
      notifyListeners();
    } catch (e) {
      print('Error fetching tasks: $e');
    }
  }
  
  // gets tasks for specific project only
  // [removes old tasks for this project first to avoid duplicates]
  Future<void> fetchTasksForProject(String projectUuid) async {
    print("=== Fetching Tasks For Project ===");
    print("Project ID: $projectUuid");
    
    try {
      // clear any existing tasks for this project
      _tasks.removeWhere((task) => task.parentProject == projectUuid);
      
      // get fresh tasks from server
      List<Task> projectTasks = await TaskServices.getTasks(projectUuid);
      
      // add to local state
      _tasks.addAll(projectTasks);
      
      print("Tasks fetched: ${projectTasks.length}");
      notifyListeners();
    } catch (e) {
      print('Error fetching tasks for project: $e');
    }
  }
  
  // filters tasks by project for views
  // [doesn't fetch anything, just filters current state]
  List<Task> getTasksForProject(String projectUuid) {
    return _tasks.where((task) => task.parentProject == projectUuid).toList();
  }
  
  // specialized refresh for project screen view
  // [ensures latest task data for kanban board]
  Future<void> refreshTasksForProjectView(String projectUuid) async {
    print("=== Refreshing Tasks For Project View ===");
    print("Project ID: $projectUuid");
    
    try {
      // note from luke about avoiding duplicates
      // would only fetch if tasks aren't already loaded
      // var existingTasks = getTasksForProject(projectUuid);
      // if (existingTasks.isEmpty) {
      //   List<Task> projectTasks = await TaskServices.getTasks(projectUuid);
      //   _tasks.addAll(projectTasks);
      //   print("Tasks loaded for first time: ${projectTasks.length}");
      // }
      
      // safer approach - always clear and reload
      _tasks.removeWhere((task) => task.parentProject == projectUuid);
      
      // get fresh data from server
      List<Task> projectTasks = await TaskServices.getTasks(projectUuid);
      
      // update local state
      _tasks.addAll(projectTasks);
      print("Tasks refreshed: ${projectTasks.length}");
      
      notifyListeners();
    } catch (e) {
      print('Error refreshing tasks for project view: $e');
    }
  }
  
  // updates task status with optimistic ui and backend sync
  // [rollbacks changes if server update fails]
  Future<bool> updateTaskStatus(Task task, Status newStatus) async {
    print("=== Updating Task Status ===");
    print("Task: ${task.title}");
    print("New Status: ${newStatus}");
    
    // save old status in case we need to rollback
    Status oldStatus = task.status;
    
    // update ui immediately for better experience
    task.updateStatus(newStatus);
    updateTask(task);
    
    try {
      // send update to backend
      bool success = await updateTaskOnline(task, task.parentProject!);
      
      if (!success) {
        // revert changes if server update failed
        print("Backend update failed, rolling back status");
        task.updateStatus(oldStatus);
        updateTask(task);
      }
      
      return success;
    } catch (e) {
      print('Error updating task status: $e');
      // revert changes on error
      task.updateStatus(oldStatus);
      updateTask(task);
      return false;
    }
  }
  
  // creates new task on server
  // [adds to local state only if server creation succeeds]
  Future<bool> createTaskOnline(Task task, int projectUid) async {
    print("=== Creating Task Online ===");
    print("Task: ${task.title}");
    print("Project UID: $projectUid");
    
    try {
      bool success = await TaskServices.createTask(task, projectUid);
      
      if (success) {
        // add to local state for immediate ui update
        addTask(task);
      }
      
      return success;
    } catch (e) {
      print('Error creating task: $e');
      return false;
    }
  }
  
  // updates existing task on server
  // [only updates local state if server update succeeds]
  Future<bool> updateTaskOnline(Task task, String projectUuid) async {
    print("=== Updating Task Online ===");
    print("Task: ${task.title}");
    
    try {
      bool success = await TaskServices.updateTask(task, projectUuid);
      
      if (success) {
        // update in local state
        updateTask(task);
      }
      
      return success;
    } catch (e) {
      print('Error updating task: $e');
      return false;
    }
  }
  
  // deletes task on server and locally
  // [removes from local state only if server deletion succeeds]
  Future<bool> deleteTaskOnline(String taskId, String projectId) async {
    print("=== Deleting Task Online ===");
    print("Task ID: $taskId");
    print("Project ID: $projectId");
    
    try {
      bool success = await TaskServices.deleteTask(taskId, projectId);
      
      if (success) {
        // remove from local state by task ID
        _tasks.removeWhere((task) => task.taskId.toString() == taskId);
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      print('Error deleting task: $e');
      return false;
    }
  }
}