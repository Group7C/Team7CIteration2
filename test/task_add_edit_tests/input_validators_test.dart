import 'package:flutter_test/flutter_test.dart';
import 'package:sevenc_iteration_two/tasks/validation/add_task_validation.dart';

void main() {
  group("Testing task title validator", () {
    test("When there are 0 characters", () {
      expect(titleValidator("", false), "Title cannot be empty");
    });
    
    test("When title is null", () {
      expect(titleValidator(null, false), "Title cannot be empty");
    });
    
    test("When there are 50 characters", () {
      String fiftyChars = "a" * 50;
      expect(titleValidator(fiftyChars, false), isNull);
    });
    
    test("When there are 51 characters", () {
      String fiftyOneChars = "a" * 51;
      expect(titleValidator(fiftyOneChars, false), "Title cannot exceed 50 characters");
    });

    test("When title already exists", () {
      expect(titleValidator("Existing Task", true), "Choose a different name.");
    });
  });
  
  group("Testing task description validator", () {
    test("When there are 0 characters", () {
      expect(descriptionValidator(""), "Description cannot be empty");
    });
    
    test("When description is null", () {
      expect(descriptionValidator(null), "Description cannot be empty");
    });
    
    test("When there is a valid description", () {
      expect(descriptionValidator("This is a valid description"), isNull);
    });
  });
  
  group("Testing task weight validator", () {
    test("When weight is empty", () {
      var result = taskWeightValidator("", 100);
      expect(result[0], "Percentage cannot be empty");
    });
    
    test("When weight is null", () {
      var result = taskWeightValidator(null, 100);
      expect(result[0], "Percentage cannot be empty");
    });
    
    test("When weight is not a number", () {
      var result = taskWeightValidator("abc", 100);
      expect(result[0], "Enter a value between 1 and 100");
    });
    
    test("When weight is less than 1", () {
      var result = taskWeightValidator("0", 100);
      expect(result[0], "Enter a value between 1 and 100");
    });
    
    test("When weight is greater than 100", () {
      var result = taskWeightValidator("101", 100);
      expect(result[0], "Enter a value between 1 and 100");
    });
    
    test("When weight exceeds project capacity", () {
      var result = taskWeightValidator("60", 50);
      expect(result[0], "Task weight must be less than 50 .");
    });
    
    test("When weight is valid", () {
      var result = taskWeightValidator("40", 100);
      expect(result[0], isNull);
      expect(result[1], 40);
    });
  });
}