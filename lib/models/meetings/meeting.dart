import 'package:intl/intl.dart';
import 'meeting_attendance.dart';

/// Simplified Meeting model that focuses on date and attendance
class Meeting {
  final int id;
  final String? title; // Subject in the database
  final DateTime date; // Start date in the database
  final DateTime? endDate; // End date in the database (optional in UI)
  final String? notes; // Optional notes
  final int totalAttendees;
  final int presentAttendees;
  final List<Map<String, dynamic>>? attendanceDetails;
  final String meetingType; // Meeting type enum: 'In-person' or 'Online'
  final bool isCompleted; // Whether attendance has been recorded

  Meeting({
    required this.id,
    this.title,
    required this.date,
    this.endDate,
    this.notes,
    required this.totalAttendees,
    required this.presentAttendees,
    this.attendanceDetails,
    this.meetingType = 'Online', // Default to Online
    this.isCompleted = false,
  });

  /// Factory constructor from JSON [creates meeting from API response]
  factory Meeting.fromJson(Map<String, dynamic> json) {
    print('DEBUG: Processing meeting JSON: ${json.toString().substring(0, json.toString().length > 200 ? 200 : json.toString().length)}');
    
    DateTime parseDate(String? input) {
      // Default to current date if input is null
      if (input == null) {
        print('DEBUG: Date input was null, using current date');
        return DateTime.now();
      }
      
      print('DEBUG: Parsing date from: $input');
      
      // Try to parse different date formats
      try {
        final date = DateTime.parse(input);
        print('DEBUG: Successfully parsed date: $date');
        return date;
      } catch (e) {
        try {
          // Try alternative format
          final date = DateFormat('yyyy-MM-dd').parse(input);
          print('DEBUG: Successfully parsed date with format yyyy-MM-dd: $date');
          return date;
        } catch (e) {
          // Default to current date if parsing fails
          print('DEBUG: Failed to parse date, using current date + 1 day');
          // For scheduled meetings, use tomorrow as default to ensure they appear as upcoming
          return DateTime.now().add(const Duration(days: 1));
        }
      }
    }

    // Get the meeting date (prioritize start_date over meeting_date for backwards compatibility)
    DateTime meetingDate;
    if (json['start_date'] != null) {
      meetingDate = parseDate(json['start_date'].toString());
    } else if (json['meeting_date'] != null) {
      meetingDate = parseDate(json['meeting_date'].toString());
    } else {
      meetingDate = DateTime.now();
    }
    
    // Get the end date if available
    DateTime? endDate;
    if (json['end_date'] != null) {
      endDate = parseDate(json['end_date'].toString());
    }

    // Get the title (prioritize subject over meeting_title for backwards compatibility)
    String? title = json['subject'] ?? json['meeting_title'] ?? 
      'Meeting on ${meetingDate.toString().substring(0, 10)}';

    // Safely handle integer values with defaults
    int meetingId = json['meeting_id'] is int ? json['meeting_id'] : 
                    (json['id'] is int ? json['id'] : 0);
                    
    // Calculate attendance counts
    int totalMembers = 0;
    int presentMembers = 0;
    
    if (json['total_attendees'] != null) {
      totalMembers = json['total_attendees'] is int ? json['total_attendees'] : 0;
    }
    
    if (json['present_attendees'] != null) {
      presentMembers = json['present_attendees'] is int ? json['present_attendees'] : 0;
    }
    
    // For old data format - process attendees list if available
    if ((totalMembers == 0 || presentMembers == 0) && json['attendees'] != null && json['attendees'] is List) {
      final attendees = json['attendees'] as List;
      totalMembers = attendees.length;
      presentMembers = attendees.where((a) => a['attended'] == true).length;
    }

    // Get the meeting type with default
    String meetingType = json['meeting_type']?.toString() ?? 'Online';
    
    // Check if meeting is completed - new meetings should default to false
    bool isCompleted = false;
    
    // If we're creating a new meeting (from a schedule action), it's not completed
    bool isNewMeeting = json.containsKey('success') && json['success'] == true;
    if (isNewMeeting) {
      print('DEBUG: This appears to be a newly created meeting - marking as not completed');
      isCompleted = false;
    } else if (json['is_completed'] != null) {
      isCompleted = json['is_completed'] == true;
      print('DEBUG: Meeting has explicit is_completed flag: $isCompleted');
    } else if (json['attendees'] != null && json['attendees'] is List && (json['attendees'] as List).isNotEmpty) {
      // If we have attendance records, consider it completed
      isCompleted = true;
      print('DEBUG: Meeting has attendance records - considering it completed');
    } else {
      // By default, future meetings are not completed
      var meetingIsInFuture = meetingDate.isAfter(DateTime.now());
      if (meetingIsInFuture) {
        isCompleted = false;
        print('DEBUG: Meeting is in the future - marking as not completed');
      }
    }

    return Meeting(
      id: meetingId,
      title: title,
      date: meetingDate,
      endDate: endDate,
      notes: json['notes']?.toString(),
      totalAttendees: totalMembers,
      presentAttendees: presentMembers,
      meetingType: meetingType,
      isCompleted: isCompleted,
      attendanceDetails: json['attendees'] != null && json['attendees'] is List
          ? (json['attendees'] as List).cast<Map<String, dynamic>>()
          : null,
    );
  }

  /// Get formatted date string [returns user-friendly date]
  String get formattedDate => DateFormat('MMMM d, yyyy').format(date);
  
  /// Get time string [returns formatted time]
  String get timeString => DateFormat('h:mm a').format(date);
  
  /// Calculate attendance percentage [returns 0-100]
  double get attendancePercentage {
    if (totalAttendees == 0) return 0.0;
    return (presentAttendees / totalAttendees) * 100;
  }
  
  /// Check if meeting has notes [returns true if notes exist]
  bool get hasNotes => notes != null && notes!.isNotEmpty;
  
  /// Generate a summary of the meeting [returns brief overview]
  String generateSummary() {
    return '$title on ${formattedDate} with $presentAttendees/$totalAttendees attendees';
  }
  
  /// Create a copy with optional changes [immutable pattern]
  Meeting copyWith({
    int? id,
    String? title,
    DateTime? date,
    DateTime? endDate,
    String? notes,
    int? totalAttendees,
    int? presentAttendees,
    List<Map<String, dynamic>>? attendanceDetails,
    String? meetingType,
    bool? isCompleted,
  }) {
    return Meeting(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      endDate: endDate ?? this.endDate,
      notes: notes ?? this.notes,
      totalAttendees: totalAttendees ?? this.totalAttendees,
      presentAttendees: presentAttendees ?? this.presentAttendees,
      attendanceDetails: attendanceDetails ?? this.attendanceDetails,
      meetingType: meetingType ?? this.meetingType,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
