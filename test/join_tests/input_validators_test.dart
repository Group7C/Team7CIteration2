import 'package:flutter_test/flutter_test.dart';
import 'package:sevenc_iteration_two/join/validation.dart';

void main() {

  String fiveCharacters = "aaaaa";

  // testing the length of the input fields on the join project screen where
  // null is an acceptable value

  group("Testing group ID & name input validator", () {

    test("When there are 0 characters", () {
      expect(idInputValidator(""), "Can not leave this field empty");
    });

    test("When there are is 5 characters", () {
      expect(idInputValidator(fiveCharacters), isNull);
    });

    test("When there is 55 characters", () {
      expect(idInputValidator(fiveCharacters * 11), "Must be 50 characters or less");
    });

  });

  group("Testing group password input validator", () {


    test("When there are 0 characters", () {
      expect(passwordInputValidator(""), "Can not leave this field empty");
    });


    test("When there is 5 characters", () {
      expect(passwordInputValidator(fiveCharacters), "Can not be less than 6 characters");
    });


    test("When there is 15 characters", () {
      expect(passwordInputValidator(fiveCharacters * 3), "Must be 10 characters or less");
    });


    test("When there is 8 characters", () {
      expect(passwordInputValidator("${fiveCharacters}aaa"), isNull);
    });

  });

}
