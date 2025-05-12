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

  
 void assignMember(String username, Role role, List<String> projectMembers) {
  if (username.trim().isEmpty) {
    throw ArgumentError('Username must not be empty.');
  }

  if (!projectMembers.any((m) => m.toLowerCase() == username.toLowerCase())) {
    throw ArgumentError('Username "$username" is not a valid project member.');
  }

  members[username] = role.name;
  notifyListeners();
}


  void removeMember(String username) {
    if (username.trim().isEmpty) {
      throw ArgumentError('Username must not be empty.');
    }
    members.remove(username);
    notifyListeners();
  }

  List<String> getMembers() {
    return members.keys.toList();
  }

  void removeTag(String? tagToDelete) {
  // Check if the tag to remove is null or empty
  if (tagToDelete == null || tagToDelete.trim().isEmpty) {    
    return;
  }
  //case-insensitive check
  int index = listOfTags.indexWhere(
    (tag) => tag.toLowerCase() == tagToDelete.toLowerCase(),
  );
  if (index == -1) {    
    return;
  }
  listOfTags.removeAt(index);
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

  void addOrUpdateTag(String? oldTag, String? newTag) {

  newTag = newTag?.trim();
  //New tag cannot be null or empty.
  if (newTag == null || newTag.trim().isEmpty) {   
    return;
  }
  //Not more than 20 characters.
  if (newTag.length > 20) {
    return;
  }
  //Check tag list.
  if (listOfTags.any((tag) => tag.toLowerCase() == newTag!.toLowerCase())) {
      return;
  }
  if (oldTag != null) {
    int index = listOfTags.indexOf(oldTag);
    if (index != -1) {
      listOfTags[index] = newTag;
      notifyListeners();
      return;
    }
  }
  listOfTags.add(newTag);
  notifyListeners();
}


  void updatePriority(int newPriority) {
    if (newPriority < 1 || newPriority > 5) {
    throw ArgumentError('Priority must be between 1 and 5. Received: $newPriority');
  }
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

  void updateStartDate(DateTime newStartDate) {
    if (newStartDate.isAfter(endDate)) {
      throw Exception("Start date must be before end date");
    }
    startDate = newStartDate;
    notifyListeners();
  }

  void updateDescription(String? newDescription) {
    if (newDescription == null) {
    throw ArgumentError("Description cannot be null.");
    }
    if (newDescription.length > 400) {
      throw Exception("Description exceed character limit (400).");
    }
    description = newDescription;
    notifyListeners();
  }

  void updateTitle(String? newTitle) {
    if (newTitle == null) {
    throw ArgumentError("Title cannot be null.");
    }
    if (newTitle.trim().isEmpty) {
      throw ArgumentError("Title cannot be empty or whitespace.");
    }
    if (newTitle.length > 50) {
      throw ArgumentError("Title cannot exceed 50 characters.");
    }
    title = newTitle;
    notifyListeners();
  }

  void updateNotificationPreference(bool newPreference) {
    notificationPreference = newPreference;
    notificationFrequency = NotificationFrequency.none;
    notifyListeners();
  }

  void updateStatus (Status newStatus){
    status = newStatus;
    notifyListeners();
  }
}