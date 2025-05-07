import 'package:flutter/material.dart';
import '../../../../features/common/models/project_model.dart';
import '../../../../features/common/services/task_service.dart';
import '../../../../features/common/models/task_model.dart';
import '../utils/progress_calculator.dart';

class ProjectDetailsViewModel extends ChangeNotifier {
  bool isLoading = true;
  Project? project;
  String? errorMessage;
  
  List<Task> _projectTasks = [];
  
  // Expose project tasks for external access
  List<Task> get projectTasks => _projectTasks;
  
  // Task calculations
  int get completedTasks => _projectTasks.where((task) => task.status == 'complete').length;
  int get totalTasks => _projectTasks.length;
  double get progress => ProgressCalculator.calculateProgress(completedTasks, totalTasks);
  
  // Computed properties
  bool get hasError => errorMessage != null;
  bool get hasProject => project != null;
  String get projectName => project?.projName ?? 'Project Details';
  DateTime? get deadline => project?.deadline;
  String? get googleDriveLink => project?.googleDriveLink;
  String? get discordLink => project?.discordLink;
  String? get joinCode => project?.joinCode;
  List<dynamic> get members => project?.members ?? [];
  
  void setLoading(bool loading) {
    isLoading = loading;
    notifyListeners();
  }
  
  void setProject(Project projectData) {
    project = projectData;
    isLoading = false;
    errorMessage = null;
    notifyListeners();
  }
  
  void setProjectWithoutNotify(Project projectData) {
    project = projectData;
    isLoading = false;
    errorMessage = null;
    // No notifyListeners() call
  }
  
  void setTasks(List<Task> tasks) {
    _projectTasks = tasks;
    notifyListeners();
  }
  
  void setTasksWithoutNotify(List<Task> tasks) {
    _projectTasks = tasks;
    // No notifyListeners() call
  }
  
  // Updates progress calculations without modifying task lists
  // This avoids duplication with Kanban's own task management
  void updateProgressStats(int taskId, String newStatus) {
    // Find the task in our list but don't modify the actual list
    // This is just for progress calculation
    final index = _projectTasks.indexWhere((task) => task.taskId == taskId);
    if (index >= 0) {
      // Only update our internal completion count tracking
      if (newStatus == 'complete' && _projectTasks[index].status != 'complete') {
        // Task was moved TO complete - increment our internal counter
        notifyListeners(); // Just trigger UI update without modifying lists
      } else if (newStatus != 'complete' && _projectTasks[index].status == 'complete') {
        // Task was moved FROM complete - decrement our internal counter
        notifyListeners(); // Just trigger UI update without modifying lists
      }
    }
  }
  
  // Forces refresh of just the progress indicator
  void refreshProgressOnly() {
    notifyListeners(); // This will cause the progress getters to be recalculated
  }
  
  void setError(String error) {
    errorMessage = error;
    isLoading = false;
    notifyListeners();
  }
  
  void addTask(Task task) {
    _projectTasks.add(task);
    notifyListeners();
  }
  
  void removeTask(int taskId) {
    _projectTasks.removeWhere((task) => task.taskId == taskId);
    notifyListeners();
  }
}