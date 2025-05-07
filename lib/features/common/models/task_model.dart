// Task and TaskMember model classes for the application

// Task model class
class Task {
  final int taskId;
  final String taskName;
  final String? parent;
  final int? weighting;
  final String? tags;
  final int priority;
  final DateTime startDate;
  final DateTime endDate;
  final String? description;
  final String? members;
  final String notificationFrequency;
  final String status;
  final int projectUid;
  final String? projectName;
  final List<TaskMember> assignedMembers;

  Task({
    required this.taskId,
    required this.taskName,
    this.parent,
    this.weighting,
    this.tags,
    required this.priority,
    required this.startDate,
    required this.endDate,
    this.description,
    this.members,
    required this.notificationFrequency,
    required this.status,
    required this.projectUid,
    this.projectName,
    this.assignedMembers = const [],
  });

  // Create a copy of this task with updated fields
  Task copyWith({
    int? taskId,
    String? taskName,
    String? parent,
    int? weighting,
    String? tags,
    int? priority,
    DateTime? startDate,
    DateTime? endDate,
    String? description,
    String? members,
    String? notificationFrequency,
    String? status,
    int? projectUid,
    String? projectName,
    List<TaskMember>? assignedMembers,
  }) {
    return Task(
      taskId: taskId ?? this.taskId,
      taskName: taskName ?? this.taskName,
      parent: parent ?? this.parent,
      weighting: weighting ?? this.weighting,
      tags: tags ?? this.tags,
      priority: priority ?? this.priority,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      description: description ?? this.description,
      members: members ?? this.members,
      notificationFrequency: notificationFrequency ?? this.notificationFrequency,
      status: status ?? this.status,
      projectUid: projectUid ?? this.projectUid,
      projectName: projectName ?? this.projectName,
      assignedMembers: assignedMembers ?? this.assignedMembers,
    );
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    // Debug the incoming JSON
    print('Parsing task JSON: ${json.keys.join(', ')}');
    
    // Handle assigned members if present
    List<TaskMember> members = [];
    if (json.containsKey('assigned_members') && json['assigned_members'] != null) {
      try {
        members = (json['assigned_members'] as List)
            .map((member) => TaskMember.fromJson(member))
            .toList();
      } catch (e) {
        print('Error parsing assigned members: $e');
      }
    }

    // Safely parse integers with null checks
    int taskId = 0;
    try {
      taskId = json['task_id'] is int 
          ? json['task_id'] 
          : int.tryParse(json['task_id']?.toString() ?? '0') ?? 0;
    } catch (e) {
      print('Error parsing task_id: $e');
    }

    int projectUid = 0;
    try {
      projectUid = json['project_uid'] is int 
          ? json['project_uid'] 
          : int.tryParse(json['project_uid']?.toString() ?? '0') ?? 0;
    } catch (e) {
      print('Error parsing project_uid: $e');
    }

    int priority = 1; // Default priority
    try {
      priority = json['priority'] is int 
          ? json['priority'] 
          : int.tryParse(json['priority']?.toString() ?? '1') ?? 1;
    } catch (e) {
      print('Error parsing priority: $e');
    }

    // Parse dates with safety
    DateTime startDate = DateTime.now();
    try {
      startDate = json['start_date'] != null 
          ? DateTime.parse(json['start_date'].toString()) 
          : DateTime.now();
    } catch (e) {
      print('Error parsing start_date: $e');
    }

    DateTime endDate = DateTime.now().add(const Duration(days: 7));
    try {
      endDate = json['end_date'] != null 
          ? DateTime.parse(json['end_date'].toString()) 
          : DateTime.now().add(const Duration(days: 7));
    } catch (e) {
      print('Error parsing end_date: $e');
    }

    return Task(
      taskId: taskId,
      taskName: json['task_name']?.toString() ?? 'Unnamed Task',
      parent: json['parent']?.toString(),
      weighting: json['weighting'] is int 
          ? json['weighting'] 
          : int.tryParse(json['weighting']?.toString() ?? ''),
      tags: json['tags']?.toString(),
      priority: priority,
      startDate: startDate,
      endDate: endDate,
      description: json['description']?.toString(),
      members: json['members_string']?.toString() ?? json['members']?.toString(),
      notificationFrequency: json['notification_frequency']?.toString() ?? 'weekly',
      status: json['status']?.toString() ?? 'to_do',
      projectUid: projectUid,
      projectName: json['project_name']?.toString(),
      assignedMembers: members,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'task_id': taskId,
      'task_name': taskName,
      'parent': parent,
      'weighting': weighting,
      'tags': tags,
      'priority': priority,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'description': description,
      'members': members,
      'notification_frequency': notificationFrequency,
      'status': status,
      'project_uid': projectUid,
    };
  }
}

// Class to represent members assigned to tasks
class TaskMember {
  final int membersId;
  final int userId;
  final String username;

  TaskMember({
    required this.membersId,
    required this.userId,
    required this.username,
  });

  factory TaskMember.fromJson(Map<String, dynamic> json) {
    try {
      int membersId = json['members_id'] is int 
          ? json['members_id'] 
          : int.tryParse(json['members_id']?.toString() ?? '0') ?? 0;
          
      int userId = json['user_id'] is int 
          ? json['user_id'] 
          : int.tryParse(json['user_id']?.toString() ?? '0') ?? 0;
          
      return TaskMember(
        membersId: membersId,
        userId: userId,
        username: json['username']?.toString() ?? 'Unknown User',
      );
    } catch (e) {
      print('Error parsing TaskMember: $e');
      return TaskMember(
        membersId: 0,
        userId: 0,
        username: 'Error User',
      );
    }
  }
}