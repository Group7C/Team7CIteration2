import 'package:flutter/material.dart';
import '../../../common/enums/notification_frequency.dart';

// Team member representation with role and permissions [links user to project]
class ProjectMember {
  final int id;
  final String username;
  final bool isOwner;
  final String role; // Current values: 'editor' or 'viewer'
  final DateTime joinDate;
  final String? profilePicture;

  ProjectMember({
    required this.id,
    required this.username,
    required this.isOwner,
    required this.role,
    required this.joinDate,
    this.profilePicture,
  });
}

// Main project model [includes ChangeNotifier for state updates]
class Project with ChangeNotifier {
  final int id;
  String name;
  DateTime deadline;
  String joinCode;
  NotificationFrequency notificationPreference;
  String? googleDriveLink;
  String? discordLink;
  List<ProjectMember> members;
  int completedTasks;
  int totalTasks;
  String? description;
  Color colour; // Theme colour for project visuals
  DateTime? nextMeetingDate; // Next scheduled meeting date
  DateTime? lastMeetingDate; // Last held meeting date

  Project({
    required this.id,
    required this.name,
    required this.deadline,
    required this.joinCode,
    required this.notificationPreference,
    this.googleDriveLink,
    this.discordLink,
    required this.members,
    required this.completedTasks,
    required this.totalTasks,
    this.description,
    required this.colour,
    this.nextMeetingDate,
    this.lastMeetingDate,
  });

  // Calculates completion percentage [used for progress indicators]
  double get progress => totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0;
  
  // Finds project creator/admin [person with full control rights]
  ProjectMember? get owner {
    try {
      return members.firstWhere((member) => member.isOwner);
    } catch (e) {
      return null;
    }
  }
  
  // Calculates days until deadline [for timeline displays]
  int get daysRemaining {
    final today = DateTime.now();
    return deadline.difference(today).inDays;
  }
  
  // Determines project health status [affects UI colour indicators]
  String get status {
    if (daysRemaining < 0) return 'Overdue';
    if (daysRemaining < 7) return 'Due soon';
    return 'On track';
  }
  
  // Methods for modifying project state [each calls notifyListeners]
  void updateName(String newName) {
    name = newName;
    notifyListeners();
  }
  
  void updateDeadline(DateTime newDeadline) {
    deadline = newDeadline;
    notifyListeners();
  }
  
  void updateNotificationPreference(NotificationFrequency newPreference) {
    notificationPreference = newPreference;
    notifyListeners();
  }
  
  void updateLinks({String? googleDrive, String? discord}) {
    if (googleDrive != null) googleDriveLink = googleDrive;
    if (discord != null) discordLink = discord;
    notifyListeners();
  }
  
  void addMember(ProjectMember member) {
    members.add(member);
    notifyListeners();
  }
  
  void removeMember(int memberId) {
    members.removeWhere((member) => member.id == memberId);
    notifyListeners();
  }
  
  void updateTaskProgress(int completed, int total) {
    completedTasks = completed;
    totalTasks = total;
    notifyListeners();
  }
  
  void updateNextMeetingDate(DateTime? date) {
    nextMeetingDate = date;
    notifyListeners();
  }
  
  void updateLastMeetingDate(DateTime? date) {
    lastMeetingDate = date;
    notifyListeners();
  }
}