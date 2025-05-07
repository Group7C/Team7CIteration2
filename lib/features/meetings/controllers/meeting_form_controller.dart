import 'package:flutter/material.dart';
import '../../../services/meeting_service.dart';
import '../../../models/meetings/meeting.dart';
import '../../../models/meetings/meeting_attendance.dart';
import '../../../features/common/models/project_model.dart';

enum MeetingFormMode { schedule, record }

class MeetingFormController {
  // Form controllers for both form types
  final titleController = TextEditingController();
  final dateController = TextEditingController();
  final notesController = TextEditingController();
  
  // Currently selected meeting (for record attendance mode)
  Meeting? selectedMeeting;
  
  // List of scheduled meetings for dropdown
  List<Meeting> scheduledMeetings = [];
  
  // Map to track attendance selections (memberId -> attended)
  final Map<String, bool> attendanceMap = {};
  
  // Form validation keys
  final scheduleFormKey = GlobalKey<FormState>();
  final recordFormKey = GlobalKey<FormState>();
  
  // Focus nodes
  final titleFocusNode = FocusNode();
  final dateFocusNode = FocusNode();
  final notesFocusNode = FocusNode();
  
  // Initialize controllers with default values
  void initDefaults() {
    // Default meeting date is tomorrow
    final defaultDate = DateTime.now().add(const Duration(days: 1));
    dateController.text = defaultDate.toString().substring(0, 10); // Format: YYYY-MM-DD
    
    // Clear other fields
    titleController.clear();
    notesController.clear();
    attendanceMap.clear();
    selectedMeeting = null;
  }
  
  // Load scheduled meetings for a project
  Future<void> loadScheduledMeetings(int projectId) async {
    print('Loading scheduled meetings for project ID: $projectId');
    try {
      scheduledMeetings = await MeetingService.getScheduledMeetings(projectId.toString());
      print('Loaded ${scheduledMeetings.length} scheduled meetings');
    } catch (e) {
      print('Error loading scheduled meetings: $e');
      scheduledMeetings = [];
    }
  }
  
  // Initialize attendance map from project members
  void initAttendanceFromMembers(List<ProjectMember> members) {
    attendanceMap.clear();
    for (var member in members) {
      // Use membersId as String to match the API expectation
      attendanceMap[member.membersId.toString()] = false; // Default to not attended
    }
  }
  
  // Select a meeting from the dropdown
  void selectMeeting(Meeting? meeting) {
    selectedMeeting = meeting;
    print('Selected meeting: ${meeting?.id} - ${meeting?.title}');
  }
  
  // Toggle attendance for a member
  void toggleAttendance(int memberId) {
    final key = memberId.toString();
    if (attendanceMap.containsKey(key)) {
      attendanceMap[key] = !attendanceMap[key]!;
      print('Toggled attendance for member $memberId to ${attendanceMap[key]}');
    }
  }
  
  // Schedule a new meeting - simplified to just require date
  Future<bool> scheduleMeeting(int projectId) async {
    if (!scheduleFormKey.currentState!.validate()) {
      return false;
    }
    
    try {
      // Schedule the meeting with minimal data
      final meetingId = await MeetingService.scheduleMeeting(
        projectId: projectId.toString(),
        date: DateTime.parse(dateController.text),
        title: titleController.text.isNotEmpty ? titleController.text : null,
      );
      
      print('Meeting scheduled with ID: $meetingId');
      
      // Clear form after successful submission
      initDefaults();
      
      return true;
    } catch (e) {
      print('Error scheduling meeting: $e');
      return false;
    }
  }
  
  // Record attendance for an existing meeting
  Future<bool> recordMeeting(int projectId) async {
    if (selectedMeeting == null) {
      print('No meeting selected for recording attendance');
      return false;
    }
    
    try {
      // Print attendance for debugging
      print('Attendance map: $attendanceMap');
      print('Attendance map entries: ${attendanceMap.entries.toList()}');
      print('Members marked as attended: ${attendanceMap.entries.where((e) => e.value).length}');
      
      // Record attendance for the selected meeting
      print('Recording attendance for meeting ID: ${selectedMeeting!.id}');
      final success = await MeetingService.recordAttendance(
        meetingId: selectedMeeting!.id.toString(),
        attendance: attendanceMap,
      );
      
      if (success) {
        // Clear form after successful submission
        initDefaults();
        return true;
      }
      return false;
    } catch (e) {
      print('Error recording meeting: $e');
      return false;
    }
  }
  
  // Dispose resources
  void dispose() {
    titleController.dispose();
    dateController.dispose();
    notesController.dispose();
    
    titleFocusNode.dispose();
    dateFocusNode.dispose();
    notesFocusNode.dispose();
  }
}