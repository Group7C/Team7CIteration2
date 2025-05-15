import 'package:flutter_test/flutter_test.dart';
import '../../lib/projects/validation/edit_project_validation.dart';

void main() {
  
    // this is testing the discord link field inside the project edit screen!

  group("Testing discord link form field validator", () {

    test("When there are 0 characters as a string", () {
      expect(discordLinkValidator(""), isNull);
    });

    test("When there are 0 characters as a null value", () {
      expect(discordLinkValidator(null), isNull);
    });

    test("When there are is 5 characters but does not contain discord.gg or discord.com/invite ", () {
      expect(discordLinkValidator("hello"), "Must be a valid Discord invite link\nExamples: www.discord.gg/abc123, discord.com/invite/abc123");
    });

    test("When there are is 201 characters", () {
      expect(discordLinkValidator("a" * 201), "Discord link cannot exceed 200 characters");
    });

    test("When there is discord.gg and the string is less than 200 characters but not empty", () {
      expect(discordLinkValidator("discord.gg/aoisjhdufioahjs"), isNull);
    });
    
    test("When there is discord.com/invite and the string is less than 200 characters but not empty", () {
      expect(discordLinkValidator("discord.com/invite/aoisjhdufioahjs"), isNull);
    });

    test("When there is no discord.gg or discord.com/invite,  and the string is less than 200 characters but not empty", () {
      expect(discordLinkValidator("google-drive.com/invite/aoisjhdufioahjs"), "Must be a valid Discord invite link\nExamples: www.discord.gg/abc123, discord.com/invite/abc123");
    });

  });
}
