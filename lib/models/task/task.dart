import 'package:flutter/material.dart';
import '../../../common/enums/notification_frequency.dart';

// This is a simplified version of the Task class to replace the one moved to redundant
class Task with ChangeNotifier {
  String title;
  String? parentProject;
  double percentageWeighting;
  List<String> listOfTags;
  int priority;
  DateTime startDate;
  DateTime endDate;
  Map<String, String> members;
  bool notificationPreference;
  NotificationFrequency notificationFrequency;
  String description;
  String directoryPath;
  List<String>? comments;

  Task({
    required this.title,
    this.parentProject,
    required this.percentageWeighting,
    required this.listOfTags, 
    required this.priority,
    required this.startDate,
    required this.endDate,
    required this.description,
    required this.members,
    required this.notificationPreference,
    required this.notificationFrequency,
    required this.directoryPath,
    List<String>? comments,
  }) : comments = comments ?? [] {
    // Initialization code if needed
  }

  // Basic methods to satisfy requirements
  void assignMember(String username, String role) {
    members[username] = role;
    notifyListeners();
  }

  void removeMember(String username) {
    members.remove(username);
    notifyListeners();
  }

  List<String> getMembers() {
    return members.keys.toList();
  }

  List<String>? getTags() {
    return listOfTags;
  }

  // Simplified method to create a copy with modifications
  Task copyWith({
    String? title,
    String? parentProject,
    double? percentageWeighting,
    List<String>? listOfTags,
    int? priority,
    DateTime? startDate,
    DateTime? endDate,
    String? description,
    Map<String, String>? members,
    bool? notificationPreference,
    NotificationFrequency? notificationFrequency,
    String? directoryPath,
    List<String>? comments,
  }) {
    return Task(
      title: title ?? this.title,
      parentProject: parentProject ?? this.parentProject,
      percentageWeighting: percentageWeighting ?? this.percentageWeighting,
      listOfTags: listOfTags ?? this.listOfTags,
      priority: priority ?? this.priority,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      description: description ?? this.description,
      members: members ?? this.members,
      notificationPreference: notificationPreference ?? this.notificationPreference,
      notificationFrequency: notificationFrequency ?? this.notificationFrequency,
      directoryPath: directoryPath ?? this.directoryPath,
      comments: comments ?? this.comments,
    );
  }
}