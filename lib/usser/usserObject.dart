import 'package:http/http.dart' as http;
import 'package:sevenc_iteration_two/usser/usserProfilePage.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class Usser extends ChangeNotifier {
  // set the value of the usserID to an empty String initially so you can
  // check if the user exists in the database, given the email and password
  String usserID = '';
  String usserName;
  String email;
  String usserPassword;
  String theme;
  String? profilePic;
  int currancyTotal;
  Map<String, dynamic> settings;
  Map<int, String> usserData = {};

  // setting the type to include list of dynamic which will change to Task when
  // the Task class is established
  List<dynamic> tasks = [];

  Usser(this.usserName,
      this.email,
      this.usserPassword,
      this.theme,
      this.profilePic,
      this.currancyTotal,
      this.settings,);

  // gets the user id based on the user's email and username
  Future<String> getID() async {
    // this function will return the id of the user from the database

    final Uri request = Uri.parse(
        "http://127.0.0.1:5000/get/user/id?email=$email");

    // set to dynamic since it may not return an integer if there is no id
    String id = '';

    try {
      // using http to asynchronously get the information from flask
      final response = await http.get(request);

      if (response.statusCode == 200) {
        // if the response was successful you will get the expected information
        print(response.body);
        id = response.body;
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

    // if the value of id is not empty (user exists in the database) then you
    // can update the id attribute of the user instance

    // -- this part needs to be tested and may need to be removed --

    if (id != '') {
      usserID = id;
    }

    return id;
  }

  Future<void> uploadUsser() async {
    // this function will upload the usser object to the database

    final Uri request = Uri.parse(
        "http://127.0.0.1:5000/create/profile?username=$usserName&email=$email&password=$usserPassword");


    // using http to asynchronously get the information from flask
    final response = await http.get(request);

    if (response.statusCode == 200) {
      // if the response was successful you will get the expected information
      print(response.body);
    }
    else {
      // if you do not get a valid status code you will be returned an invalid
      // status code
      print(response.statusCode);
    }
  }

  void updateUsser() {
    // this function will update the usser object in the database

    // COME BACK TO THIS LATER
  }

  Future<String> getProjects() async {
    // this function will get the projects that the usser is a part of
    // THIS FUNCTION IS A WORK IN PROGRESS SO THERE MAY BE UNEXPECTED BEHAVIOUR

    dynamic id = await getID();

    final Uri request = Uri.parse(
        "http://127.0.0.1:5000/get/user/projects?user_id=$id");

    String projects = '';

    try {
      // using http to asynchronously get the information from flask
      final response = await http.get(request);

      if (response.statusCode == 200) {
        // if the response was successful you will get the expected information
        print(response.body);
        projects = response.body;
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

    return projects;
  }

  Future<bool?> checkUsserExists() async {
    // checks if a user exists

    final Uri request = Uri.parse(
        "http://127.0.0.1:5000/check/user/exists?email=$email");

    bool userExists;

    try {
      // using http to asynchronously get the information from flask
      final response = await http.get(request);

      if (response.statusCode == 200) {
        // if the response was successful you will get the expected information
        print(response.body);

        // response body is always going to be a string, hence why i have to
        // convert it to type bool
        if (response.body == "True") {
          userExists = true;
        }
        else {
          userExists = false;
        }

        return userExists;
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

    // returns null if there is an issue getting a response from the server
    return null;
  }

  Future<String?> getTheme() async {
    // this function will get the theme given an id


    // if you don't await the method, the type will be Future<String> which will
    // not be possible to compare to a String as they are not of the same type
    String id = await getID();

    if (id == '') {
      print("The user does not exist within the database");
      // return null if the user does not exist!
      return null;
    }
    else {
      final Uri request = Uri.parse(
          "http://127.0.0.1:5000/get/user/theme?user_id=$id");

      String? userTheme;

      try {
        final response = await http.get(request);

        if (response.statusCode == 200) {
          print(response.body);
          userTheme = response.body;
        }
        else {
          print(response.statusCode);
        }
      }
      catch (e) {
        print(e);
      }

      return userTheme;
    }
  }

  Future<void> changeTheme() async {
    // this function will change the attribute of the theme if a stored value
    // exists within the database

    String? userTheme = await getTheme();
    if (userTheme != null) {
      userTheme = userTheme;
    }
  }

  Future<String?> getPassword() async {
    // will get the password of a user with the associated ID
    print("UserId: $usserID");
    if (usserID == '') {
      // the user does not exist in the database so there is no password to
      // retrieve
      return null;
    }
    else {
      final Uri request = Uri.parse(
          "http://127.0.0.1:5000/get/user/password?user_id=$usserID");
      try {
        final response = await http.get(request);
        print("getPasswordStatus: ${response.statusCode}");

        if (response.statusCode == 200) {
          return response.body;
        }
      }
      catch (e) {
        print(e);
      }
    }
    return null;
  }

  Future<bool?> passwordCorrect() async {
    // function will compare the user's password to the password stored within the
    // database. Returns true if the password is correct, false if the password
    // is incorrect and null if the password is incorrect

    String? databasePassword = await getPassword();

    print("Datebase Password:$databasePassword");
    // will return null if there is no database password
    if (databasePassword == null) {
      return null;
    }
    else {
      return (usserPassword == databasePassword) ? true : false;
    }
  }

  Future<void> updateUsername() async {
    // this function will return the username of the user given their email
    // and updates the object's usserName

    final Uri request = Uri.parse("http://127.0.0.1:5000/get/username?email=$email");

    print(email);

    try {
      final response = await http.get(request);

      if (response.statusCode == 200) { usserName = response.body; }
      else { print(response.statusCode); }
    }
    catch (e) { print('in exception'); print(e); }
  }
}