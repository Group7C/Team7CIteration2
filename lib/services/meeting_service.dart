import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/meetings/meeting.dart';
import '../models/meetings/meeting_attendance.dart';

/// Service for managing meeting data [interacts with meeting API endpoints]
class MeetingService {
  static const String baseUrl = 'http://127.0.0.1:5000';
  
  /// Create a new meeting with attendance records
  static Future<int> createMeeting({
    required String projectId,
    required DateTime date,
    required Map<int, bool> attendance,
    String? title,
    String? notes,
    String? meetingType,
  }) async {
    try {
      print('Calling API to create meeting for project ID: $projectId');
      
      // Convert the Map<int, bool> to Map<String, bool> for reliable JSON serialization
      final Map<String, bool> serializedAttendance = {};
      attendance.forEach((key, value) {
        serializedAttendance[key.toString()] = value;
      });
      
      final requestData = {
        'project_id': projectId,
        'date': date.toIso8601String(),
        'title': title ?? 'Meeting on ${date.toIso8601String().substring(0, 10)}',
        'notes': notes ?? '',
        'attendance': serializedAttendance,
        'meeting_type': meetingType ?? 'Online', // Updated to use valid meeting type
        'end_date': date.toIso8601String(), // Adding end date
      };
      
      print('Request data: ${json.encode(requestData)}');
      
      // Try direct HTTP call with timeout
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/meetings'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: json.encode(requestData),
        ).timeout(const Duration(seconds: 10));
        
        print('Response status code: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 201) {
          final data = json.decode(response.body);
          return data['meeting_id'];
        } else {
          print('Failed to create meeting: ${response.statusCode}');
          print('Response body: ${response.body}');
          throw Exception('Failed to create meeting: ${response.statusCode}');
        }
      } catch (e) {
        print('First attempt failed: $e');
        print('Trying again with a different approach...');
        
        // Try a backup approach with different URL format
        try {
          final response = await http.post(
            Uri.parse('http://localhost:5000/meetings'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(requestData),
          ).timeout(const Duration(seconds: 15));
          
          print('Second attempt response status code: ${response.statusCode}');
          print('Second attempt response body: ${response.body}');
          
          if (response.statusCode == 201) {
            final data = json.decode(response.body);
            return data['meeting_id'];
          }
        } catch (secondError) {
          print('Second attempt also failed: $secondError');
        }
        
        // If both attempts fail, rethrow the original error
        rethrow;
      }
    } catch (e) {
      print('Error creating meeting: $e');
      rethrow;
    }
  }
  
  /// Get all meetings for a project
  static Future<List<Meeting>> getProjectMeetings(String projectId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/project/$projectId/meetings'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Meeting.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load meetings');
      }
    } catch (e) {
      print('Error loading meetings: $e');
      rethrow;
    }
  }
  
  /// Get details of a specific meeting
  static Future<Map<String, dynamic>> getMeetingDetails(String meetingId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/meetings/$meetingId'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load meeting details');
      }
    } catch (e) {
      print('Error loading meeting details: $e');
      rethrow;
    }
  }
  
  /// Get contribution metrics for project members
  static Future<List<Map<String, dynamic>>> getProjectContribution(String projectId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/project/$projectId/contribution'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load contribution data');
      }
    } catch (e) {
      print('Error loading contribution data: $e');
      rethrow;
    }
  }
  
  /// Set the upcoming meeting date for a project
  static Future<bool> setUpcomingMeetingDate(String projectId, DateTime date) async {
    try {
      print('Setting upcoming meeting date for project $projectId to ${date.toIso8601String()}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/project/$projectId/upcoming-meeting'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'date': date.toIso8601String(),
        }),
      );
      
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error setting upcoming meeting date: $e');
      return false;
    }
  }
  
  /// Update the last meeting date for a project
  static Future<bool> setLastMeetingDate(String projectId, DateTime date) async {
    try {
      print('Setting last meeting date for project $projectId to ${date.toIso8601String()}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/project/$projectId/last-meeting'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'date': date.toIso8601String(),
        }),
      );
      
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error setting last meeting date: $e');
      return false;
    }
  }
  
  /// Get the next and last meeting dates for a project
  static Future<Map<String, dynamic>> getProjectMeetingDates(String projectId) async {
    try {
      print('Getting meeting dates for project $projectId');
      
      final response = await http.get(
        Uri.parse('$baseUrl/project/$projectId/meeting-dates'),
      );
      
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load meeting dates');
      }
    } catch (e) {
      print('Error getting meeting dates: $e');
      return {
        'next_meeting_date': null,
        'last_meeting_date': null,
      };
    }
  }
  
  /// Test connectivity to the meeting API
  static Future<bool> testConnection() async {
    try {
      print('Testing connection to meeting API...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/test/meeting-api'),
      );
      
      print('Test response status code: ${response.statusCode}');
      print('Test response body: ${response.body}');
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error testing connection: $e');
      return false;
    }
  }
}
