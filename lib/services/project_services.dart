import 'package:http/http.dart' as http;
import 'dart:convert';
import '../projects/project_model.dart';
import '../projects/project_member.dart';
import '../Objects/task.dart';

// handles all api requests related to projects
// communicates with backend for creating, updating, retrieving projects
class ProjectServices {
  // server endpoint [set to localhost for testing]
  static const String baseUrl = 'http://127.0.0.1:5000';

  // sends project data to server for creation
  // [adds user as member automatically]
  static Future<bool> createProject(
    String name, 
    String joinCode, 
    String dueDate, 
    String uuid, 
    String userId,
    String? googleDriveLink,
    String? discordLink,
    String notificationPreference,
  ) async {
    try {
      // build url with all required parameters
      String url = '$baseUrl/upload/project?name=${Uri.encodeComponent(name)}'
          '&join=${Uri.encodeComponent(joinCode)}'
          '&due=${Uri.encodeComponent(dueDate)}'
          '&uuid=${Uri.encodeComponent(uuid)}'
          '&user_id=${Uri.encodeComponent(userId)}'
          '&notification_preference=${Uri.encodeComponent(notificationPreference)}';
      
      // add optional parameters if they exist
      if (googleDriveLink != null && googleDriveLink.isNotEmpty) {
        url += '&google_drive_link=${Uri.encodeComponent(googleDriveLink)}';
      }
      if (discordLink != null && discordLink.isNotEmpty) {
        url += '&discord_link=${Uri.encodeComponent(discordLink)}';
      }
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print('Error creating project: $e');
      return false;
    }
  }
  
  // gets basic project info for specific user
  // [simpler version without detailed member info]
  static Future<List<Project>> getProjects(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get/projects?user_id=$userId'),
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<Project> projects = [];
        
        for (var item in data) {
          // convert notification preference string to enum
          NotificationFrequency notification;
          switch(item['notification_preference']?.toLowerCase()) {
            case 'daily':
              notification = NotificationFrequency.daily;
              break;
            case 'monthly':
              notification = NotificationFrequency.monthly;
              break;
            case 'none':
              notification = NotificationFrequency.none;
              break;
            default:
              notification = NotificationFrequency.weekly;
          }
          
          // build members map with default role
          Map<String, String> members = {};
          if (item['members'] != null) {
            // set everyone to editor by default
            for (String member in List<String>.from(item['members'])) {
              members[member] = 'Editor';
            }
          }
          
          projects.add(Project(
            projectName: item['name'],
            joinCode: item['joinCode'],
            deadline: DateTime.parse(item['deadline']),
            notificationFrequency: notification,
            uuid: item['uuid'],
            projectUid: item['project_uid'],
            googleDriveLink: item['google_drive_link'],
            discordLink: item['discord_link'],
            members: members,
            nextMeeting: item['next_meeting'],  // capture any scheduled meetings
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
  
  // sends updated project details to server
  // [handles all editable properties]
  static Future<bool> updateProject(Project project) async {
    try {
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
      
      // format date as yyyy-mm-dd
      String deadlineStr = project.deadline.toIso8601String().split('T')[0];
      
      // convert members to simple comma list for api
      String membersStr = project.members.keys.join(',');
      
      // build url with all params
      final String url = '$baseUrl/update/project'
          '?uuid=${Uri.encodeComponent(project.uuid)}'
          '&name=${Uri.encodeComponent(project.projectName)}'
          '&join_code=${Uri.encodeComponent(project.joinCode)}'
          '&deadline=${Uri.encodeComponent(deadlineStr)}'
          '&notification_preference=${Uri.encodeComponent(notificationPref)}'
          '&google_drive_link=${Uri.encodeComponent(project.googleDriveLink ?? '')}'
          '&discord_link=${Uri.encodeComponent(project.discordLink ?? '')}'
          '&members=${Uri.encodeComponent(membersStr)}';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['status'] == 'success';
      }
      return false;
    } catch (e) {
      print('Error updating project: $e');
      return false;
    }
  }
  
  // enhanced version that includes detailed member info
  // [preferred method for most ui needs]
  static Future<List<Project>> getProjectsWithMembers(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get/projects_with_members?user_id=$userId'),
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<Project> projects = [];
        
        for (var item in data) {
          // convert notification preference string to enum
          NotificationFrequency notification;
          switch(item['notification_preference']?.toLowerCase()) {
            case 'daily':
              notification = NotificationFrequency.daily;
              break;
            case 'monthly':
              notification = NotificationFrequency.monthly;
              break;
            case 'none':
              notification = NotificationFrequency.none;
              break;
            default:
              notification = NotificationFrequency.weekly;
          }
          
          // parse detailed member objects
          List<ProjectMember> membersList = [];
          if (item['members_list'] != null) {
            for (var memberData in item['members_list']) {
              membersList.add(ProjectMember.fromJson(memberData));
            }
          }
          
          // backwards compatible members map
          Map<String, String> members = {};
          if (item['members'] != null) {
            members = Map<String, String>.from(item['members']);
          }
          
          projects.add(Project(
            projectName: item['name'],
            joinCode: item['joinCode'],
            deadline: DateTime.parse(item['deadline']),
            notificationFrequency: notification,
            uuid: item['uuid'],
            projectUid: item['project_uid'],
            googleDriveLink: item['google_drive_link'],
            discordLink: item['discord_link'],
            members: members,
            membersList: membersList,
            nextMeeting: item['next_meeting'],
          ));
        }
        
        return projects;
      }
      return [];
    } catch (e) {
      print('Error getting projects with members: $e');
      return [];
    }
  }
  
  // removes project from database
  // [requires user to be project member]
  static Future<bool> deleteProject(String projectUuid, String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/delete/project?uuid=$projectUuid&user_id=$userId'),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['status'] == 'success';
      }
      return false;
    } catch (e) {
      print('Error deleting project: $e');
      return false;
    }
  }
  
  // adds user to existing project using join code
  // [returns detailed message for ui feedback]
  static Future<Map<String, dynamic>> joinProject(String joinCode, String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/join/project?join_code=$joinCode&user_id=$userId'),
      );
      
      if (response.statusCode == 200) {
        // backend returns plain text rather than json now
        final responseStr = response.body;
        
        // check if contains success message from backend so we party
        if (responseStr.contains('success')) {
          return {
            'status': 'success',
            'message': 'Successfully joined the project'
          };
        } else {
          return {
            'status': 'error',
            'message': responseStr
          };
        }
      }
      return {'status': 'error', 'message': 'Failed to join project'};
    } catch (e) {
      print('Error joining project: $e');
      return {'status': 'error', 'message': 'Network error: $e'};
    }
  }
}