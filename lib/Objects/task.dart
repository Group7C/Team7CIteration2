import 'package:flutter/material.dart';
enum NotificationFrequency { daily, weekly, monthly, none }
enum Role { editor, reader }
extension RoleExtension on Role {
  String get name {
    switch (this) {
      case Role.editor:
        return 'Editor';
      case Role.reader:
        return 'Reader';
      default:
        return '';
    }
  }
}
enum Status {todo, inProgress, completed}

extension StatusExtension on Status {
  String get displayName {
    switch (this) {
      case Status.todo:
        return 'To Do';
      case Status.inProgress:
        return 'In Progress';
      case Status.completed:
        return 'Completed';
    }
  }
}

class Task with ChangeNotifier {

  String title;
  String? parentProject;
  double percentageWeighting;
  List<String> listOfTags = [];
  int priority;
  DateTime startDate = DateTime.now();
  DateTime endDate;
  Map<String, String> members = {};
  bool notificationPreference = true;
  NotificationFrequency notificationFrequency = NotificationFrequency.daily;
  String description;
  String directoryPath;
  List<String>? comments;
  Status status = Status.todo;

  Task({
    required this.title,
    this.parentProject,
    required this.status,
    required this.percentageWeighting,
    required this.listOfTags, 
    required this.priority,
    required this.startDate,
    required this.endDate,
    required this.description,
    required this.members,
    required this.notificationPreference ,
    required this.notificationFrequency ,
    required this.directoryPath,
  List<String>? comments,
  })  :  comments = comments ?? [] {
    
    if ( endDate.isBefore(startDate)) {
      throw ArgumentError("End date must be after start date.");
    }
    if (description.length > 400) {
      throw Exception("Description is too long.");
    }
  }

  void setTask() {
    title = '';    
    percentageWeighting = 0.0;
    listOfTags = [];
    priority = 1;
    startDate = DateTime.now();
    endDate = DateTime.now().add(Duration(hours: 1));
    description = '';
    members = {};
    notificationPreference = true;
    notificationFrequency = NotificationFrequency.daily;
    notifyListeners(); 
  }

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

  void removeTag(String tag) {
    listOfTags.remove(tag);
    notifyListeners();
  }

  List<String>? getTags() {
    return listOfTags;
  }

  bool canEdit(String username) {
    return members.containsKey(username);
  }

  void updateNotificationFrequency(NotificationFrequency frequency) {
    notificationFrequency = frequency;
    notifyListeners();
  }

  void addOrUpdateTag(String oldTag, String newTag) {
    if (newTag.isEmpty) {
      print("New tag cannot be empty.");
      return;
    }
    int index = listOfTags.indexOf(oldTag);
    if (index != -1) {
      listOfTags[index] = newTag;
    } else {
      listOfTags.add(newTag);
    }
    notifyListeners();
  }

  void updatePriority(int newPriority) {
    priority = newPriority;
    notifyListeners();
  }

  void updatePercentageWeighting(double newPercentageWeighting) {
    percentageWeighting = newPercentageWeighting;
    notifyListeners();
  }

  void updateEndDate(DateTime newEndDate) {
    if (newEndDate.isBefore(startDate)) {
      throw Exception("End date must be after start date");
    }
    endDate = newEndDate;
    notifyListeners();
  }

  void updateDescription(String newDescription) {
    if (newDescription.length > 400) {
      throw Exception("Character limit reached!!!");
    }
    description = newDescription;
    notifyListeners();
  }

  void updateTitle(String newTitle) {
    title = newTitle;
    notifyListeners();
  }

  void updateNotificationPreference(bool newPreference) {
    notificationPreference = newPreference;
    notifyListeners();
  }

  void updateStatus (Status newStatus){
    status = newStatus;
    notifyListeners();
  }
}