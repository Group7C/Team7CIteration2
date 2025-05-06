import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../usser/usserObject.dart';
import 'dart:math';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:5000';
  
  // Get color based on project ID
  static Color _getProjectColor(dynamic projectId) {
    const colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    
    if (projectId == null) return Colors.grey;
    
    try {
      final id = int.parse(projectId.toString());
      return colors[id % colors.length];
    } catch (e) {
      return Colors.grey;
    }
  }
  
  // Fetch user's projects with proper logging
  static Future<List<Map<String, dynamic>>> fetchUserProjects(BuildContext context) async {
    print('\n=== FETCHING USER PROJECTS ===');
    try {
      final usser = context.read<Usser>();
      
      // Ensure we have a user ID
      if (usser.usserID.isEmpty) {
        await usser.getID();
      }
      print('User ID: ${usser.usserID}');
      
      final url = '$baseUrl/get/user/projects?user_id=${usser.usserID}';
      print('API URL: $url');
      
      final response = await http.get(Uri.parse(url));
      print('Status Code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Projects received: ${data.length}');
        
        // Format and log each project
        final formattedProjects = data.map((project) {
          final formattedProject = {
            'id': project['id']?.toString() ?? '',
            'title': project['name'] ?? 'Unnamed Project',
            'name': project['name'] ?? 'Unnamed Project',
            'deadline': project['deadline'] ?? '',
            'members': project['members'] ?? 0,
            'completed_tasks': project['completed_tasks'] ?? 0,
            'total_tasks': project['total_tasks'] ?? 0,
            'description': project['description'] ?? '',
            'percentage': project['completed_tasks'] != null && project['total_tasks'] != null && project['total_tasks'] > 0
                ? ((project['completed_tasks'] / project['total_tasks']) * 100).round()
                : 0,
          };
          
          print('\nProject: ${jsonEncode(formattedProject)}');
          return formattedProject;
        }).toList();
        
        print('\n=== PROJECTS LOADED SUCCESSFULLY ===\n');
        return formattedProjects.cast<Map<String, dynamic>>();
      } else {
        print('Error: ${response.body}');
        throw Exception('Failed to load projects: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching projects: $e');
      print('=== PROJECTS FETCH FAILED ===\n');
      return [];
    }
  }
  
  // New helper function to normalize task status (ADDED FOR FIX)
  static String normalizeTaskStatus(dynamic rawStatus) {
    if (rawStatus == null) return 'todo';
    
    final statusStr = rawStatus.toString().toLowerCase().trim();
    
    // Map various status formats to the three standard statuses
    if (statusStr == 'in progress' || statusStr == 'inprogress' || statusStr == 'in_progress') {
      return 'in_progress';
    } else if (statusStr == 'done' || statusStr == 'complete' || statusStr == 'completed') {
      return 'completed';
    } else if (statusStr == 'to do' || statusStr == 'todo' || statusStr == 'to-do' || statusStr == 'not started') {
      return 'todo';
    }
    
    // Default to todo for any other status
    return 'todo';
  }
  
  // Fetch user's tasks for all their projects
  static Future<List<Map<String, dynamic>>> fetchUserTasks(BuildContext context) async {
    print('\n=== FETCHING USER TASKS ===');
    try {
      final usser = context.read<Usser>();
      
      if (usser.usserID.isEmpty) {
        await usser.getID();
      }
      print('User ID: ${usser.usserID}');
      
      // First, get user's projects
      final projects = await fetchUserProjects(context);
      List<Map<String, dynamic>> allTasks = [];
      
      print('Fetching tasks for ${projects.length} projects...');
      
      // For each project, fetch its tasks using the correct endpoint
      for (var project in projects) {
        final projectId = project['id'];
        print('\nFetching tasks for project ID: $projectId');
        
        // Use the correct endpoint format from your backend
        final url = '$baseUrl/project/$projectId/tasks';
        print('URL: $url');
        
        final response = await http.get(Uri.parse(url));
        print('Status Code: ${response.statusCode}');
        
        if (response.statusCode == 200) {
          final List<dynamic> projectTasks = json.decode(response.body);
          print('Tasks found: ${projectTasks.length}');
          
          // Add tasks to the list with project info and normalized status
          for (var task in projectTasks) {
            // Normalize status (IMPORTANT FIX)
            String normalizedStatus = normalizeTaskStatus(task['status']);
            
            final formattedTask = {
              'id': task['id']?.toString() ?? '',
              'title': task['title'] ?? 'Unnamed Task',
              'task_name': task['title'] ?? 'Unnamed Task',
              'description': task['description'] ?? '',
              'due_date': task['due_date'] ?? '',
              'start_date': task['start_date'] ?? '',
              'status': normalizedStatus,  // Use normalized status
              'priority': task['priority'] ?? 'Medium',
              'project_id': projectId,
              'project_name': project['name'],
              'assignee_id': task['assignee_id'],
              'assignee_username': task['assignee_username'] ?? 'Unassigned',
              'weighting': task['percentage_weighting'],
              'tags': task['tags'],
              'members': task['members'],
              'parent': '',
              'notification_frequency': '',
            };
            
            print('Task: ${jsonEncode(formattedTask)}');
            allTasks.add(formattedTask);
          }
        } else {
          print('Error fetching tasks for project $projectId: ${response.body}');
        }
      }
      
      print('\nTotal tasks fetched: ${allTasks.length}');
      print('=== TASKS LOADED SUCCESSFULLY ===\n');
      return allTasks;
      
    } catch (e) {
      print('Error fetching tasks: $e');
      print('=== TASKS FETCH FAILED ===\n');
      return [];
    }
  }
  
  // Fetch only tasks assigned to the current user
  static Future<List<Map<String, dynamic>>> fetchUserAssignedTasks(BuildContext context) async {
    print('\n=== FETCHING USER ASSIGNED TASKS ===');
    try {
      final usser = context.read<Usser>();
      
      if (usser.usserID.isEmpty) {
        await usser.getID();
      }
      print('User ID: ${usser.usserID}');
      
      // First get all tasks for all projects the user is part of
      final allTasks = await fetchUserTasks(context);
      
      // Filter tasks to only those assigned to the current user
      final userTasks = allTasks.where((task) {
        // Check if assignee_id matches the current user's ID
        if (task['assignee_id'] != null) {
          bool isAssigned = task['assignee_id'].toString() == usser.usserID.toString();
          print('Task: ${task['title']} - Assigned to user? $isAssigned');
          return isAssigned;
        }
        return false;
      }).toList();
      
      print('Total user assigned tasks: ${userTasks.length} (filtered from ${allTasks.length} total)');
      userTasks.forEach((task) {
        print('User Task: ${task['title']} (${task['status']}) - Project: ${task['project_name']}');
      });
      print('=== USER ASSIGNED TASKS LOADED SUCCESSFULLY ===\n');
      return userTasks;
      
    } catch (e) {
      print('Error fetching user assigned tasks: $e');
      print('=== USER ASSIGNED TASKS FETCH FAILED ===\n');
      return [];
    }
  }
  
  // Map task priority to status (since your schema doesn't have status field)
  static String _mapTaskStatus(dynamic priority) {
    if (priority == null) return 'todo';
    
    final priorityStr = priority.toString().toLowerCase();
    if (priorityStr.contains('high')) return 'in_progress';
    if (priorityStr.contains('medium')) return 'todo';
    if (priorityStr.contains('low')) return 'todo';
    
    // Fallback
    return 'todo';
  }
  
  // Fetch user's collaboration groups based on shared task assignments
  static Future<List<Map<String, dynamic>>> fetchUserGroups(BuildContext context) async {
    print('\n=== FETCHING USER GROUPS ===');
    try {
      final usser = context.read<Usser>();
      
      if (usser.usserID.isEmpty) {
        await usser.getID();
      }
      
      final userId = usser.usserID;
      print('User ID: $userId');
      
      // Get all tasks for all projects the user is in
      final allTasks = await fetchUserTasks(context);
      
      // Dictionary to store groups (key: task ID, value: list of members)
      Map<String, Map<String, dynamic>> taskGroups = {};
      
      // Find tasks with shared assignments
      for (var task in allTasks) {
        final taskId = task['id']?.toString() ?? '';
        final taskTitle = task['title']?.toString() ?? 'Unnamed Task';
        final projectName = task['project_name']?.toString() ?? 'Unknown Project';
        final projectId = task['project_id']?.toString() ?? '';
        
        // Parse members from the task
        Map<String, dynamic> members = {};
        if (task['members'] != null) {
          try {
            if (task['members'] is String) {
              members = json.decode(task['members']) as Map<String, dynamic>;
            } else if (task['members'] is Map) {
              members = Map<String, dynamic>.from(task['members']);
            }
          } catch (e) {
            print('Error parsing members for task $taskId: $e');
          }
        }
        
        // Add the assignee to members if not included already
        final assigneeUsername = task['assignee_username']?.toString() ?? '';
        final assigneeId = task['assignee_id']?.toString() ?? '';
        
        if (assigneeUsername.isNotEmpty && assigneeId.isNotEmpty) {
          if (!members.containsKey(assigneeUsername)) {
            members[assigneeUsername] = 'editor';
          }
        }
        
        // Only include tasks with multiple members (at least 2)
        if (members.length >= 2) {
          // Check if the current user is one of the members or the assignee
          bool userIsInvolved = assigneeId == userId || 
                               members.keys.contains(usser.usserName);
          
          if (userIsInvolved) {
            print('Task $taskId has ${members.length} members and user is involved');
            
            // Create a group for this task
            taskGroups[taskId] = {
              'id': taskId,
              'name': 'Collaborators on "$taskTitle"',
              'task_title': taskTitle,
              'member_count': members.length,
              'members': members,
              'project_name': projectName,
              'project_id': projectId,
              'status': 'Active',
            };
          }
        }
      }
      
      // Convert the map to a list of groups
      final groups = taskGroups.values.toList();
      
      // Sort groups by member count (descending)
      groups.sort((a, b) => (b['member_count'] as int).compareTo(a['member_count'] as int));
      
      print('Found ${groups.length} collaboration groups');
      print('=== USER GROUPS LOADED SUCCESSFULLY ===\n');
      return groups;
      
    } catch (e) {
      print('Error creating user groups: $e');
      print('=== USER GROUPS CREATION FAILED ===\n');
      return [];
    }
  }
  
  // Fetch recent activity (placeholder - you'll need to implement the API endpoint)
  static Future<List<Map<String, dynamic>>> fetchRecentActivity(BuildContext context) async {
    print('\n=== FETCHING RECENT ACTIVITY ===');
    print('Note: Activity endpoint not implemented yet');
    print('=== ACTIVITY FETCH SKIPPED ===\n');
    return [];
  }
  
  // Fetch upcoming deadlines based on tasks and projects
  static Future<List<Map<String, dynamic>>> fetchUpcomingDeadlines(BuildContext context) async {
    print('\n=== FETCHING UPCOMING DEADLINES ===');
    try {
      final projects = await fetchUserProjects(context);
      final tasks = await fetchUserTasks(context);
      List<Map<String, dynamic>> deadlines = [];
      
      // Add project deadlines
      for (var project in projects) {
        if (project['deadline'] != null && project['deadline'].isNotEmpty) {
          final deadline = {
            'id': 'project_${project['id']}',
            'title': 'Project Deadline: ${project['name']}',
            'project_name': project['name'],
            'due_date': project['deadline'],
            'type': 'project',
            'project_id': project['id'],
          };
          
          print('Project deadline: ${jsonEncode(deadline)}');
          deadlines.add(deadline);
        }
      }
      
      // Add task deadlines
      for (var task in tasks) {
        if (task['due_date'] != null && task['due_date'].isNotEmpty) {
          final deadline = {
            'id': task['id'],
            'title': task['title'],
            'project_name': task['project_name'],
            'due_date': task['due_date'],
            'type': 'task',
            'project_id': task['project_id'],
          };
          
          print('Task deadline: ${jsonEncode(deadline)}');
          deadlines.add(deadline);
        }
      }
      
      // Sort by due date
      deadlines.sort((a, b) {
        try {
          final dateA = DateTime.parse(a['due_date']);
          final dateB = DateTime.parse(b['due_date']);
          return dateA.compareTo(dateB);
        } catch (e) {
          return 0;
        }
      });
      
      print('\nTotal deadlines found: ${deadlines.length}');
      print('=== DEADLINES LOADED SUCCESSFULLY ===\n');
      return deadlines;
      
    } catch (e) {
      print('Error fetching deadlines: $e');
      print('=== DEADLINES FETCH FAILED ===\n');
      return [];
    }
  }
  
  // Update task status with enhanced error handling and logging
  static Future<bool> updateTaskStatus(String taskId, String newStatus) async {
    print('\n=== UPDATING TASK STATUS ===');
    print('Task ID: $taskId');
    print('New Status: $newStatus');
    
    try {
      // Ensure status is in the expected format for the backend
      String backendStatus = newStatus;
      
      // If needed, convert from frontend status format to backend format
      // This is handled in our normalization function instead
      
      final url = '$baseUrl/task/$taskId/status';
      print('URL: $url');
      
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': backendStatus}),
      );
      
      print('Status Code: ${response.statusCode}');
      print('Response: ${response.body}');
      
      if (response.statusCode == 200) {
        print('=== TASK STATUS UPDATED SUCCESSFULLY ===\n');
        return true;
      } else {
        print('Error: ${response.body}');
        print('=== TASK STATUS UPDATE FAILED ===\n');
        return false;
      }
    } catch (e) {
      print('Error updating task status: $e');
      print('=== TASK STATUS UPDATE FAILED ===\n');
      return false;
    }
  }
  
  // Create a new task
  static Future<Map<String, dynamic>?> createTask(String projectId, Map<String, dynamic> taskData) async {
    print('\n=== CREATING NEW TASK ===');
    print('Project ID: $projectId');
    print('Task Data: ${jsonEncode(taskData)}');
    
    try {
      // Normalize the status if present
      if (taskData.containsKey('status')) {
        taskData['status'] = normalizeTaskStatus(taskData['status']);
      }
      
      final url = '$baseUrl/project/$projectId/tasks';
      print('URL: $url');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(taskData),
      );
      
      print('Status Code: ${response.statusCode}');
      print('Response: ${response.body}');
      
      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        print('=== TASK CREATED SUCCESSFULLY ===\n');
        return responseData;
      } else {
        print('Error: ${response.body}');
        print('=== TASK CREATION FAILED ===\n');
        return null;
      }
    } catch (e) {
      print('Error creating task: $e');
      print('=== TASK CREATION FAILED ===\n');
      return null;
    }
  }
  
  // Get project members
  static Future<List<Map<String, dynamic>>> getProjectMembers(String projectId) async {
    print('\n=== FETCHING PROJECT MEMBERS ===');
    print('Project ID: $projectId');
    
    try {
      final url = '$baseUrl/project/$projectId/members';
      print('URL: $url');
      
      final response = await http.get(Uri.parse(url));
      print('Status Code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Members received: ${data.length}');
        
        final members = data.map((member) => {
          'id': member['id']?.toString() ?? '',
          'username': member['username'] ?? '',
          'email': member['email'] ?? '',
          'profile_picture': member['profile_picture'],
        }).toList();
        
        print('=== PROJECT MEMBERS LOADED SUCCESSFULLY ===\n');
        return members.cast<Map<String, dynamic>>();
      } else {
        print('Error: ${response.body}');
        print('=== PROJECT MEMBERS FETCH FAILED ===\n');
        return [];
      }
    } catch (e) {
      print('Error fetching project members: $e');
      print('=== PROJECT MEMBERS FETCH FAILED ===\n');
      return [];
    }
  }
}