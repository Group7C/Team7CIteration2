import 'package:flutter/material.dart';

/// Simple class to represent a meeting attendee
class MeetingAttendee {
  final int membersId;
  final int? userId;
  final String? username;
  final bool attended;
  
  /// Constructor for meeting attendee
  const MeetingAttendee({
    required this.membersId,
    this.userId,
    this.username,
    required this.attended,
  });
  
  /// Create from JSON object
  factory MeetingAttendee.fromJson(Map<String, dynamic> json) {
    return MeetingAttendee(
      membersId: json['members_id'],
      userId: json['user_id'],
      username: json['username'],
      attended: json['attended'] ?? false,
    );
  }
  
  /// Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'members_id': membersId,
      'user_id': userId,
      'username': username,
      'attended': attended,
    };
  }
}

/// Class for tracking meeting attendance records
class MeetingAttendance {
  final DateTime date;
  final Map<String, bool> attendanceByMemberId; // Changed to String keys to match API
  final String? notes;
  final String? title;
  
  /// Constructor for meeting attendance
  MeetingAttendance({
    required this.date,
    required this.attendanceByMemberId,
    this.notes,
    this.title,
  });
  
  /// Convert to JSON for API [serializes data for backend]
  Map<String, dynamic> toJson() {
    return {
      'date': date.toString().substring(0, 10), // Format for API: YYYY-MM-DD
      'members_attendance': attendanceByMemberId.entries
          .map((e) => '${e.key}:${e.value}')
          .join(','), // Format for API: "member_id:true,member_id:false,..."
      'notes': notes ?? '',
      'title': title ?? 'Meeting on ${date.toString().substring(0, 10)}',
    };
  }
  
  /// Factory constructor from JSON [creates attendance from API response]
  factory MeetingAttendance.fromJson(Map<String, dynamic> json) {
    final attendance = <String, bool>{};
    
    // Handle attendance records from the API
    if (json['attendees'] != null && json['attendees'] is List) {
      final attendeesList = json['attendees'] as List;
      for (final attendee in attendeesList) {
        if (attendee is Map && attendee.containsKey('members_id') && attendee.containsKey('attended')) {
          attendance[attendee['members_id'].toString()] = attendee['attended'] == true;
        }
      }
    }
    
    // Parse the date
    DateTime meetingDate;
    if (json['date'] != null) {
      meetingDate = DateTime.parse(json['date']);
    } else if (json['start_date'] != null) {
      meetingDate = DateTime.parse(json['start_date']);
    } else if (json['meeting_date'] != null) {
      meetingDate = DateTime.parse(json['meeting_date']);
    } else {
      meetingDate = DateTime.now();
    }
    
    return MeetingAttendance(
      date: meetingDate,
      attendanceByMemberId: attendance,
      notes: json['notes'],
      title: json['subject'] ?? json['meeting_title'] ?? json['title'],
    );
  }
  
  /// Calculates attendance percentage [between 0.0 and 1.0]
  double getAttendancePercentage() {
    if (attendanceByMemberId.isEmpty) return 0.0;
    
    final presentCount = attendanceByMemberId.values.where((present) => present).length;
    return presentCount / attendanceByMemberId.length;
  }
  
  /// Counts how many people attended [present members count]
  int getPresentCount() {
    return attendanceByMemberId.values.where((present) => present).length;
  }
  
  /// Gets the total number of members [size of attendance map]
  int getTotalMemberCount() {
    return attendanceByMemberId.length;
  }
}