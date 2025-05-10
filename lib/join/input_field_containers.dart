import 'package:flutter/material.dart';

String? uidErrorText;
String? joinCodeErrorText;

// creating a function that returns a Input Box
TextFormField createInputField(TextEditingController controller, String hintMessage, int maxInputLength, Function validatorFunction, String? _errorText) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      hintText: hintMessage,
    ),
    forceErrorText: _errorText,
    maxLength: maxInputLength,
    validator: (value) {
      return validatorFunction(value);
    },
    style: const TextStyle(color: Colors.white70),
  );
}