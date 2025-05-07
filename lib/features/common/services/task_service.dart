import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task_model.dart';

class TaskService {
  // Base URL for API calls
  static const String _baseUrl = 'http://localhost:5000';

  // Get all tasks for a specific project
  static Future<List<Task>> getTasksByProject(int projectId) async {
    try {
      // Check for valid project ID
      if (projectId <= 0) {
        print('Invalid project ID: $projectId');
        return [];
      }
      
      print('Fetching tasks for project ID: $projectId');
      final response = await http.get(
        Uri.parse('$_baseUrl/get/project/tasks?project_id=$projectId'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Response status code: ${response.statusCode}');
      if (response.statusCode != 200) {
        throw Exception('Failed to load tasks: ${response.statusCode}');
      }

      print('Response body: ${response.body}');
      // Parse the JSON response
      final dynamic decodedResponse = jsonDecode(response.body);

      // Check if there's an error in the response (which would be a Map)
      if (decodedResponse is Map && decodedResponse.containsKey('error')) {
        print('Error in response: ${decodedResponse['error']}');
        throw Exception(decodedResponse['error']);
      }

      // If no error, response should be a List
      if (decodedResponse is! List) {
        print('Unexpected response format: ${decodedResponse.runtimeType}');
        throw Exception('Unexpected response format');
      }
      
      // Debug the JSON response structures
      if (decodedResponse.isNotEmpty) {
        print('First task JSON structure:');
        print('Keys: ${(decodedResponse[0] as Map).keys.toList()}');
        if ((decodedResponse[0] as Map).containsKey('assigned_members')) {
          print('assigned_members type: ${decodedResponse[0]['assigned_members'].runtimeType}');
          print('assigned_members count: ${decodedResponse[0]['assigned_members'].length}');
          if (decodedResponse[0]['assigned_members'].length > 0) {
            print('First assigned member keys: ${(decodedResponse[0]['assigned_members'][0] as Map).keys.toList()}');
          }
        } else {
          print('No assigned_members field found');
        }
      }

      // Convert to Task objects
      final List<Task> tasks = (decodedResponse as List)
          .map((taskJson) => Task.fromJson(taskJson))
          .toList();
          
      print('Successfully fetched ${tasks.length} tasks');
      return tasks;
    } catch (e) {
      print('Error fetching project tasks: $e');
      throw Exception('Failed to load tasks: $e');
    }
  }

  // Get all tasks assigned to a specific user
  static Future<List<Task>> getTasksByUser(int userId) async {
    try {
      // Check for valid user ID
      if (userId <= 0) {
        print('Invalid user ID: $userId');
        return [];
      }
      
      print('Fetching tasks for user ID: $userId');
      final response = await http.get(
        Uri.parse('$_baseUrl/get/user/tasks?user_id=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Response status code: ${response.statusCode}');
      if (response.statusCode != 200) {
        throw Exception('Failed to load user tasks: ${response.statusCode}');
      }

      print('Response body: ${response.body}');
      // Parse the JSON response
      final dynamic decodedResponse = jsonDecode(response.body);

      // Check if there's an error in the response (which would be a Map)
      if (decodedResponse is Map && decodedResponse.containsKey('error')) {
        print('Error in response: ${decodedResponse['error']}');
        throw Exception(decodedResponse['error']);
      }

      // If no error, response should be a List
      if (decodedResponse is! List) {
        print('Unexpected response format: ${decodedResponse.runtimeType}');
        throw Exception('Unexpected response format');
      }

      // Convert to Task objects
      final List<Task> tasks = (decodedResponse as List)
          .map((taskJson) => Task.fromJson(taskJson))
          .toList();
          
      print('Successfully fetched ${tasks.length} tasks for user');
      return tasks;
    } catch (e) {
      print('Error fetching user tasks: $e');
      throw Exception('Failed to load user tasks: $e');
    }
  }

  // Create a new task
  static Future<int> createTask({
    required int projectId,
    required String taskName,
    String? parent,
    int? weighting,
    String? tags,
    required int priority,
    required DateTime startDate,
    required DateTime endDate,
    String? description,
    String? members,
    required String notificationFrequency,
    String status = 'to_do',
    String? membersIds,
    String? userIds, // NEW: Added parameter for user IDs
  }) async {
    try {
      // Build the URL with query parameters
      String url = '$_baseUrl/create/task?project_id=$projectId&task_name=$taskName&priority=$priority';
      
      // Convert dates to ISO format string (YYYY-MM-DD)
      url += '&start_date=${startDate.toIso8601String().split('T')[0]}';
      url += '&end_date=${endDate.toIso8601String().split('T')[0]}';
      
      // Add notification frequency
      url += '&notification_frequency=$notificationFrequency';
      
      // Add status
      url += '&status=$status';
      
      // Add optional parameters if they exist
      if (parent != null) url += '&parent=$parent';
      if (weighting != null) url += '&weighting=$weighting';
      if (tags != null) url += '&tags=$tags';
      if (description != null) url += '&description=$description';
      if (members != null) url += '&members=$members';
      
      // NEW: Prioritize userIds over membersIds
      if (userIds != null) {
        url += '&user_ids=$userIds';
      } else if (membersIds != null) {
        url += '&members_ids=$membersIds';
      }
      
      // Make the API call
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to create task: ${response.statusCode}');
      }

      final Map<String, dynamic> result = jsonDecode(response.body);
      
      if (result.containsKey('error')) {
        throw Exception(result['error']);
      }

      return result['task_id'];
    } catch (e) {
      print('Error creating task: $e');
      throw Exception('Failed to create task: $e');
    }
  }

  // Update an existing task
  static Future<bool> updateTask({
    required int taskId,
    String? taskName,
    String? parent,
    int? weighting,
    String? tags,
    int? priority,
    DateTime? startDate,
    DateTime? endDate,
    String? description,
    String? members,
    String? notificationFrequency,
    String? status,
    String? membersIds,
    String? removeMembersIds,
  }) async {
    try {
      // Build the URL with query parameters
      String url = '$_baseUrl/update/task?task_id=$taskId';
      
      // Add optional parameters if they exist
      if (taskName != null) url += '&task_name=$taskName';
      if (parent != null) url += '&parent=$parent';
      if (weighting != null) url += '&weighting=$weighting';
      if (tags != null) url += '&tags=$tags';
      if (priority != null) url += '&priority=$priority';
      if (startDate != null) url += '&start_date=${startDate.toIso8601String().split('T')[0]}';
      if (endDate != null) url += '&end_date=${endDate.toIso8601String().split('T')[0]}';
      if (description != null) url += '&description=$description';
      if (members != null) url += '&members=$members';
      if (notificationFrequency != null) url += '&notification_frequency=$notificationFrequency';
      if (status != null) url += '&status=$status';
      if (membersIds != null) url += '&members_ids=$membersIds';
      if (removeMembersIds != null) url += '&remove_members_ids=$removeMembersIds';
      
      // Make the API call
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update task: ${response.statusCode}');
      }

      final Map<String, dynamic> result = jsonDecode(response.body);
      
      if (result.containsKey('error')) {
        throw Exception(result['error']);
      }

      return result['success'] ?? false;
    } catch (e) {
      print('Error updating task: $e');
      throw Exception('Failed to update task: $e');
    }
  }

  // Specialized method for updating just the task status
  // Uses the dedicated endpoint for status updates
  static Future<Map<String, dynamic>> updateTaskStatus(int taskId, String status) async {
    try {
      // Validate parameters
      if (taskId <= 0) {
        print('Invalid task ID for status update: $taskId');
        return {'success': false, 'error': 'Invalid task ID'};
      }
      
      // Validate status
      if (!['to_do', 'in_progress', 'complete'].contains(status)) {
        print('Invalid status: $status. Must be one of: to_do, in_progress, complete');
        return {'success': false, 'error': 'Invalid status. Must be one of: to_do, in_progress, complete'};
      }
      
      print('Updating task $taskId status to $status');
      final response = await http.get(
        Uri.parse('$_baseUrl/update/task/status?task_id=$taskId&status=$status'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Status update response code: ${response.statusCode}');
      if (response.statusCode != 200) {
        print('Failed to update task status: ${response.statusCode}');
        return {'success': false, 'error': 'HTTP error ${response.statusCode}'};
      }

      print('Status update response body: ${response.body}');
      final Map<String, dynamic> result = jsonDecode(response.body);
      
      if (result.containsKey('error')) {
        print('Error in status update response: ${result['error']}');
        return {'success': false, 'error': result['error']};
      }

      print('Status update successful');
      return result; // Returns the full response with task details
    } catch (e) {
      print('Error updating task status: $e');
      return {'success': false, 'error': e.toString()};
    }
  }
  
  // Get available task statuses
  static List<String> getAvailableTaskStatuses() {
    return ['to_do', 'in_progress', 'complete'];
  }
  
  // Get all group tasks for a specific user (tasks with multiple members)
  static Future<List<Task>> getGroupTasksByUser(int userId) async {
    try {
      // Check for valid user ID
      if (userId <= 0) {
        print('Invalid user ID: $userId');
        return [];
      }
      
      print('Fetching group tasks for user ID: $userId');
      final response = await http.get(
        Uri.parse('$_baseUrl/get/group/tasks?user_id=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Group tasks response status code: ${response.statusCode}');
      if (response.statusCode != 200) {
        throw Exception('Failed to load group tasks: ${response.statusCode}');
      }

      print('Group tasks response body: ${response.body}');
      // Parse the JSON response
      final dynamic decodedResponse = jsonDecode(response.body);

      // Check if there's an error in the response (which would be a Map)
      if (decodedResponse is Map && decodedResponse.containsKey('error')) {
        print('Error in response: ${decodedResponse['error']}');
        throw Exception(decodedResponse['error']);
      }

      // If no error, response should be a List
      if (decodedResponse is! List) {
        print('Unexpected response format: ${decodedResponse.runtimeType}');
        throw Exception('Unexpected response format');
      }

      // Convert to Task objects
      final List<Task> tasks = (decodedResponse as List)
          .map((taskJson) => Task.fromJson(taskJson))
          .toList();
          
      print('Successfully fetched ${tasks.length} group tasks for user');
      return tasks;
    } catch (e) {
      print('Error fetching group tasks: $e');
      throw Exception('Failed to load group tasks: $e');
    }
  }

  // Delete a task
  static Future<bool> deleteTask(int taskId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/delete/task?task_id=$taskId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete task: ${response.statusCode}');
      }

      final Map<String, dynamic> result = jsonDecode(response.body);
      
      if (result.containsKey('error')) {
        throw Exception(result['error']);
      }

      return result['success'] ?? false;
    } catch (e) {
      print('Error deleting task: $e');
      throw Exception('Failed to delete task: $e');
    }
  }
}
