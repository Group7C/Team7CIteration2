import '../usser/usserObject.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

enum NotiPref {
  daily,
  weekly
}

class Project extends ChangeNotifier {
  // the projectId is the PK value in the db and the projectUuid is the
  // unique identifier for the project
  int? projectId;
  NotiPref? notificationPreference;
  String? projectUuid;
  String name;
  String joinCode;
  DateTime? dueDate;
  String? google_drive_link;
  String? discord_link;

  // if you are trying to create a group, then the dueDate will be passed as an
  // argument
  Project(this.name, this.joinCode, [this.dueDate]);

  Future<bool?> uuidExists(String tempUuid) async {
    // method to ensure that uuid isn't already associated to a project otherwise
    // have to regenerate a new uuid

    final Uri request = Uri.parse("http://127.0.0.1:5000/check/project/uuid/exists?uuid=$tempUuid");
    print("Inside uuidexists, tempUuid=$tempUuid");


    try {
      // using http to asynchronously get the information from flask
      final response = await http.get(request);

      if (response.statusCode == 200) {
        // if the response was successful you will get the expected information
        print(response.body);
        if (int.parse(response.body) > 0) { return true; }
        else { return false; }
      }
      else {
        // if you do not get a valid status code you will be returned an invalid
        // status code
        print(response.statusCode);
      }
    }
    catch (e) {
      // catching any exceptions
      print(e);
    }

    // return null if there is an error
    return null;
  }

  Future<void> generateUuid() async{
    // method to generate the uuid, need to ensure that there isn't another
    // project which already uses this uuid

    Uuid uuid = const Uuid();

    bool? exists = true;

    // keep trying to generate new uuid till original one found
    while (exists == true) {
      String tempUuid = uuid.v6();

      print(tempUuid);
      print(tempUuid.length);
      // if the uuid doesn't exist inside the database, then you can store it
      // inside the database and move on

      exists = await uuidExists(tempUuid);
      print("Exists: $exists");
      if (exists == false) {
        projectUuid = tempUuid;
        // uploadUuid(tempUuid);
      }
      else if (exists == null) {
        // need to handle what happens if there is an error trying to check if
        // the uuid exists

        // ADD MORE HERE
        break;
      }
    }

  }

  /*
  Future<void> uploadUuid(String tempUuid) async {
    // once the uuid has been generated and it is unique, this method will handle
    // storing the uuid in the database

    final Uri request = Uri.parse(
        "http://127.0.0.1:5000/get/user/id?email=$tempUuid");

    try {
      // using http to asynchronously get the information from flask
      final response = await http.get(request);

      if (response.statusCode == 200) {
        // if the response was successful you will get the expected information
        print(response.body);
        print("IN STATUS CODE 200");
      }
      else {
        // if you do not get a valid status code you will be returned an invalid
        // status code
        print(response.statusCode);
      }
    }
    catch (e) {
      // catching any exceptions
      print(e);
      print("IN EXCEPTION");
    }
  }

   */

  Future<bool?> isPasswordCorrect() async {
    // function will check if the join code of a project matches the one in the
    // database

    final Uri request = Uri.parse("http://127.0.0.1:5000/project/"
        "password/validation?uuid=$projectUuid&password=$joinCode");


    try {
      // using http to asynchronously get the information from flask
      final response = await http.get(request);

      if (response.statusCode == 200) {
        // if the response was successful you will get the expected information
        print(response.body);
        if (int.parse(response.body) == 1) { return true; }
        else { return false; }
      }
      else {
        print(response.statusCode);
      }
    }
    catch (e) {
      // catching any exceptions
      print(e);
    }

    // return null if there is an error
    return null;

  }

