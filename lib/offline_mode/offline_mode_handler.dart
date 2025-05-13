import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/projects_provider.dart';
import '../providers/tasks_provider.dart';
import '../Objects/task.dart';
import '../projects/project_model.dart';
import '../providers/user_provider.dart';
import '../usser/usserObject.dart';

// offline mode handler for app functionality without internet
// [loads local mock data to simulate backend connectivity]
class OfflineModeHandler {
  
  // reads mock project data from json assets
  // [converts to proper app models with all required fields]
  static Future<List<Project>> loadMockProjects() async {
    // read json file from assets bundle
    String jsonString = await rootBundle.loadString('lib/offline_mode/mock_data/mock_projects.json');
    List<dynamic> jsonData = json.decode(jsonString)['projects'];
    
    List<Project> projects = [];
    for (var item in jsonData) {
      // convert each json project to proper Project object 
      // [carefully handles dates and enums]
      Project project = Project(
        projectName: item['projectName'],
        joinCode: item['joinCode'],
        deadline: DateTime.parse(item['deadline']),
        notificationFrequency: item['notificationFrequency'] == 'daily' ? 
                              NotificationFrequency.daily : NotificationFrequency.weekly,
        uuid: item['uuid'],
        projectUid: item['projectUid'] ?? projects.length + 1,  // fallback to generated id if missing
      );
      
      // populate project with members if available
      if (item['members'] != null) {
        for (var member in item['members']) {
          project.addMember(member, 'Editor'); // default role for testing
        }
      }
      
      projects.add(project);
    }
    
    return projects;
  }
  
  // reads mock task data from json assets
  // [matches structure expected from backend api]
  static Future<List<Task>> loadMockTasks() async {
    // read json file from assets bundle
    String jsonString = await rootBundle.loadString('lib/offline_mode/mock_data/mock_tasks.json');
    List<dynamic> jsonData = json.decode(jsonString)['tasks'];
    
    List<Task> tasks = [];
    for (var item in jsonData) {
      // convert string status to app enum
      // [todo, inProgress, completed]
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


      
      // convert string notification frequency to app enum
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

      // create complete task object with mock data
      // [ensures all required properties are included]
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
        directoryPath: 'offline/tasks/${item['title']}', // offline-specific path
      );
      
      tasks.add(task);
    }
    
    return tasks;
  }



  static Future<List<Usser>> loadMockUsers() async {
    String jsonString = await rootBundle.loadString('lib/offline_mode/mock_data/users.json');
    Map<String, dynamic> jsonData = json.decode(jsonString);

    List<Usser> users = [];

    jsonData.forEach((key, userJson) {
      users.add(Usser.fromJson(userJson));
    });

    return users;
  }


  // Load mock data into providers
  static Future<bool> loadMockData(BuildContext context) async {
    // Load and set projects


    List<Project> projects = await loadMockProjects();
    Provider.of<ProjectsProvider>(context, listen: false).loadMockProjects(projects);
    
    // then load tasks that reference those projects
    List<Task> tasks = await loadMockTasks();
    Provider.of<TaskProvider>(context, listen: false).loadMockTasks(tasks);

    print("loading users");

    List<Usser> users = await loadMockUsers();
    Usser mockUser = users.last;
    Provider.of<Usser>(context, listen: false)
      ..usserName = mockUser.usserName
      ..email = mockUser.email
      ..usserPassword = mockUser.usserPassword
      ..theme = mockUser.theme
      ..profilePic = mockUser.profilePic
      ..currancyTotal = mockUser.currancyTotal
      ..settings = mockUser.settings
      ..tasks = mockUser.tasks;
    
    // all mock data loaded successfully
    return true;
  }






}