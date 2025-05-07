class Project {
  final int projectUid;
  final String joinCode;
  final String projName;
  final DateTime deadline;
  final String notificationPreference;
  final String? googleDriveLink;
  final String? discordLink;
  final String uuid;
  final List<ProjectMember> members;

  Project({
    required this.projectUid,
    required this.joinCode,
    required this.projName,
    required this.deadline,
    required this.notificationPreference,
    this.googleDriveLink,
    this.discordLink,
    required this.uuid,
    this.members = const [],
  });

  // Create a simple Project from just a name
  factory Project.fromName(String name) {
    return Project(
      projectUid: 0, // Placeholder
      joinCode: '', // Placeholder
      projName: name,
      deadline: DateTime.now().add(const Duration(days: 30)), // Placeholder
      notificationPreference: 'Weekly', // Placeholder
      uuid: '', // Placeholder
      members: [],
    );
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      projectUid: json['project_uid'],
      joinCode: json['join_code'],
      projName: json['proj_name'],
      deadline: DateTime.parse(json['deadline']),
      notificationPreference: json['notification_preference'],
      googleDriveLink: json['google_drive_link'],
      discordLink: json['discord_link'],
      uuid: json['uuid'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'project_uid': projectUid,
      'join_code': joinCode,
      'proj_name': projName,
      'deadline': deadline.toIso8601String().split('T')[0],
      'notification_preference': notificationPreference,
      'google_drive_link': googleDriveLink,
      'discord_link': discordLink,
      'uuid': uuid,
    };
  }
}

class ProjectMember {
  final int membersId;
  final int projectUid;
  final int userId;
  final bool isOwner;
  final String memberRole;
  final DateTime joinDate;
  final String? username; // From ONLINE_USER table

  ProjectMember({
    required this.membersId,
    required this.projectUid,
    required this.userId,
    required this.isOwner,
    required this.memberRole,
    required this.joinDate,
    this.username,
  });

  factory ProjectMember.fromJson(Map<String, dynamic> json) {
    return ProjectMember(
      membersId: json['members_id'],
      projectUid: json['project_uid'],
      userId: json['user_id'],
      isOwner: json['is_owner'],
      memberRole: json['member_role'],
      joinDate: DateTime.parse(json['join_date']),
      username: json['username'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'members_id': membersId,
      'project_uid': projectUid,
      'user_id': userId,
      'is_owner': isOwner,
      'member_role': memberRole,
      'join_date': joinDate.toIso8601String().split('T')[0],
      'username': username,
    };
  }
}
