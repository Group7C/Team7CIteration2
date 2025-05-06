import 'package:intl/intl.dart';
import 'meeting_attendance.dart';

/// Model for a meeting [represents a project team meeting]
class Meeting {
  final int id;
  final String? title;
  final DateTime date;
  final String? notes;
  final int totalAttendees;
  final int presentAttendees;
  final List<Map<String, dynamic>>? attendanceDetails;

  Meeting({
    required this.id,
    this.title,
    required this.date,
    this.notes,
    required this.totalAttendees,
    required this.presentAttendees,
    this.attendanceDetails,
  });

  /// Factory constructor from JSON [creates meeting from API response]
  factory Meeting.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(String input) {
      // Try to parse different date formats
      try {
        return DateTime.parse(input);
      } catch (e) {
        try {
          // Try alternative format
          return DateFormat('yyyy-MM-dd').parse(input);
        } catch (e) {
          // Default to current date if parsing fails
          return DateTime.now();
        }
      }
    }

    // Calculate the attendance counts from the attendance map if available
    int totalMembers = 0;
    int presentMembers = 0;
    
    if (json['attendance'] != null && json['attendance'] is Map) {
      final Map<String, dynamic> attendanceMap = json['attendance'] as Map<String, dynamic>;
      totalMembers = attendanceMap.length;
      presentMembers = attendanceMap.values.where((attended) => attended == true).length;
    } else if (json['total_members'] != null) {
      totalMembers = json['total_members'];
      presentMembers = json['attended_count'] ?? 0;
    }

    return Meeting(
      id: json['id'],
      title: json['title'] ?? 'Meeting on ${parseDate(json['date']).toString().substring(0, 10)}',
      date: parseDate(json['date']),
      notes: json['notes'],
      totalAttendees: totalMembers,
      presentAttendees: presentMembers,
      attendanceDetails: json['attendees'] != null
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
    return '$title on ${formattedDate} at ${timeString} with $presentAttendees/$totalAttendees attendees';
  }
  
  /// Create a copy with optional changes [immutable pattern]
  Meeting copyWith({
    int? id,
    String? title,
    DateTime? date,
    String? notes,
    int? totalAttendees,
    int? presentAttendees,
    List<Map<String, dynamic>>? attendanceDetails,
  }) {
    return Meeting(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      totalAttendees: totalAttendees ?? this.totalAttendees,
      presentAttendees: presentAttendees ?? this.presentAttendees,
      attendanceDetails: attendanceDetails ?? this.attendanceDetails,
    );
  }
}
