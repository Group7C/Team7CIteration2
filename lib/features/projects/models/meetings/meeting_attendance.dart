import 'package:flutter/material.dart';

// Class for tracking who attended meetings [attendance record model]
class MeetingAttendance {
  final DateTime date;
  final Map<int, bool> attendanceByMemberId;
  final String? notes;
  
  // Convert attendance map to JSON-safe format
  Map<String, bool> get serializedAttendance {
    final Map<String, bool> result = {};
    attendanceByMemberId.forEach((key, value) {
      result[key.toString()] = value;
    });
    return result;
  }
  
  MeetingAttendance({
    required this.date,
    required this.attendanceByMemberId,
    this.notes,
  });
  
  // Finds the most recent meeting [returns null if no meetings exist]
  static DateTime? getLastMeetingDate(List<MeetingAttendance> meetings) {
    if (meetings.isEmpty) return null;
    
    // Sort newest first and grab the top one [most recent date first]
    final sortedMeetings = List<MeetingAttendance>.from(meetings)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sortedMeetings.first.date;
  }
  
  // Calculates attendance percentage [between 0.0 and 1.0]
  double getAttendancePercentage() {
    if (attendanceByMemberId.isEmpty) return 0.0;
    
    final presentCount = attendanceByMemberId.values.where((present) => present).length;
    return presentCount / attendanceByMemberId.length;
  }
  
  // Counts how many people attended [present members count]
  int getPresentCount() {
    return attendanceByMemberId.values.where((present) => present).length;
  }
  
  // Gets the total number of members [size of attendance map]
  int getTotalMemberCount() {
    return attendanceByMemberId.length;
  }
  
  // Makes a clone with optional changes [immutable pattern]
  MeetingAttendance copyWith({
    DateTime? date,
    Map<int, bool>? attendanceByMemberId,
    String? notes,
  }) {
    return MeetingAttendance(
      date: date ?? this.date,
      attendanceByMemberId: attendanceByMemberId ?? Map.from(this.attendanceByMemberId),
      notes: notes ?? this.notes,
    );
  }
}