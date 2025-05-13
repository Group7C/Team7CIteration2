import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Objects/task.dart';
import 'user_services.dart';

// helper for formatting strings
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}

// handles api requests for task operations
// [connects ui with backend database for task management]
class TaskServices {
  // api endpoint [local dev server]
  static const String baseUrl = 'http://127.0.0.1:5000';

  // creates new task on server
  // [handles complex conversion between app and db formats]
  static Future<bool> createTask(Task task, int projectUid) async {
    try {
      print('=== Creating Task ===');
      print('Task: ${task.title}');
      print('Project UID: $projectUid');
      
      // convert dates to yyyy-mm-dd format
      String startDate = "${task.startDate.year}-${task.startDate.month.toString().padLeft(2, '0')}-${task.startDate.day.toString().padLeft(2, '0')}";
      String endDate = "${task.endDate.year}-${task.endDate.month.toString().padLeft(2, '0')}-${task.endDate.day.toString().padLeft(2, '0')}";
      
      // convert notification frequency to match db format
      String notificationFreq = task.notificationFrequency.name.capitalize();
      if (notificationFreq == 'None') notificationFreq = 'Never';
      
      // convert status to match db format
      String statusString;
      switch (task.status) {
        case Status.todo:
          statusString = 'to_do';
          break;
        case Status.inProgress:
          statusString = 'in_progress';
          break;
        case Status.completed:
          statusString = 'complete';
          break;
        default:
          statusString = 'to_do';
      }
      
      // convert members map to array for db
      List<Map<String, dynamic>> membersArray = [];
      
      // get numeric user ids from usernames
      List<String> usernames = task.members.keys.toList();
      Map<String, int> userIds = await UserServices.getUserIdsFromUsernames(usernames);
      
      task.members.forEach((username, role) {
        if (userIds.containsKey(username)) {
          membersArray.add({
            'user_id': userIds[username],
            'role': role,
          });
        } else {
          print('Warning: Could not find user ID for username: $username');
        }
      });
      
      // backend only supports one tag currently
      String? singleTag = task.listOfTags.isNotEmpty ? task.listOfTags.first : null;
      
      // build complete request body
      Map<String, dynamic> requestBody = {
        'project_uid': projectUid,
        'task_name': task.title,
        'priority': task.priority,
        'weighting': task.percentageWeighting.toInt(),
        'tags': singleTag,
        'start_date': startDate,
        'end_date': endDate,
        'description': task.description,
        'members': membersArray,
        'notification_frequency': notificationFreq,
        'status': statusString,
      };
      
      print('Request body: ${json.encode(requestBody)}');
      
      // post to api
      final response = await http.post(
        Uri.parse('$baseUrl/create/task'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          return true;
        }
      }
      
      return false;
    } catch (e) {
      print('Error creating task: $e');
      return false;
    }
  }

  // fetches tasks for specific project
  // [converts api response to task objects]
  static Future<List<Task>> getTasks(String projectUuid) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get/tasks?project_id=$projectUuid'),
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        
        List<Task> tasks = [];
        for (var item in data) {
          // map status values between api and app
          Status status;
          switch(item['status'] ?? 'To Do') {
            case 'In Progress':
              status = Status.inProgress;
              break;
            case 'Completed':
            case 'Complete':
              status = Status.completed;
              break;
            case 'To Do':
            default:
              status = Status.todo;
          }
          
          // map notification values
          NotificationFrequency freq;
          switch(item['notification_frequency'] ?? 'daily') {
            case 'weekly':
              freq = NotificationFrequency.weekly;
              break;
            case 'monthly':
              freq = NotificationFrequency.monthly;
              break;
            case 'none':
              freq = NotificationFrequency.none;
              break;
            default:
              freq = NotificationFrequency.daily;
          }
          
          // parse comma-separated tags
          List<String> tags = [];
          if (item['tags'] != null && item['tags'].toString().isNotEmpty) {
            tags = item['tags'].toString().split(',');
          }
          
          // parse members with default role
          Map<String, String> members = {};
          if (item['members'] != null && item['members'].toString().isNotEmpty) {
            for (var member in item['members'].toString().split(',')) {
              members[member] = 'Editor'; // default everyone to editor
            }
          }
          
          try {
            // construct complete task object
            Task task = Task(
              taskId: item['task_id'],  // important for updating
              title: item['task_name'] ?? 'Unnamed Task',
              description: item['description'] ?? '',
              status: status,
              priority: item['priority'] ?? 1,
              percentageWeighting: double.tryParse(item['weighting'].toString()) ?? 0.0,
              listOfTags: tags,
              startDate: DateTime.tryParse(item['start_date']) ?? DateTime.now(),
              endDate: DateTime.tryParse(item['end_date']) ?? DateTime.now().add(const Duration(days: 7)),
              members: members,
              notificationPreference: true,
              notificationFrequency: freq,
              directoryPath: 'tasks/${item['task_id']}',
              parentProject: projectUuid,
            );
            tasks.add(task);
          } catch (e) {
            print('Error parsing task: $e');
          }
        }
        
