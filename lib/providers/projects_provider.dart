import 'package:flutter/material.dart';
import '../projects/project_model.dart';
import '../services/project_services.dart';
import '../Objects/task.dart'; // For NotificationFrequency

// manages all project data throughout app
// handles state management between ui and database
// [provides central access to project operations]
class ProjectsProvider extends ChangeNotifier {
  final List<Project> _projects = [];

  // exposes projects list to rest of app
  List<Project> get projects => _projects;
  
  // loads sample data for testing or offline mode
  void loadMockProjects(List<Project> mockProjects) {
    _projects.clear();
    _projects.addAll(mockProjects);
    notifyListeners();
  }

  // adds project to local state
  void addProject(Project project) {
    print("Adding project to provider: ${project.projectName}");
    _projects.add(project);
    print("Project added to provider: ${project.projectName}");
    notifyListeners();
  }

  // removes project from local state
  void removeProject(Project project) {
    _projects.remove(project);
    notifyListeners();
  }

  // finds project by name if exists
  Project? getProject(String name) {
    try {
      return _projects.firstWhere((project) => project.projectName == name);
    } catch (e) {
      return null;
    }
  }
  
  // creates new project on backend and updates local state
  // [formats data to match api expectations, missing this caused SOME issues to say the least!]
  Future<bool> createProjectOnline(Project project, String userId) async {
    try {
      // format date for backend yyyy-mm-dd format
      String formattedDate = "${project.deadline.year}-${project.deadline.month.toString().padLeft(2, '0')}-${project.deadline.day.toString().padLeft(2, '0')}";
      
      // convert enum to string for backend
      String notificationPref;
      switch(project.notificationFrequency) {
        case NotificationFrequency.daily:
          notificationPref = 'Daily';
          break;
        case NotificationFrequency.monthly:
          notificationPref = 'Monthly';
          break;
        case NotificationFrequency.none:
          notificationPref = 'None';
          break;
        default:
          notificationPref = 'Weekly';
      }
      
      // call service to create on server
      bool success = await ProjectServices.createProject(
        project.projectName,
        project.joinCode,
        formattedDate,
        project.uuid,
        userId,
        project.googleDriveLink,
        project.discordLink,
        notificationPref,
      );
      
      if (success) {
        // refresh projects to include newly created one
        await fetchProjects(userId);
      }
      
      return success;
    } catch (e) {
      print('Error in createProjectOnline: $e');
      return false;
    }
  }
  
  // gets all projects user is part of from backend
  // [replaces local list with fresh data]
  Future<void> fetchProjects(String userId) async {
    try {
      List<Project> userProjects = await ProjectServices.getProjectsWithMembers(userId);
      _projects.clear();
      _projects.addAll(userProjects);
      notifyListeners();
    } catch (e) {
      print('Error fetching projects: $e');
    }
  }
  
  // adds user to existing project using join code
  // [returns status message to display to user]
  Future<Map<String, dynamic>> joinProjectWithCode(String joinCode, String userId) async {
    try {
      // attempt to join on server
      final result = await ProjectServices.joinProject(joinCode, userId);
      
      if (result['status'] == 'success') {
        // refresh projects to include newly joined one
        await fetchProjects(userId);
      }
      
      return result;
    } catch (e) {
      print('Error joining project: $e');
      return {'status': 'error', 'message': 'Error joining project: $e'};
    }
  }
}