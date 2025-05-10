import 'package:flutter/material.dart';
import '../Objects/task.dart'; // Reusing NotificationFrequency

class Project with ChangeNotifier {
  String projectName;
  String joinCode;
  DateTime deadline;
  NotificationFrequency notificationFrequency;
  String? googleDriveLink;
  String? discordLink;
  String uuid;
  List<String> members = [];

  Project({
    required this.projectName,
    required this.joinCode,
    required this.deadline,
    required this.notificationFrequency,
    required this.uuid,
    this.googleDriveLink,
    this.discordLink,
    List<String>? members,
  }) : members = members ?? [];

  void addMember(String username) {
    if (!members.contains(username)) {
      members.add(username);
      notifyListeners();
    }
  }

  void removeMember(String username) {
    members.remove(username);
    notifyListeners();
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
