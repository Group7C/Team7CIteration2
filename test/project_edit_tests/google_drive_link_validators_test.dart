import 'package:flutter_test/flutter_test.dart';
import '../../lib/projects/validation/edit_project_validation.dart';

void main() {
  
    // this is testing the Google Drive link field inside the project edit screen!

  group("Testing google drive link form field validator", () {

    test("When there are 0 characters as a string", () {
      expect((googleDriveLinkValidator("")), isNull);
    });

    test("When there are 0 characters as a null value", () {
      expect(googleDriveLinkValidator(null), isNull);
    });

    test("When there are is 5 characters but does not contain drive.google.com or docs.google.com", () {
      expect(googleDriveLinkValidator("hello"), "Must be a valid Google Drive link\nExamples: www.drive.google.com/folder/..., https://docs.google.com/...");
    });

    test("When there are is 201 characters", () {
      expect(googleDriveLinkValidator("a" * 201), "Google Drive link cannot exceed 200 characters");
    });

    test("When there is drive.google.com and the string is less than 200 characters but not empty", () {
      expect(googleDriveLinkValidator("drive.google.com/aoisjhdufioahjs"), isNull);
    });
    
    test("When there is docs.google.com and the string is less than 200 characters but not empty", () {
      expect(googleDriveLinkValidator("docs.google.com/invite/aoisjhdufioahjs"), isNull);
    });

    test("When there is no drive.google.com or docs.google.com,  and the string is less than 200 characters but not empty", () {
      expect(googleDriveLinkValidator("discord.com/invite/aoisjhdufioahjs"), "Must be a valid Google Drive link\nExamples: www.drive.google.com/folder/..., https://docs.google.com/...");
    });

  });
}
