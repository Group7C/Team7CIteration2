class Meeting {
  final int? meetingId; // Nullable for new meetings
  final int projectUid;
  final String meetingTitle;
  final DateTime meetingDate;
  final String? notes;
  final bool isCompleted;
  final List<MeetingAttendee> attendees;

  Meeting({
    this.meetingId,
    required this.projectUid,
    required this.meetingTitle,
    required this.meetingDate,
    this.notes,
    this.isCompleted = false,
    this.attendees = const [],
  });

  // Create a meeting from JSON data
  factory Meeting.fromJson(Map<String, dynamic> json) {
    // Parse attendees if present
    List<MeetingAttendee> attendeesList = [];
    if (json.containsKey('attendees') && json['attendees'] is List) {
      attendeesList = (json['attendees'] as List)
          .map((attendeeJson) => MeetingAttendee.fromJson(attendeeJson))
          .toList();
    }

    return Meeting(
      meetingId: json['meeting_id'],
      projectUid: json['project_uid'],
      meetingTitle: json['meeting_title'],
      meetingDate: DateTime.parse(json['meeting_date']),
      notes: json['notes'],
      isCompleted: json['is_completed'] ?? false,
      attendees: attendeesList,
    );
  }

  // Convert meeting to JSON
  Map<String, dynamic> toJson() {
    return {
      'meeting_id': meetingId,
      'project_uid': projectUid,
      'meeting_title': meetingTitle,
      'meeting_date': meetingDate.toIso8601String().split('T')[0], // Format as YYYY-MM-DD
      'notes': notes,
      'is_completed': isCompleted,
      // Don't include attendees in the base JSON
    };
  }

  // Create a copy of this meeting with updated fields
  Meeting copyWith({
    int? meetingId,
    int? projectUid,
    String? meetingTitle,
    DateTime? meetingDate,
    String? notes,
    bool? isCompleted,
    List<MeetingAttendee>? attendees,
  }) {
    return Meeting(
      meetingId: meetingId ?? this.meetingId,
      projectUid: projectUid ?? this.projectUid,
      meetingTitle: meetingTitle ?? this.meetingTitle,
      meetingDate: meetingDate ?? this.meetingDate,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
      attendees: attendees ?? this.attendees,
    );
  }
}

class MeetingAttendee {
  final int membersId;
  final int userId;
  final String? username;
  final bool attended;

  MeetingAttendee({
    required this.membersId,
    required this.userId,
    this.username,
    this.attended = false,
  });

  // Create a meeting attendee from JSON data
  factory MeetingAttendee.fromJson(Map<String, dynamic> json) {
    return MeetingAttendee(
      membersId: json['members_id'],
      userId: json['user_id'],
      username: json['username'],
      attended: json['attended'] ?? false,
    );
  }

  // Convert meeting attendee to JSON
  Map<String, dynamic> toJson() {
    return {
      'members_id': membersId,
      'user_id': userId,
      'username': username,
      'attended': attended,
    };
  }

  // Create a copy of this attendee with updated fields
  MeetingAttendee copyWith({
    int? membersId,
    int? userId,
    String? username,
    bool? attended,
  }) {
    return MeetingAttendee(
      membersId: membersId ?? this.membersId,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      attended: attended ?? this.attended,
    );
  }
}
