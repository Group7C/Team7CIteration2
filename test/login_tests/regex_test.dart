import 'package:flutter_test/flutter_test.dart';
import 'package:sevenc_iteration_two/login/validation.dart';


void main() {

  group("testing the email field", () {

    test("when theres a valid gmail account and prior to @ is also fine", () {
      expect(regexEmail("up2247643@gmail.com"), "0");
    });

    test("When the email is not a gmail account but prior to @ is fine", () {
      expect(regexEmail("up2247643@hotmail.co.uk"), "Must be a gmail account");
    });

    test("when the email is a gmail account but prior to @ is not fine ", () {
      expect(regexEmail("12 hi@gmail.com"), "Only include letters, number(s) and period(s)");
    });

    test("when the email is not a gmail account and prior to @ is not fine ", () {
      expect(regexEmail("this isn't a gmail"), "Must be a gmail account");
    });

  });

  group("testing the username field", () {

    test("When theres a valid username including letters, period and numbers", () {
      expect(regexUsername("Jibrail.A23"), "0");
    });

    test("when theres a valid username using only numbers", () {
      expect(regexUsername("98147456"), "0");
    });

    test("when theres a valid username using periods", () {
      expect(regexUsername("........"), "0");
    });

    test("when the username contains a special character", () {
      expect(regexUsername("JibrailA@"), "Only include letters, number(s) & period(s)");
    });

    test("when the username contains a whitespace", () {
      expect(regexUsername("Jibrail A"), "Only include letters, number(s) & period(s)");
    });

  });

  group("testing the password field", () {

    test("valid password with letters, numbers and a special character", () {
      expect(regexPassword("jib12398!"), "0");
    });

    test("Invalid password with just letters", () {
      expect(regexPassword("thisisapassword"), "Must include letters, number(s) & special character(s) (., @ or !)");
    });

    test("Invalid password with just numbers", () {
      expect(regexPassword("187239871"), "Must include letters, number(s) & special character(s) (., @ or !)");
    });

    test("Invalid password with just special characters", () {
      expect(regexPassword("!!!.@@"), "Must include letters, number(s) & special character(s) (., @ or !)");
    });

    test("Invalid password with no letters, numbers or special characters", () {
      expect(regexPassword("   "), "Must include letters, number(s) & special character(s) (., @ or !)");
    });

    test("invalid password with just letters and numbers", () {
      expect(regexPassword("thisisjib123"), "Must include letters, number(s) & special character(s) (., @ or !)");
    });

    test("invalid password with just letters and special characters", () {
      expect(regexPassword("thisisjib!!!!"), "Must include letters, number(s) & special character(s) (., @ or !)");
    });

    test("invalid password with just numbers and special characters", () {
      expect(regexPassword("71289371!!!"), "Must include letters, number(s) & special character(s) (., @ or !)");
    });

  });
}


