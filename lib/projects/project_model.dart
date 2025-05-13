import 'package:flutter/material.dart';
import '../Objects/task.dart'; // For NotificationFrequency and Role
import 'project_member.dart';

class Project with ChangeNotifier {
  String projectName;
  String joinCode;
  DateTime deadline;
  NotificationFrequency notificationFrequency;
  String? googleDriveLink;
  String? discordLink;
  String uuid;
  int? projectUid;  // Nullable for new projects - backend will assign  
  List<ProjectMember> membersList = []; //  structure with full member data
  Map<String, String> members = {}; // keep for backward compatibility for now
  Map<String, dynamic>? nextMeeting; //   Store next meeting info for meetings component
  
  Project({
    required this.projectName,
    required this.joinCode,
    required this.deadline,
    required this.notificationFrequency,
    required this.uuid,
    this.projectUid,  
    this.googleDriveLink,
    this.discordLink,
    Map<String, String>? members, 
    List<ProjectMember>? membersList,
    this.nextMeeting,  
  }) : members = members ?? {},
       membersList = membersList ?? [] {
    // Sync members map from membersList if provided
    if (this.membersList.isNotEmpty) {
      for (var member in this.membersList) {
        this.members[member.username] = member.role;
      }
    }
  }

  void addMemberWithDetails(ProjectMember member) {
    membersList.add(member);
    members[member.username] = member.role;
    notifyListeners();
  }
  
  ProjectMember? getMemberByUsername(String username) {
    try {
      return membersList.firstWhere((member) => member.username == username);
    } catch (e) {
      return null;
    }
  }
   // Just a bunch of getters and setters for the project
  void addMember(String username, String role) {
    members[username] = role;
    notifyListeners();
  }

  void removeMember(String username) {
    members.remove(username);
    notifyListeners();
  }

  
  List<String> getMemberNames() {
    return members.keys.toList();
  }

  void updateDeadline(DateTime newDeadline) {
    deadline = newDeadline;
    notifyListeners();
  }

  void updateNotificationFrequency(NotificationFrequency frequency) {
    notificationFrequency = frequency;
    notifyListeners();
  }

  void updateGoogleDriveLink(String link) {
    googleDriveLink = link;
    notifyListeners();
  }

  void updateDiscordLink(String link) {
    discordLink = link;
    notifyListeners();
  }
}
