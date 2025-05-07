import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/meetings/meeting.dart';
import '../models/meetings/meeting_attendance.dart';

/// Simplified service for managing meeting data
class MeetingService {
  static const String baseUrl = 'http://127.0.0.1:5000';
  
  /// Schedule a new meeting (simplified to just date and minimal required fields)
  static Future<int> scheduleMeeting({
    required String projectId,
    required DateTime date,
    String? title,
    String? meetingType,
  }) async {
    try {
      print('Scheduling meeting for project ID: $projectId on ${date.toString().substring(0, 10)}');
      
      // Generate a default title if none provided
      final meetingTitle = title ?? 'Meeting on ${date.toString().substring(0, 10)}';
      
      // Make sure date is at least 1 day in the future to show up as upcoming
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final scheduledDate = date.isBefore(tomorrow) ? tomorrow : date;
      
      // Create request with minimal required fields and filler data for required DB fields
      final response = await http.get(
        Uri.parse('$baseUrl/create/meeting').replace(queryParameters: {
          'project_id': projectId,
          'meeting_type': meetingType ?? 'Online',
          'subject': meetingTitle,
          'start_date': scheduledDate.toString().substring(0, 10),
          'end_date': scheduledDate.toString().substring(0, 10),
          'attendees': 'To be recorded', // Filler data
          'progress': 'To be updated', // Filler data
          'takeaway': 'To be determined', // Filler data
          'notes': 'Scheduled meeting', // Filler data
        }),
      );
      
      print('Schedule meeting response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['meeting_id'];
      } else {
        throw Exception('Failed to schedule meeting: ${response.statusCode}');
      }
    } catch (e) {
      print('Error scheduling meeting: $e');
      rethrow;
    }
  }
  
  /// Get all meetings for a project
  static Future<List<Meeting>> getProjectMeetings(String projectId) async {
    try {
      print('Getting meetings for project ID: $projectId');
      
      final response = await http.get(
        Uri.parse('$baseUrl/get/project/meetings').replace(queryParameters: {
          'project_id': projectId,
        }),
      );

      print('Get meetings response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        // Parse the response body
        final dynamic data = json.decode(response.body);
        
        // Check if there's an error message and handle it
        if (data is Map<String, dynamic> && data.containsKey('error')) {
          print('Backend returned error: ${data['error']}');
          
          // Create a fallback meeting with tomorrow's date
          final meeting = Meeting(
            id: 0,
            title: 'Scheduled Meeting',
            date: DateTime.now().add(const Duration(days: 1)),
            totalAttendees: 0,
            presentAttendees: 0,
            isCompleted: false,
          );
          
          // Get meetings created through the schedule endpoint
          final scheduledMeeting = await getCreatedMeeting(projectId);
          if (scheduledMeeting != null) {
            return [scheduledMeeting];
          }
          
          return [meeting];
        }
        
        // Handle both array and object responses
        if (data is List) {
          // If it's already a list, map each item to a Meeting
          return data.map((item) => Meeting.fromJson(item)).toList();
        } else if (data is Map<String, dynamic>) {
          // If it's a map with a meetings array field, use that
          if (data.containsKey('meetings') && data['meetings'] is List) {
            return (data['meetings'] as List)
                .map((item) => Meeting.fromJson(item))
                .toList();
          } else {
            // Consider the entire map as a single meeting
            return [Meeting.fromJson(data)];
          }
        } else {
          // Empty list as fallback
          return [];
        }
      } else {
        throw Exception('Failed to load meetings: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading meetings: $e');
      rethrow;
    }
  }
  
  /// Get only scheduled (upcoming) meetings for a project
  static Future<List<Meeting>> getScheduledMeetings(String projectId) async {
    try {
      print('Getting scheduled meetings for project ID: $projectId');
      
      // Get all meetings first
      final allMeetings = await getProjectMeetings(projectId);
      
      // Filter to only include future meetings that aren't completed
      final now = DateTime.now();
      final scheduledMeetings = allMeetings
          .where((meeting) => 
              !meeting.isCompleted && 
              meeting.date.isAfter(now))
          .toList();
      
      // Sort by date (earliest first)
      scheduledMeetings.sort((a, b) => a.date.compareTo(b.date));
      
      print('Found ${scheduledMeetings.length} scheduled meetings');
      scheduledMeetings.forEach((meeting) {
        print('Scheduled meeting: ID=${meeting.id}, Title=${meeting.title}, Date=${meeting.date}');
      });
      
      return scheduledMeetings;
    } catch (e) {
      print('Error getting scheduled meetings: $e');
      return [];
    }
  }
  
  /// Get a specific meeting by ID
  static Future<Meeting?> getCreatedMeeting(String projectId) async {
    try {
      // Try to directly query the meeting table for this project's meetings
      final response = await http.get(
        Uri.parse('$baseUrl/create/meeting').replace(queryParameters: {
          'project_id': projectId,
          'subject': 'Upcoming Meeting',
          'start_date': DateTime.now().add(const Duration(days: 1)).toString().substring(0, 10),
          'end_date': DateTime.now().add(const Duration(days: 1)).toString().substring(0, 10),
          'attendees': 'To be recorded',
          'progress': 'To be updated',
          'takeaway': 'To be determined',
          'notes': 'Scheduled meeting',
        }),
      );
      
      if (response.statusCode == 200) {
        // Create a meeting object directly using the response
        final data = json.decode(response.body);
        if (data.containsKey('meeting_id')) {
          // Create a dummy meeting with the ID and future date
          return Meeting(
            id: data['meeting_id'],
            title: 'Upcoming Meeting',
            date: DateTime.now().add(const Duration(days: 1)),
            totalAttendees: 0,
            presentAttendees: 0,
            isCompleted: false,
          );
        }
      }
      return null;
    } catch (e) {
      print('Error getting created meeting: $e');
      return null;
    }
  }
  
  /// Record attendance for a meeting
  static Future<bool> recordAttendance({
    required String meetingId,
    required Map<String, bool> attendance, // Map of member_id to attendance status
  }) async {
    try {
      print('Recording attendance for meeting ID: $meetingId');
      
      // Filter to only include members who attended (true values)
      final attendedMembers = attendance.entries
          .where((entry) => entry.value == true)
          .map((e) => e.key)
          .toList();
      
      print('Attended members: $attendedMembers');
      
      // If no one attended, return early
      if (attendedMembers.isEmpty) {
        print('No members attended this meeting');
        return true; // Still consider this successful - it's valid to have no attendees
      }
      
      // Convert the filtered attendance to the required format: "member_id:true,..."
      final membersAttendance = attendedMembers
          .map((id) => '$id:true')
          .join(',');
      
      final response = await http.get(
        Uri.parse('$baseUrl/update/meeting/attendance').replace(queryParameters: {
          'meeting_id': meetingId,
          'members_attendance': membersAttendance,
        }),
      );
      
      print('Record attendance response: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error recording attendance: $e');
      return false;
    }
  }
  
  /// Get details of a specific meeting by ID
  static Future<Meeting?> getMeetingById(String meetingId) async {
    try {
      print('Getting details for meeting ID: $meetingId');
      
      final response = await http.get(
        Uri.parse('$baseUrl/get/meeting').replace(queryParameters: {
          'meeting_id': meetingId,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Meeting.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting meeting details: $e');
      return null;
    }
  }
}