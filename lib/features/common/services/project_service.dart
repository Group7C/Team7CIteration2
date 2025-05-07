import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/project_model.dart';
import '../models/deadline_model.dart';

class ProjectService {
  // Base URL for your API calls
  static const String _baseUrl = 'http://localhost:5000';
  
  // Method to get all projects for a specific user
  static Future<List<Project>> getUserProjects(int userId) async {
    // Make API call to get projects for the user using the correct route from your Flask app
    final response = await http.get(
      Uri.parse('$_baseUrl/get/user/projects?user_id=$userId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print('Response body: ${response.body}');
      
      // Parse the response - now the endpoint returns complete project objects
      final List<dynamic> projectsJson = jsonDecode(response.body);
      
      // Create Project objects from the JSON
      final List<Project> projects = projectsJson.map((projectJson) => Project(
        projectUid: projectJson['project_uid'],
        joinCode: projectJson['join_code'],
        projName: projectJson['proj_name'],
        deadline: DateTime.parse(projectJson['deadline']),
        notificationPreference: projectJson['notification_preference'],
        googleDriveLink: projectJson['google_drive_link'],
        discordLink: projectJson['discord_link'],
        uuid: projectJson['uuid'],
        members: [], // We don't have members at this level
      )).toList();
      
      return projects;
    } else {
      throw Exception('Failed to load projects: ${response.statusCode}');
    }
  }
  
  // Get project by ID (full details)
  static Future<Project> getProjectById(int projectId) async {
    try {
      // Use our new endpoint to get full project details
      final response = await http.get(
        Uri.parse('$_baseUrl/get/project/details?project_id=$projectId'),
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to load project details: ${response.statusCode}');
      }
      
      // Parse the JSON response
      final Map<String, dynamic> projectJson = jsonDecode(response.body);
      
      // Check if there's an error in the response
      if (projectJson.containsKey('error')) {
        throw Exception(projectJson['error']);
      }
      
      // Extract project details
      final List<ProjectMember> members = [];
      
      // Convert member data to ProjectMember objects
      if (projectJson.containsKey('members')) {
        final List<dynamic> membersList = projectJson['members'];
        for (var memberData in membersList) {
          members.add(
            ProjectMember(
              membersId: memberData['members_id'],
              projectUid: projectJson['project_uid'],
              userId: memberData['user_id'],
              isOwner: memberData['is_owner'],
              memberRole: memberData['member_role'],
              joinDate: DateTime.parse(memberData['join_date']),
              username: memberData['username'],
            ),
          );
        }
      }
      
      // Create and return the full Project object
      return Project(
        projectUid: projectJson['project_uid'],
        joinCode: projectJson['join_code'],
        projName: projectJson['proj_name'],
        deadline: DateTime.parse(projectJson['deadline']),
        notificationPreference: projectJson['notification_preference'],
        googleDriveLink: projectJson['google_drive_link'],
        discordLink: projectJson['discord_link'],
        uuid: projectJson['uuid'],
        members: members,
      );
    } catch (e) {
      print('Error fetching project details: $e');
      throw Exception('Failed to load project: $e');
    }
  }

  // Get deadlines from user's projects
  static Future<List<Deadline>> getUserDeadlines(int userId) async {
    // First get all projects for the user
    final projects = await getUserProjects(userId);
    
    // Extract deadlines from projects
    final List<Deadline> deadlines = [];
    
    for (var project in projects) {
      deadlines.add(
        Deadline(
          projectUid: project.projectUid,
          projectName: project.projName,
          date: project.deadline,
          description: 'Project deadline',
        ),
      );
    }
    
    // Sort deadlines by date (closest first)
    deadlines.sort((a, b) => a.date.compareTo(b.date));
    
    return deadlines;
  }
  
  // Update a project's details
  static Future<bool> updateProject({
    required int projectId,
    String? projName,
    DateTime? deadline,
    String? notificationPreference,
    String? googleDriveLink,
    String? discordLink,
    String? joinCode,
  }) async {
    try {
      // Build the URL with query parameters
      String url = '$_baseUrl/update/project?project_id=$projectId';
      
      // Add optional parameters if they exist
      if (projName != null) url += '&proj_name=$projName';
      if (deadline != null) url += '&deadline=${deadline.toIso8601String().split('T')[0]}';
      if (notificationPreference != null) url += '&notification_preference=$notificationPreference';
      if (googleDriveLink != null) url += '&google_drive_link=$googleDriveLink';
      if (discordLink != null) url += '&discord_link=$discordLink';
      if (joinCode != null) url += '&join_code=$joinCode';
      
      // Make the API call
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update project: ${response.statusCode}');
      }

      final Map<String, dynamic> result = jsonDecode(response.body);
      
      if (result.containsKey('error')) {
        throw Exception(result['error']);
      }

      return result['success'] ?? false;
    } catch (e) {
      print('Error updating project: $e');
      throw Exception('Failed to update project: $e');
    }
  }
  
  // Delete a project and all related data
  static Future<bool> deleteProject(int projectId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/delete/project?project_id=$projectId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete project: ${response.statusCode}');
      }

      final Map<String, dynamic> result = jsonDecode(response.body);
      
      if (result.containsKey('error')) {
        throw Exception(result['error']);
      }

      return result['success'] ?? false;
    } catch (e) {
      print('Error deleting project: $e');
      throw Exception('Failed to delete project: $e');
    }
  }
  
  // Convenience method to update just the project links
  static Future<bool> updateProjectLinks(int projectId, String googleDriveLink, String discordLink) async {
    return updateProject(
      projectId: projectId,
      googleDriveLink: googleDriveLink,
      discordLink: discordLink,
    );
  }
  
  // Convenience method to update just the project name or deadline
  static Future<bool> updateProjectBasics(int projectId, String projName, DateTime deadline) async {
    return updateProject(
      projectId: projectId,
      projName: projName,
      deadline: deadline,
    );
  }

  // Create a new project
  static Future<int> createProject({
    required String projName,
    required DateTime deadline,
    required int userId,
  }) async {
    try {
      // Generate a unique UUID for the project
      final uuid = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Generate a random join code (6 characters)
      final joinCode = (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString();
      
      // Format the date for the API
      final formattedDate = deadline.toIso8601String().split('T')[0];
      
      // Build the URL with query parameters
      final url = '$_baseUrl/upload/project?name=$projName&join=$joinCode&due=$formattedDate&uuid=$uuid&user_id=$userId';
      
      // Make the API call
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to create project: ${response.statusCode}');
      }
      
      // Get the project ID from the backend (need to query for it since the API doesn't return it directly)
      final getProjectIdUrl = '$_baseUrl/get/project/id?uuid=$uuid';
      final idResponse = await http.get(
        Uri.parse(getProjectIdUrl),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (idResponse.statusCode != 200) {
        throw Exception('Failed to get project ID: ${idResponse.statusCode}');
      }
      
      // The response should be the project ID as a string
      final projectId = int.tryParse(idResponse.body);
      
      if (projectId == null) {
        throw Exception('Invalid project ID returned from server');
      }
      
      return projectId;
    } catch (e) {
      print('Error creating project: $e');
      throw Exception('Failed to create project: $e');
    }
  }
}
