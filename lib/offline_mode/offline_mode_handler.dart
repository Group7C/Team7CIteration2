import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/projects_provider.dart';
import '../providers/tasks_provider.dart';
import '../Objects/task.dart';
import '../projects/project_model.dart';

// Handles loading of mock data for testing
class OfflineModeHandler {
  
  // Load mock project data from JSON
  static Future<List<Project>> loadMockProjects() async {
    String jsonString = await rootBundle.loadString('lib/offline_mode/mock_data/mock_projects.json');
    List<dynamic> jsonData = json.decode(jsonString)['projects'];
    
    List<Project> projects = [];
    for (var item in jsonData) {
      // Convert JSON to Project object using the correct model
      Project project = Project(
        projectName: item['projectName'],
        joinCode: item['joinCode'],
        deadline: DateTime.parse(item['deadline']),
        notificationFrequency: item['notificationFrequency'] == 'daily' ? 
                              NotificationFrequency.daily : NotificationFrequency.weekly,
        uuid: item['uuid'],
      );
      
      // Add members if they exist
      if (item['members'] != null) {
        for (var member in item['members']) {
          project.addMember(member);
        }
      }
      
      projects.add(project);
    }
    
    return projects;
  }
  
  // Load mock task data from JSON
  static Future<List<Task>> loadMockTasks() async {
    String jsonString = await rootBundle.loadString('lib/offline_mode/mock_data/mock_tasks.json');
    List<dynamic> jsonData = json.decode(jsonString)['tasks'];
    
    List<Task> tasks = [];
    for (var item in jsonData) {
      // Set status based on string value
      Status taskStatus;
      switch(item['status']) {
        case 'inProgress':
          taskStatus = Status.inProgress;
          break;
        case 'completed':
          taskStatus = Status.completed;
          break;
        default:
          taskStatus = Status.todo;
      }
      
      // Set notification frequency
      NotificationFrequency notificationFreq;
      switch(item['notificationFrequency']) {
        case 'weekly':
          notificationFreq = NotificationFrequency.weekly;
          break;
        case 'monthly':
          notificationFreq = NotificationFrequency.monthly;
          break;
        case 'none':
          notificationFreq = NotificationFrequency.none;
          break;
        default:
          notificationFreq = NotificationFrequency.daily;
      }

      // Create Task object with all required fields
      Task task = Task(
        title: item['title'],
        description: item['description'],
        status: taskStatus,
        priority: item['priority'],
        percentageWeighting: item['percentageWeighting'],
        listOfTags: List<String>.from(item['listOfTags']),
        startDate: DateTime.parse(item['startDate']),
        endDate: DateTime.parse(item['endDate']),
        parentProject: item['parentProject'],
        members: Map<String, String>.from(item['members']),
        notificationPreference: item['notificationPreference'],
        notificationFrequency: notificationFreq,
        directoryPath: 'offline/tasks/${item['title']}', // Provide a default directory path
      );
      
      tasks.add(task);
    }
    
    return tasks;
  }
  
  // Load mock data into providers
  static Future<bool> loadMockData(BuildContext context) async {
    // Load and set projects
    List<Project> projects = await loadMockProjects();
    Provider.of<ProjectsProvider>(context, listen: false).loadMockProjects(projects);
    
    // Load and set tasks (assuming we've updated TaskProvider similarly)
    List<Task> tasks = await loadMockTasks();
    Provider.of<TaskProvider>(context, listen: false).loadMockTasks(tasks);
    
    return true;
  }
}