        return tasks;
      }
      return [];
    } catch (e) {
      print('Error getting tasks: $e');
      return [];
    }
  }

  // updates existing task on server
  // [handles all fields that can be modified]
  static Future<bool> updateTask(Task task, String projectUuid) async {
    try {
      print('=== Updating Task ===');
      print('Task: ${task.title}');
      
      // format dates
      String startDate = "${task.startDate.year}-${task.startDate.month.toString().padLeft(2, '0')}-${task.startDate.day.toString().padLeft(2, '0')}";
      String endDate = "${task.endDate.year}-${task.endDate.month.toString().padLeft(2, '0')}-${task.endDate.day.toString().padLeft(2, '0')}";
      
      // map enum to string for api
      String notificationFreq;
      switch (task.notificationFrequency) {
        case NotificationFrequency.daily:
          notificationFreq = "Daily";
          break;
        case NotificationFrequency.weekly:
          notificationFreq = "Weekly";
          break;
        case NotificationFrequency.monthly:
          notificationFreq = "Monthly";
          break;
        case NotificationFrequency.none:
          notificationFreq = "Never";
          break;
        default:
          notificationFreq = "Daily";
      }
      
      // create member string with roles
      List<String> membersList = [];
      task.members.forEach((username, role) {
        membersList.add('$username:$role');
      });
      String membersString = membersList.join(',');
      
      // convert tags to comma list
      String tagsString = task.listOfTags.join(',');
      
      // map status to match api expectations
      String statusString;
      switch (task.status) {
        case Status.todo:
          statusString = 'to_do';
          break;
        case Status.inProgress:
          statusString = 'in_progress';
          break;
        case Status.completed:
          statusString = 'complete';
          break;
        default:
          statusString = 'to_do';
      }
      
      // build query params for api
      Map<String, String> queryParams = {
        'task_id': task.taskId.toString(),  // crucial for identifying correct task
        'project_id': projectUuid,
        'task_name': task.title,
        'status': statusString,
        'priority': task.priority.toString(),
        'weighting': task.percentageWeighting.toStringAsFixed(0),
        'tags': tagsString,
        'start_date': startDate,
        'end_date': endDate,
        'description': task.description,
        'members': membersString,
        'notification_frequency': notificationFreq,
      };
      
      Uri uri = Uri.parse('$baseUrl/update/task').replace(queryParameters: queryParams);
      
      final response = await http.get(uri);
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error: Update failed - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error updating task: $e');
      return false;
    }
  }

  // removes task from database
  // [identified by task and project ids]
  static Future<bool> deleteTask(String taskId, String projectId) async {
    try {
      print('=== Deleting Task ===');
      print('Task ID: $taskId');
      print('Project ID: $projectId');
      
      final response = await http.get(
        Uri.parse('$baseUrl/delete/task?task_id=$taskId&project_id=$projectId'),
      );
      
      print('Response status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting task: $e');
      return false;
    }
  }
}