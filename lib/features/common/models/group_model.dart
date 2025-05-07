import 'task_model.dart';

class Group {
  final int taskId;
  final String taskName;
  final String projectName;
  final DateTime deadline;
  final List<TaskMember> members;
  final int projectId;
  final String status;

  Group({
    required this.taskId,
    required this.taskName,
    required this.projectName,
    required this.deadline,
    required this.members,
    required this.projectId,
    required this.status,
  });

  // Factory method to create a Group from a Task
  factory Group.fromTask(Task task) {
    return Group(
      taskId: task.taskId,
      taskName: task.taskName,
      projectName: task.projectName ?? 'Unknown Project',
      deadline: task.endDate,
      members: task.assignedMembers,
      projectId: task.projectUid,
      status: task.status,
    );
  }

  // Get member count for the group
  int get memberCount => members.length;

  // Check if group has multiple members
  bool get isGroup => members.length > 1;

  // Check if a specific user is a member of this group
  bool isMember(int userId) {
    return members.any((member) => member.userId == userId);
  }

  // Get the first few members for preview (limit to 3)
  List<TaskMember> get previewMembers {
    if (members.length <= 3) return members;
    return members.sublist(0, 3);
  }

  // Get additional members count for display
  int get additionalMembersCount => members.length > 3 ? members.length - 3 : 0;
}
