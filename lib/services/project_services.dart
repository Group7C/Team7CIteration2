import 'package:http/http.dart' as http;
import 'dart:convert';
import '../projects/project_model.dart';
import '../Objects/task.dart';

class ProjectServices {
  // API URL
  static const String baseUrl = 'http://127.0.0.1:5000';

  // Create a new project in the database
  static Future<bool> createProject(String name, String joinCode, String dueDate, 
      String uuid, String userId) async {
    try {
      // Using GET method to match your Flask API implementation
      final response = await http.get(
        Uri.parse('$baseUrl/upload/project?name=$name&join=$joinCode&due=$dueDate&uuid=$uuid&user_id=$userId'),
      );
      
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print('Error creating project: $e');
      return false;
    }
  }
  
  // Get projects for user from db
  static Future<List<Project>> getProjects(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get/projects?user_id=$userId'),
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<Project> projects = [];
        
        for (var item in data) {
          projects.add(Project(
            projectName: item['name'],
            joinCode: item['joinCode'],
            deadline: DateTime.parse(item['deadline']),
            notificationFrequency: NotificationFrequency.weekly, // default value
            uuid: item['uuid'],
          ));
        }
        
        return projects;
      }
      return [];
    } catch (e) {
      print('Error getting projects: $e');
      return [];
    }
  }
}