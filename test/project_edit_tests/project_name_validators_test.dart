import 'package:flutter_test/flutter_test.dart';
import '../../lib/projects/validation/edit_project_validation.dart';

void main() {

    // this is testing the Project name form field inside the project edit screen!

  group("Testing Project name form field validator", () {


    test("When there are 0 characters as a string", () {
      expect(projectNameFieldValidation(""), "Project name must not be empty");
    });

    test("When there are 0 characters as a null value", () {
      expect(projectNameFieldValidation(null), "Project name must not be empty");
    });

    test("When there are 51 characters", () {
      expect(projectNameFieldValidation("a" * 51), "Project name must be 50 or less characters");
    });

    test("When there are 8 characters", () {
      expect(projectNameFieldValidation("football"), isNull);
    });

  });
}
