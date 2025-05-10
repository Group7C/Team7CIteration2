import 'package:flutter/material.dart';
import '../projects/project_model.dart';
import '../services/project_services.dart';

class ProjectsProvider extends ChangeNotifier {
  final List<Project> _projects = [];

  // Simple getter for projects
  List<Project> get projects => _projects;
  
  // Load mock data (can be called from login screen when needed)
  void loadMockProjects(List<Project> mockProjects) {
    _projects.clear();
    _projects.addAll(mockProjects);
    notifyListeners();
  }

  void addProject(Project project) {
    print("Adding project to provider: ${project.projectName}");
    _projects.add(project);
    print("Project added to provider: ${project.projectName}");
    notifyListeners();
  }

  void removeProject(Project project) {
    _projects.remove(project);
    notifyListeners();
  }

  Project? getProject(String name) {
    try {
      return _projects.firstWhere((project) => project.projectName == name);
    } catch (e) {
      return null;
    }
  }
  
  // Create project in the database
  Future<bool> createProjectOnline(Project project, String userId) async {
    try {
      // Format date to match backend expectations (YYYY-MM-DD)
      String formattedDate = "${project.deadline.year}-${project.deadline.month.toString().padLeft(2, '0')}-${project.deadline.day.toString().padLeft(2, '0')}";
      
      bool success = await ProjectServices.createProject(
        project.projectName,
        project.joinCode,
        formattedDate,
        project.uuid,
        userId
      );
      
      if (success) {
        // Also add to local state for immediate UI update
        _projects.add(project);
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      print('Error in createProjectOnline: $e');
      return false;
    }
  }
  
  // Fetch user's projects from the backend
  Future<void> fetchProjects(String userId) async {
    try {
      List<Project> userProjects = await ProjectServices.getProjects(userId);
      _projects.clear();
      _projects.addAll(userProjects);
      notifyListeners();
    } catch (e) {
      print('Error fetching projects: $e');
    }
  }
}