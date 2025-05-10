import "input_field_containers.dart";
// validates the email input box
String? emailInputValidator(String value) {
  if (value.isEmpty) {
    return "Can not leave this field empty";
  }
  else if (16 > value.length) {
    return "Must be at least 16 characters";
  }
  else if (value.length > 40) {
    return "Must be 40 characters or less";
  }
  return null;
}

// validates the password input box
String? passwordInputValidator(String value) {
  if (value.isEmpty) {
    return "Can not leave this field empty";
  }
  else if (value.length < 8) {
    return "Can not be less than 8 characters";
  }
  else if (value.length > 100) {
    return "Must be 100 characters or less";
  }
  return null;
}

// validates the username input box
String? usernameInputValidator(String value) {
  if (value.isEmpty) {
    return "Can not leave this field empty";
  }
  else if (value.length < 8) {
    return "Must be 8 characters at least";
  }
  else if (value.length > 100) {
    return "Must be 100 characters or less";
  }
  return null;
}


// this function will be responsible for the regex of the email input box
String regexEmail(String name) {
  // will return '0' if acceptable email
  RegExp regex = RegExp(r'^(.*)(@gmail.com)$');
  RegExpMatch? regMatches = regex.firstMatch(name);

  if (regMatches == null) {
    return "Must be a gmail account";
  }
  else {
    String? beforeAtSymbol = regMatches.group(1)!;

    RegExp usernameRegex = RegExp(r'^[A-Za-z0-9.]+$');
    RegExpMatch? userRegMatch = usernameRegex.firstMatch(beforeAtSymbol);
    if (userRegMatch == null) {
      return "Only include letters, number(s) and period(s)";
    }
  }

  return "0";
}

// this function will be responsible for the regex of the username input field
String regexUsername(String name) {
  // will return '0' if acceptable email
  RegExp regex = RegExp(r'^[A-Za-z0-9.]+$');
  RegExpMatch? regMatches = regex.firstMatch(name);

  if (regMatches == null) {
    return "Only include letters, number(s) & period(s)";
  }

  return "0";
}

// this will be responsible for the regex of the password input field
String regexPassword(String name) {
  // will return '0' if acceptable email
  RegExp regex = RegExp(r'^(?=.*[A-Za-z].*)(?=.*\d.*)(?=.*[.@!].*)[A-Za-z0-9.@!]+$');
  RegExpMatch? regMatches = regex.firstMatch(name);

  if (regMatches == null) {
    return "Must include letters, number(s) & special character(s) (., @ or !)";
  }

  return "0";
}