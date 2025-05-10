import 'package:sevenc_iteration_two/login/validation.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {

  String empty = "";
  String lessThanEight = "aaa";
  String eightCharacters = "aaaaaaaa";
  String hundredAndFourCharacters = eightCharacters * 13;

  // these tested functions observe the length of the input fields, not including
  // regex (that's handled in the other test)

  // an output of null represents a valid case

  group("Testing email input validator", () {

    test("When there is no input", () {
      expect(emailInputValidator(empty), "Can not leave this field empty");
    });

    test("email less than 16 characters", () {
      expect(emailInputValidator(lessThanEight), "Must be at least 16 characters");
    });

    test("email greater than 40 characters", () {
      expect(emailInputValidator(hundredAndFourCharacters), "Must be 40 characters or less");
    });

    test("valid email length", () {
      expect(emailInputValidator(eightCharacters * 3), isNull);
    });

  });

  group("Testing username input validator", () {

    test("When there is no input", () {
      expect(usernameInputValidator(empty), "Can not leave this field empty");
    });

    test("username is less than 8 characters", () {
      expect(usernameInputValidator(lessThanEight), "Must be 8 characters at least");
    });

    test("username is greater than 100 characters", () {
      expect(usernameInputValidator(hundredAndFourCharacters), "Must be 100 characters or less");
    });

    test("valid username length", () {
      expect(usernameInputValidator(eightCharacters * 3), isNull);
    });

  });

  group("Testing password input validator", () {

    test("When there is no input", () {
      expect(passwordInputValidator(empty), "Can not leave this field empty");
    });

    test("less than 8 character password", () {
      expect(passwordInputValidator(lessThanEight), "Can not be less than 8 characters");
    });

    test("greater than 100 character password", () {
      expect(passwordInputValidator(hundredAndFourCharacters), "Must be 100 characters or less");
    });

    test("valid password length", () {
      expect(passwordInputValidator(eightCharacters * 3), isNull);
    });

  });

}

