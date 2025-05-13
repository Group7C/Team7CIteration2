import 'package:http/http.dart' as http;
import 'dart:convert';

// handles api calls related to project meetings
// [manages scheduling and attendance tracking]
class MeetingServices {
  // server endpoint [local dev server]
  static const String baseUrl = 'http://127.0.0.1:5000';

  // creates a new scheduled meeting
  // [converts datetime to format backend expects - DONT REMOVE AGAIN]
  static Future<Map<String, dynamic>> scheduleMeeting(
    int projectUid,
    DateTime meetingDateTime,
  ) async {
    try {
      // format datetime as yyyy-mm-dd hh:mm:ss string
      String formattedDateTime = 
          '${meetingDateTime.year}-${meetingDateTime.month.toString().padLeft(2, '0')}-'
          '${meetingDateTime.day.toString().padLeft(2, '0')} '
          '${meetingDateTime.hour.toString().padLeft(2, '0')}:'
          '${meetingDateTime.minute.toString().padLeft(2, '0')}:00';

      // post request with json body
      final response = await http.post(
        Uri.parse('$baseUrl/api/meetings/schedule'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'project_uid': projectUid,
          'meeting_datetime': formattedDateTime,
        }),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'error': 'Failed to schedule meeting'};
      }
    } catch (e) {
      print('Error scheduling meeting: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // records which members attended a meeting
  // [improved so it takes member ids rather than usernames]
  static Future<Map<String, dynamic>> recordAttendance(
    int meetingId,
    List<int> memberIds,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/meetings/record_attendance'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'meeting_id': meetingId,
          'member_ids': memberIds,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'error': 'Failed to record attendance'};
      }
    } catch (e) {
      print('Error recording attendance: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // alternative method using usernames instead of ids during dev
  // [easier to use from ui where we might have usernames]
  static Future<Map<String, dynamic>> recordAttendanceByUsernames(
    int meetingId,
    List<String> usernames,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/meetings/record_attendance_by_usernames'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'meeting_id': meetingId,
          'usernames': usernames,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'error': 'Failed to record attendance'};
      }
    } catch (e) {
      print('Error recording attendance: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // retrieves all meetings for a project
  // [includes past and upcoming meetings]
  static Future<List<Map<String, dynamic>>> getProjectMeetings(int projectUid) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/meetings/project/$projectUid'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['meetings'] != null) {
          return List<Map<String, dynamic>>.from(data['meetings']);
        }
      }
      return [];
    } catch (e) {
      print('Error getting project meetings: $e');
      return [];
    }
  }
}