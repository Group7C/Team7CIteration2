import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meeting_model.dart';
import '../models/project_model.dart';

class MeetingService {
  // Base URL for API calls 
  static const String _baseUrl = 'http://localhost:5000';

  // Get all meetings for a specific project
  static Future<List<Meeting>> getProjectMeetings(int projectId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/get/project/meetings?project_id=$projectId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load meetings: ${response.statusCode}');
      }

      // Parse the JSON response
      final dynamic jsonResponse = jsonDecode(response.body);
      
      // Check if there's an error in the response
      if (jsonResponse is Map<String, dynamic> && jsonResponse.containsKey('error')) {
        throw Exception(jsonResponse['error']);
      }

      // Handle the response if it's a list of meetings
      if (jsonResponse is List) {
        // Convert to Meeting objects
        final List<Meeting> meetings = jsonResponse
            .map((meetingJson) => Meeting.fromJson(meetingJson))
            .toList();

        return meetings;
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      print('Error fetching project meetings: $e');
      throw Exception('Failed to load meetings: $e');
    }
  }

  // Create a new meeting (either scheduled or record of past meeting)
  static Future<int> createMeeting({
    required int projectId,
    required String meetingTitle,
    required DateTime meetingDate,
    String? notes,
    bool isCompleted = false,
  }) async {
    try {
      // Format the date for the API
      final formattedDate = meetingDate.toIso8601String().split('T')[0];
      
      // Build the URL with query parameters
      String url = '$_baseUrl/create/meeting?project_id=$projectId&meeting_title=$meetingTitle&meeting_date=$formattedDate';
      
      // Add optional parameters
      if (notes != null) url += '&notes=$notes';
      url += '&is_completed=$isCompleted';
      
      // Make the API call
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to create meeting: ${response.statusCode}');
      }

      final Map<String, dynamic> result = jsonDecode(response.body);
      
      if (result.containsKey('error')) {
        throw Exception(result['error']);
      }

      return result['meeting_id'];
    } catch (e) {
      print('Error creating meeting: $e');
      throw Exception('Failed to create meeting: $e');
    }
  }

  // Update meeting attendance records
  static Future<bool> updateMeetingAttendance({
    required int meetingId,
    required List<MeetingAttendee> attendees,
  }) async {
    try {
      // Format the attendance data as "memberId:attended,memberId:attended,..."
      final attendanceData = attendees.map((attendee) => 
        '${attendee.membersId}:${attendee.attended}'
      ).join(',');
      
      // Build the URL with query parameters
      final url = '$_baseUrl/update/meeting/attendance?meeting_id=$meetingId&members_attendance=$attendanceData';
      
      // Make the API call
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update attendance: ${response.statusCode}');
      }

      final Map<String, dynamic> result = jsonDecode(response.body);
      
      if (result.containsKey('error')) {
        throw Exception(result['error']);
      }

      return result['success'] ?? false;
    } catch (e) {
      print('Error updating meeting attendance: $e');
      throw Exception('Failed to update attendance: $e');
    }
  }

  // Helper method to create meeting with attendance records in one call
  static Future<int> createMeetingWithAttendance({
    required int projectId,
    required String meetingTitle,
    required DateTime meetingDate,
    String? notes,
    required List<MeetingAttendee> attendees,
  }) async {
    // First create the meeting
    final meetingId = await createMeeting(
      projectId: projectId,
      meetingTitle: meetingTitle,
      meetingDate: meetingDate,
      notes: notes,
      isCompleted: true, // This is a record of a past meeting
    );
    
    // Then update the attendance
    if (attendees.isNotEmpty) {
      await updateMeetingAttendance(
        meetingId: meetingId,
        attendees: attendees,
      );
    }
    
    return meetingId;
  }
}
