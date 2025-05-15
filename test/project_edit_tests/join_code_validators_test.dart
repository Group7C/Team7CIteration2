import 'package:flutter_test/flutter_test.dart';
import '../../lib/projects/validation/edit_project_validation.dart';

void main() {

    // this is testing the join code form field inside the project edit screen!

  group("Testing join code form field validator", () {


    test("When there are 0 characters as a string", () {
      expect(joinCodeFieldValidation(""), "Join code can not be empty");
    });

    test("When there are 0 characters as a null value", () {
      expect(joinCodeFieldValidation(null), "Join code can not be empty");
    });

    test("When there are is 5 characters", () {
      expect(joinCodeFieldValidation("a"), "Join code must be 6 or more characters");
    });

    test("When there is 11 characters", () {
      expect(joinCodeFieldValidation("a" * 11), "Join code must be 10 or less characters");
    });

    test("When there is no symbol (.@!) or digit but there are characters", () {
      expect(joinCodeFieldValidation("values"), "It must contain at least one number or symbol");
    });

    test("When there is between characters 6 and 10, and has a symbol or digit", () {
      expect(joinCodeFieldValidation("values1.@"), isNull);
    });

  });
}


