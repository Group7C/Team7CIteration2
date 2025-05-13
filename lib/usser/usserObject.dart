import 'package:http/http.dart' as http;
import 'package:sevenc_iteration_two/usser/usserProfilePage.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import '../Objects/task.dart';

class Usser extends ChangeNotifier {
  String usserID = '';
  String usserName;
  String email;
  String usserPassword;
  String theme;
  String? profilePic;
  int currancyTotal;
  Map<String, dynamic> settings;
  Map<int, String> usserData = {};

  List<dynamic> tasks = [];

  Usser(
      this.usserName,
      this.email,
      this.usserPassword,
      this.theme,
      this.profilePic,
      this.currancyTotal,
      this.settings,
      );

  factory Usser.fromJson(Map<String, dynamic> json) {
    // Parse all tasks from all projects
    List<Task> parsedTasks = [];

    if (json['projects'] != null) {
      for (var project in json['projects']) {
        for (var task in project['tasks']) {
          parsedTasks.add(Task(
            title: task['title'],
            description: task['description'],
            status: _parseStatus(task['status']),
            priority: task['priority'],
            percentageWeighting: 0, // you can modify this logic later
            listOfTags: [],
            startDate: DateTime.now(), // no start date in your JSON
            endDate: DateTime.parse(task['deadline']),
            parentProject: project['name'],
            members: {}, // not available in the current JSON
            notificationPreference: true,
            notificationFrequency: NotificationFrequency.none,
            directoryPath: 'offline/tasks/${task['title']}',
          ));
        }
      }
    }

    return Usser(
      json['username'],
      json['email'],
      json['password'],
      json['theme'],
      json['profile_picture'],
      json['currency_total'],
      Map<String, dynamic>.from(json['customize_settings'] ?? {}),
    )..tasks = parsedTasks;
  }

  static Status _parseStatus(String? status) {
    switch (status) {
      case 'inProgress':
        return Status.inProgress;
      case 'completed':
        return Status.completed;
      default:
        return Status.todo;
    }
  }

  Future<String> getID() async {
    final Uri request = Uri.parse(
        "http://127.0.0.1:5000/get/user/id?email=$email");

    String id = '';

    try {
      final response = await http.get(request);

      if (response.statusCode == 200) {
        print(response.body);
        id = response.body;
        print("IN STATUS CODE 200");
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      print(e);
      print("IN EXCEPTION");
    }

    if (id != '') {
      usserID = id;
    }

    return id;
  }

  Future<void> uploadUsser() async {
    final Uri request = Uri.parse(
        "http://127.0.0.1:5000/create/profile?username=$usserName&email=$email&password=$usserPassword");

    final response = await http.get(request);

    if (response.statusCode == 200) {
      print(response.body);
    } else {
      print(response.statusCode);
    }
  }

  void updateUsser() {
    // To be implemented
  }

  Future<String> getProjects() async {
    dynamic id = await getID();

    final Uri request = Uri.parse(
        "http://127.0.0.1:5000/get/user/projects?user_id=$id");

    String projects = '';

    try {
      final response = await http.get(request);

      if (response.statusCode == 200) {
        print(response.body);
        projects = response.body;
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      print(e);
    }

    return projects;
  }

  Future<bool?> checkUsserExists() async {
    final Uri request = Uri.parse(
        "http://127.0.0.1:5000/check/user/exists?email=$email");

    bool userExists;

    try {
      final response = await http.get(request);

      if (response.statusCode == 200) {
        print(response.body);
        userExists = response.body == "True";
        return userExists;
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      print(e);
    }

    return null;
  }

  Future<String?> getTheme() async {
    String id = await getID();

    if (id == '') {
      print("The user does not exist within the database");
      return null;
    } else {
      final Uri request = Uri.parse(
          "http://127.0.0.1:5000/get/user/theme?user_id=$id");

      String? userTheme;

      try {
        final response = await http.get(request);

        if (response.statusCode == 200) {
          print(response.body);
          userTheme = response.body;
        } else {
          print(response.statusCode);
        }
      } catch (e) {
        print(e);
      }

      return userTheme;
    }
  }

  Future<void> changeTheme() async {
    String? userTheme = await getTheme();
    if (userTheme != null) {
      theme = userTheme;
    }
  }

  Future<String?> getPassword() async {
    print("UserId: $usserID");
    if (usserID == '') {
      return null;
    } else {
      final Uri request = Uri.parse(
          "http://127.0.0.1:5000/get/user/password?user_id=$usserID");
      try {
        final response = await http.get(request);
        print("getPasswordStatus: ${response.statusCode}");

        if (response.statusCode == 200) {
          return response.body;
        }
      } catch (e) {
        print(e);
      }
    }
    return null;
  }

  Future<bool?> passwordCorrect() async {
    String? databasePassword = await getPassword();

    print("Datebase Password:$databasePassword");
    if (databasePassword == null) {
      return null;
    } else {
      return (usserPassword == databasePassword);
    }
  }

  Future<void> updateUsername() async {
    final Uri request = Uri.parse("http://127.0.0.1:5000/get/username?email=$email");

    print(email);

    try {
      final response = await http.get(request);

      if (response.statusCode == 200) {
        usserName = response.body;
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      print('in exception');
      print(e);
    }
  }

  Future<List<Task>> getTasksAsync() async {
    return [];
  }

}
