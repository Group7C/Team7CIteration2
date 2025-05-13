// Model for project member with all necessary IDs
class ProjectMember {
  final int membersId;  // From project_members table in backend
  final int userId;     // From online_user table in backend
  final String username;
  final String role;
  final bool isOwner;
  
  ProjectMember({
    required this.membersId,
    required this.userId,
    required this.username,
    required this.role,
    required this.isOwner,
  });
  
  factory ProjectMember.fromJson(Map<String, dynamic> json) {
    return ProjectMember(
      membersId: json['members_id'],
      userId: json['user_id'],
      username: json['username'],
      role: json['member_role'] ?? json['role'] ?? 'Editor',
      isOwner: json['is_owner'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'members_id': membersId,
      'user_id': userId,
      'username': username,
      'role': role,
      'is_owner': isOwner,
    };
  }
}
