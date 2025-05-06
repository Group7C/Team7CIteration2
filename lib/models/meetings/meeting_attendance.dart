import 'package:flutter/material.dart';

/// Class for tracking who attended meetings [attendance record model]
class MeetingAttendance {
  final DateTime date;
  final Map<int, bool> attendanceByMemberId;
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
    // Convert the attendance map to a JSON-safe format (String keys)
    final Map<String, bool> serializedAttendance = {};
    attendanceByMemberId.forEach((key, value) {
      serializedAttendance[key.toString()] = value;
    });
    
    return {
      'date': date.toIso8601String(),
      'attendance': serializedAttendance,
      'notes': notes ?? '',
      'title': title ?? 'Meeting on ${date.toIso8601String().substring(0, 10)}',
    };
  }
  
  /// Factory constructor from JSON [creates attendance from API response]
  factory MeetingAttendance.fromJson(Map<String, dynamic> json) {
    final attendance = <int, bool>{};
    
    if (json.containsKey('attendance') && json['attendance'] is List) {
      final attendanceList = json['attendance'] as List;
      for (final attendee in attendanceList) {
        if (attendee is Map && attendee.containsKey('user_id') && attendee.containsKey('attended')) {
          attendance[attendee['user_id']] = attendee['attended'];
        }
      }
    }
    
    return MeetingAttendance(
      date: DateTime.parse(json['date']),
      attendanceByMemberId: attendance,
      notes: json['notes'],
      title: json['title'],
    );
  }
  
  /// Finds the most recent meeting [returns null if no meetings exist]
  static DateTime? getLastMeetingDate(List<MeetingAttendance> meetings) {
    if (meetings.isEmpty) return null;
    
    // Sort newest first and grab the top one [most recent date first]
    final sortedMeetings = List<MeetingAttendance>.from(meetings)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sortedMeetings.first.date;
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
  
  /// Gets a list of member IDs who attended [present member IDs]
  List<int> getPresentMemberIds() {
    return attendanceByMemberId.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
  }
  
  /// Gets a list of member IDs who didn't attend [absent member IDs]
  List<int> getAbsentMemberIds() {
    return attendanceByMemberId.entries
        .where((entry) => !entry.value)
        .map((entry) => entry.key)
        .toList();
  }
  
  /// Makes a clone with optional changes [immutable pattern]
  MeetingAttendance copyWith({
    DateTime? date,
    Map<int, bool>? attendanceByMemberId,
    String? notes,
    String? title,
  }) {
    return MeetingAttendance(
      date: date ?? this.date,
      attendanceByMemberId: attendanceByMemberId ?? Map.from(this.attendanceByMemberId),
      notes: notes ?? this.notes,
      title: title ?? this.title,
    );
  }
}