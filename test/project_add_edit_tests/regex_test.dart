import 'package:flutter_test/flutter_test.dart';
import 'package:sevenc_iteration_two/projects/validation/add_project_validation.dart';

void main() {
  
  group("testing project name regex validator", () {
    
    test("when name has valid characters (letters, numbers and spaces)", () {
      expect(regexProjectName("Project 123"), "0");
    });
    
    test("when name has only letters", () {
      expect(regexProjectName("ProjectName"), "0");
    });
    
    test("when name has only numbers", () {
      expect(regexProjectName("123456"), "0");
    });
    
    test("when name has only spaces", () {
      expect(regexProjectName("   "), "0");
    });
    
    test("when name has special characters", () {
      expect(regexProjectName("Project-123"), "Only include letters, numbers, and spaces");
    });
    
    test("when name has emojis", () {
      expect(regexProjectName("Project 😊"), "Only include letters, numbers, and spaces");
    });
    
    test("when name has underscores", () {
      expect(regexProjectName("Project_123"), "Only include letters, numbers, and spaces");
    });
    
  });
  
  group("testing join code regex validator", () {
    
    test("when code has valid characters (letters and numbers)", () {
      expect(regexJoinCode("Code123"), "0");
    });
    
    test("when code has only letters", () {
      expect(regexJoinCode("CodeOnly"), "0");
    });
    
    test("when code has only numbers", () {
      expect(regexJoinCode("123456"), "0");
    });
    
    test("when code has spaces", () {
      expect(regexJoinCode("Code 123"), "Only include letters and numbers");
    });
    
    test("when code has special characters", () {
      expect(regexJoinCode("Code-123"), "Only include letters and numbers");
    });
    
    test("when code has underscores", () {
      expect(regexJoinCode("Code_123"), "Only include letters and numbers");
    });
    
    test("when code has emojis", () {
      expect(regexJoinCode("Code😊"), "Only include letters and numbers");
    });
    
  });
  
}
