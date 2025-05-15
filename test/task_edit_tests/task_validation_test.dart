import 'package:flutter_test/flutter_test.dart';
import 'package:sevenc_iteration_two/tasks/validation/edit_task_validation.dart';

void main() {
  group("Testing task title field validation", () {
    test("When there are 0 characters as a string", () {
      expect(taskTitleFieldValidation(""), "Task title must not be empty");
    });

    test("When there are 0 characters as a null value", () {
      expect(taskTitleFieldValidation(null), "Task title must not be empty");
    });

    test("When there are 51 characters", () {
      expect(taskTitleFieldValidation("a" * 51), "Task title must be 50 or less characters");
    });

    test("When there are 50 characters", () {
      expect(taskTitleFieldValidation("a" * 50), isNull);
    });
    
    test("When a task with same name exists", () {
      expect(taskTitleFieldValidation("Task Name", duplicateCheck: true), "A task with this name already exists");
    });
  });
  
  group("Testing task description field validation", () {
    test("When there are 0 characters as a string", () {
      expect(taskDescriptionFieldValidation(""), "Task description must not be empty");
    });

    test("When there are 0 characters as a null value", () {
      expect(taskDescriptionFieldValidation(null), "Task description must not be empty");
    });

    test("When there are 401 characters", () {
      expect(taskDescriptionFieldValidation("a" * 401), "Task description must be 400 or less characters");
    });

    test("When there are 400 characters", () {
      expect(taskDescriptionFieldValidation("a" * 400), isNull);
    });
  });
  
  group("Testing task weight field validation", () {
    test("When weight is empty", () {
      var result = taskWeightFieldValidation("", 50, 30);
      expect(result[0], "Task weight must not be empty");
    });
    
    test("When weight is null", () {
      var result = taskWeightFieldValidation(null, 50, 30);
      expect(result[0], "Task weight must not be empty");
    });
    
    test("When weight is not a number", () {
      var result = taskWeightFieldValidation("abc", 50, 30);
      expect(result[0], "Task weight must be between 1 and 100");
    });
    
    test("When weight is less than 1", () {
      var result = taskWeightFieldValidation("0", 50, 30);
      expect(result[0], "Task weight must be between 1 and 100");
    });
    
    test("When weight is greater than 100", () {
      var result = taskWeightFieldValidation("101", 50, 30);
      expect(result[0], "Task weight must be between 1 and 100");
    });
    
    test("When weight increase exceeds available capacity", () {
      // Current weight is 30, new weight is 90, which is an increase of 60
      // But available capacity is only 50
      var result = taskWeightFieldValidation("90", 50, 30);
      expect(result[0], "Task weight increase must be less than available capacity (50)");
    });
    
    test("When weight is decreased", () {
      // Current weight is 50, new weight is 30, which is a decrease - should always be allowed
      var result = taskWeightFieldValidation("30", 20, 50);
      expect(result[0], isNull);
      expect(result[1], 30);
    });
    
    test("When weight increase is within capacity", () {
      // Current weight is 30, new weight is 70, increase of 40 is within capacity of 50
      var result = taskWeightFieldValidation("70", 50, 30);
      expect(result[0], isNull);
      expect(result[1], 70);
    });
  });
}