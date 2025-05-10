import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../lib/providers/connectivity_provider.dart';
import '../../lib/providers/projects_provider.dart';
import '../../lib/providers/tasks_provider.dart';
import '../../lib/Objects/task.dart';
import '../../lib/join/project.dart';

// Handles loading of mock data for offline mode [Helps isolate test data from main code]
class OfflineModeHandler {
  
  // Load mock project data from JSON
  static Future<List<Project>> loadMockProjects() async {
    String jsonString = await rootBundle.loadString('test/offlineMode/mock_data/mock_projects.json');
    List<dynamic> jsonData = json.decode(jsonString)['projects'];
    
    List<Project> projects = [];
    for (var item in jsonData) {
      // Convert JSON to Project object
      Project project = Project(
        item['projectName'],
        item['joinCode'],
        DateTime.parse(item['deadline']),
      );
      
      // Set additional properties
      project.uuid = item['uuid'];
      
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
    String jsonString = await rootBundle.loadString('test/offlineMode/mock_data/mock_tasks.json');
    List<dynamic> jsonData = json.decode(jsonString)['tasks'];
    
    List<Task> tasks = [];
    for (var item in jsonData) {
      // Create Task object
      Task task = Task(
        title: item['title'],
        description: item['description'],
        status: item['status'],
        priority: item['priority'],
        percentageWeighting: item['percentageWeighting'],
        listOfTags: List<String>.from(item['listOfTags']),
        startDate: DateTime.parse(item['startDate']),
        endDate: DateTime.parse(item['endDate']),
        parentProject: item['parentProject'],
        members: Map<String, String>.from(item['members']),
        notificationPreference: item['notificationPreference'],
        notificationFrequency: NotificationFrequency.daily, // Default value
      );
      
      // Set task frequency based on JSON
      if (item['notificationFrequency'] == 'weekly') {
        task.notificationFrequency = NotificationFrequency.weekly;
      } else if (item['notificationFrequency'] == 'monthly') {
        task.notificationFrequency = NotificationFrequency.monthly;
      } else if (item['notificationFrequency'] == 'none') {
        task.notificationFrequency = NotificationFrequency.none;
      }
      
      tasks.add(task);
    }
    
    return tasks;
  }
  
  // Setup offline mode data in providers
  static Future<bool> setupOfflineMode(BuildContext context) async {
    // Set offline mode flag
    Provider.of<ConnectivityProvider>(context, listen: false).setOfflineMode(true);
    
    // Load and set projects
    List<Project> projects = await loadMockProjects();
    Provider.of<ProjectsProvider>(context, listen: false).setOfflineProjects(projects);
    
    // Load and set tasks
    List<Task> tasks = await loadMockTasks();
    Provider.of<TaskProvider>(context, listen: false).setOfflineTasks(tasks);
    
    return true;
  }
}