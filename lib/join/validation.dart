// validator function for the group id input field to make sure it meets requirements
// this is the same function for the name input field when creating a group
String? idInputValidator(String value) {
  if (value.isEmpty) {
    return "Can not leave this field empty";
  }
  else if (value.length > 50) {
    return "Must be 50 characters or less";
  }
  return null;
}

// validator function for the password input field to make sure it meets requriements
String? passwordInputValidator(String value) {
  if (value.isEmpty) {
    return "Can not leave this field empty";
  }
  else if (value.length < 6) {
    return "Can not be less than 6 characters";
  }
  else if (value.length > 10) {
    return "Must be 10 characters or less";
  }
  return null;
}