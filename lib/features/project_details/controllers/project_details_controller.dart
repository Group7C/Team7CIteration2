import '../models/project_details_view_model.dart';
import '../../../../features/common/services/project_service.dart';
import '../../../../features/common/services/task_service.dart';
import '../../../../features/common/models/project_model.dart';

class ProjectDetailsController {
  final ProjectDetailsViewModel viewModel;
  
  ProjectDetailsController(this.viewModel);
  
  /// Load project details from the service
  Future<void> loadProjectDetails(int projectId) async {
    try {
      viewModel.setLoading(true);
      
      // Load project data
      final projectData = await ProjectService.getProjectById(projectId);
      viewModel.setProject(projectData);
      
      // Load project tasks
      final projectTasks = await TaskService.getTasksByProject(projectId);
      viewModel.setTasks(projectTasks);
      
    } catch (e) {
      print('Error loading project details: $e');
      viewModel.setError('Failed to load project details: $e');
    }
  }
  
  /// Load project details from the service without triggering UI updates
  /// Used for background refreshes
  Future<void> loadProjectDetailsQuietly(int projectId) async {
    try {
      // Don't set loading since we don't want UI changes
      
      // Load project data
      final projectData = await ProjectService.getProjectById(projectId);
      
      // Update the view model's project without notification
      viewModel.setProjectWithoutNotify(projectData);
      
      // Load project tasks
      final projectTasks = await TaskService.getTasksByProject(projectId);
      
      // Update the view model's tasks without notification
      viewModel.setTasksWithoutNotify(projectTasks);
      
    } catch (e) {
      print('Error quietly loading project details: $e');
      // Don't set error since we don't want UI changes
    }
  }
  
  /// Helper method for clipboard operations
  void copyToClipboard(String text) {
    // This would contain the clipboard functionality
    // Moved from the UI to the controller
  }
}