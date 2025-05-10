import 'package:flutter_test/flutter_test.dart';
import 'package:sevenc_iteration_two/projects/validation/add_project_validation.dart';

void main() {
  
  String empty = "";
  String tenChars = "abcdefghij";
  String twentyChars = tenChars + tenChars;
  String twentyOneChars = twentyChars + "x";
  String elevenChars = tenChars + "x";
  
  // testing length of input fields on add project screen

  
  group("Testing project name input validator", () {
    
    test("When there are 0 characters", () {
      expect(projectNameValidator(empty), "Project name cannot be empty");
    });
    
    test("When there are 20 characters", () {
      expect(projectNameValidator(twentyChars), isNull);
    });
    
    test("When there are 21 characters", () {
      expect(projectNameValidator(twentyOneChars), "Project name cannot exceed 20 characters");
    });
    
    test("When there are 10 characters", () {
      expect(projectNameValidator(tenChars), isNull);
    });
    
  });
  
  group("Testing join code input validator", () {
    
    test("When there are 0 characters", () {
      expect(joinCodeValidator(empty), "Join code cannot be empty");
    });
    
    test("When there are 10 characters", () {
      expect(joinCodeValidator(tenChars), isNull);
    });
    
    test("When there are 11 characters", () {
      expect(joinCodeValidator(elevenChars), "Join code cannot exceed 10 characters");
    });
    
    test("When there are 5 characters", () {
      expect(joinCodeValidator("abcde"), isNull);
    });
    
  });
  
  group("Testing deadline input validator", () {
    
    test("When there are 0 characters", () {
      expect(deadlineValidator(empty), "Deadline cannot be empty");
    });
    
    test("When date is invalid format", () {
      expect(deadlineValidator("not-a-date"), "Invalid date format");
    });
    
    // test for past date - need to use specific format to match parser
    test("When date is in past", () {
      expect(deadlineValidator("2020-01-01"), "Deadline cannot be in the past");
    });
    
    // test for future date - valid case
    test("When date is in future", () {
      // using date 5 years in future to ensure test doesn't fail over time
      final futureDate = DateTime.now().add(Duration(days: 365 * 5));
      final formattedDate = "${futureDate.year}-${futureDate.month.toString().padLeft(2, '0')}-${futureDate.day.toString().padLeft(2, '0')}";
      expect(deadlineValidator(formattedDate), isNull);
    });
    
  });
  
  group("Testing Google Drive link input validator", () {
    
    test("When link is empty", () {
      expect(googleDriveLinkValidator(empty), isNull); // optional field
    });
    
    test("When link is null", () {
      expect(googleDriveLinkValidator(null), isNull); // optional field
    });
    
    test("When link is too long", () {
      String longLink = "https://drive.google.com/" + "a" * 200;
      expect(googleDriveLinkValidator(longLink), "Google Drive link cannot exceed 200 characters");
    });
    
    test("When link doesn't contain Google Drive domain", () {
      expect(googleDriveLinkValidator("https://example.com"), "Must be a valid Google Drive link\nExamples: www.drive.google.com/folder/..., https://docs.google.com/...");
    });
    
    test("When link contains drive.google.com", () {
      expect(googleDriveLinkValidator("https://drive.google.com/folder/123"), isNull);
    });
    
    test("When link contains docs.google.com", () {
      expect(googleDriveLinkValidator("https://docs.google.com/document/123"), isNull);
    });
    
  });
  
  group("Testing Discord link input validator", () {
    
    test("When link is empty", () {
      expect(discordLinkValidator(empty), isNull); // optional field
    });
    
    test("When link is null", () {
      expect(discordLinkValidator(null), isNull); // optional field
    });
    
    test("When link is too long", () {
      String longLink = "https://discord.gg/" + "a" * 200;
      expect(discordLinkValidator(longLink), "Discord link cannot exceed 200 characters");
    });
    
    test("When link doesn't contain Discord domain", () {
      expect(discordLinkValidator("https://example.com"), "Must be a valid Discord invite link\nExamples: www.discord.gg/abc123, discord.com/invite/abc123");
    });
    
    test("When link contains discord.gg", () {
      expect(discordLinkValidator("https://discord.gg/abc123"), isNull);
    });
    
    test("When link contains discord.com/invite", () {
      expect(discordLinkValidator("https://discord.com/invite/abc123"), isNull);
    });
    
  });
  
}