  Future<void> loadAttributes() async {
    // when successfully joining a project you can load the other attributes of
    // the project from the database

    // function will check if the join code of a project matches the one in the
    // database

    final Uri request = Uri.parse("http://127.0.0.1:5000/get/"
        "project/attributes?uuid=$projectUuid&password=$joinCode");

    try {
      // using http to asynchronously get the information from flask
      final response = await http.get(request);

      if (response.statusCode == 200) {
        // if the response was successful you will get the expected information
        print(response.body);

        List<String> attributes = jsonDecode(response.body);
        projectId = int.parse(attributes[0]);
        attributes[1] == "Weekly"? notificationPreference = NotiPref.weekly :
        notificationPreference = NotiPref.daily;
        name = attributes[2];
        dueDate = DateTime.parse(attributes[3]);
        attributes[4] == "Null"? google_drive_link = null: google_drive_link = attributes[4];
        attributes[5] == "Null"? discord_link = null: discord_link = attributes[5];

        // because the home screen ui will use the name of the project as the
        // title
        notifyListeners();
      }
      else {
        print(response.statusCode);
      }
    }
    catch (e) {
      // catching any exceptions
      print(e);
    }
  }

  Future<int?> getProjectId() async {
    final Uri request = Uri.parse("http://127.0.0.1:5000/"
        "get/project/id?uuid=$projectUuid");

    try {
      // using http to asynchronously get the information from flask
      final response = await http.get(request);

      if (response.statusCode == 200) {
        // if the response was successful you will get the expected information
        print(response.body);
        return int.parse(response.body);
      }
      else {
        print(response.statusCode);
      }
    }
    catch (e) {
      // catching any exceptions
      print(e);
    }

    return null;

  }

  Future<bool?> isUserInProject(String userId) async {


    int? projectId = await getProjectId();

    final Uri request = Uri.parse("http://127.0.0.1:5000/"
        "user/in/project?user_id=$userId&project_id=$projectId");

    try {
      // using http to asynchronously get the information from flask
      final response = await http.get(request);

      if (response.statusCode == 200) {
        // if the response was successful you will get the expected information
        print(response.body);
        if (int.parse(response.body) > 0) { return true;}
        else { return false;}

      }
      else {
        print(response.statusCode);
      }
    }
    catch (e) {
      // catching any exceptions
      print(e);
    }

    return null;
  }


  Future<List<String?>> joinProject(String? uidErrorText, String? joinCodeErrorText, String userId) async {
    // this function will be called when a user tries to join a project

    // first have to check if that uuid exists
    bool? exists = await uuidExists(projectUuid!);


    if (exists == true) {
      // have to check that the user is not trying to join a project they are already
      // a part of
      bool? userExists = await isUserInProject(userId);

      print("DOES THE USER EXIST INSIDE THE PROJECT: $userExists");

      // will prevent the rest of the function from executing
      if (userExists == true) {

        print("inside user exists ");
        uidErrorText = "You are already part of that project";
      }
      else {
        // the project exists so now you can compare to see if the join code is
        // correct

        bool? correctPassword = await isPasswordCorrect();

        if (correctPassword == true) {
          // went successful, the uuid exists and the password matches
          // this means that you can now load other attributes from the project
          // in the database

          loadAttributes();
        }
        else {
          // unsuccessful attempt to join project
          joinCodeErrorText = "Incorrect join code";
        }
      }
    }
    else if (exists == false) {
      // the project does not exist
      uidErrorText = "Incorrect id";
    }
    else {
      // error trying to retrieve information
      uidErrorText = "Unable to check if project exists with that uuid";
    }

    List<String?> errors = [uidErrorText, joinCodeErrorText];

    return errors;
  }

  Future<void> uploadProjectDatabase(String userId) async {
    // this function will be responsible for uploading the project to the database



    final Uri request = Uri.parse(
        "http://127.0.0.1:5000/upload/project?uuid=$projectUuid"
            "&name=$name&join=$joinCode&due=$dueDate&user_id=$userId");

    try {
      // using http to asynchronously get the information from flask
      final response = await http.get(request);

      if (response.statusCode == 200) {
        // if the response was successful you will get the expected information
        print(response.body);
        print("IN STATUS CODE 200");
      }
      else {
        // if you do not get a valid status code you will be returned an invalid
        // status code
        print(response.statusCode);
      }
    }
    catch (e) {
      // catching any exceptions
      print(e);
      print("IN EXCEPTION");
    }
  }

  /*
  void getUuid() => projectUuid;
   */
}