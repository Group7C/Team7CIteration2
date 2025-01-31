import "package:flutter/material.dart";
import "login.dart";
import 'validation.dart';

final username = TextEditingController();
final password = TextEditingController();
final email = TextEditingController();

// creating a function that returns a Input Box
TextFormField createInputField(TextEditingController controller, String hintMessage, int maxInputLength, Function validatorFunction) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      hintText: hintMessage,
    ),
    maxLength: maxInputLength,
    validator: (value) {
      return validatorFunction(value);
    },
    style: const TextStyle(color: Colors.white70),
  );
}

// this handles the ui for the username
Container usernameContainer() {
  return Container(
    child: Column(
      children: [
        const SizedBox(height: 50,),
        Text("Username", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.grey[300])),
        SizedBox(
            width: 200,
            child: createInputField(username, "Enter your username", 10, usernameInputValidator)
        ),

      ],
    ),
  );
}

// this handles the ui for the email
Container emailContainer() {
  return Container(
    child: Column(
      children: [
        const SizedBox(height: 50,),
        Text("Email", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.grey[300])),
        SizedBox(
            width: 200,
            child: createInputField(email, "Enter your email", 10, emailInputValidator)
        ),
      ],
    ),
  );
}

Container passwordContainer() {
  return Container(
    child: Column(
      children: [
        Text("Password", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.grey[300])),
        const SizedBox(height: 50),
        SizedBox(
            width: 200,
            child: createInputField(password, "Enter Password", 10, passwordInputValidator)
        ),
      ],
    ),
  );
}