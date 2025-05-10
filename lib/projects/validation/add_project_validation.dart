// Project validation functions for add project screen

// Validates the project name input
String? projectNameValidator(String value) {
  if (value.isEmpty) {
    return "Project name cannot be empty";
  }
  else if (value.length > 20) {
    return "Project name cannot exceed 20 characters";
  }
  return null;
}

// Validates the join code input
String? joinCodeValidator(String value) {
  if (value.isEmpty) {
    return "Join code cannot be empty";
  }
  else if (value.length > 10) {
    return "Join code cannot exceed 10 characters";
  }
  return null;
}

// Validates the deadline input
String? deadlineValidator(String value) {
  if (value.isEmpty) {
    return "Deadline cannot be empty";
  }
  
  try {
    final date = DateTime.parse(value);
    final now = DateTime.now();
    
    if (date.isBefore(now)) {
      return "Deadline cannot be in the past";
    }
  } catch (e) {
    return "Invalid date format";
  }
  
  return null;
}

// Validates the Google Drive link input (optional)
String? googleDriveLinkValidator(String? value) {
  if (value != null && value.isNotEmpty) {
    if (value.length > 200) {
      return "Google Drive link cannot exceed 200 characters";
    }
    
    // More flexible URL validation
    if (!value.contains('drive.google.com') && 
        !value.contains('docs.google.com')) {
      return "Must be a valid Google Drive link\nExamples: www.drive.google.com/folder/..., https://docs.google.com/...";
    }
  }
  return null;
}

// Validates the Discord link input (optional)
String? discordLinkValidator(String? value) {
  if (value != null && value.isNotEmpty) {
    if (value.length > 200) {
      return "Discord link cannot exceed 200 characters";
    }
    
    // More flexible URL validation
    if (!value.contains('discord.gg') && 
        !value.contains('discord.com/invite')) {
      return "Must be a valid Discord invite link\nExamples: www.discord.gg/abc123, discord.com/invite/abc123";
    }
  }
  return null;
}

// Regex for project name (alphanumeric characters and spaces)
String regexProjectName(String name) {
  RegExp regex = RegExp(r'^[A-Za-z0-9 ]+$');
  RegExpMatch? regMatches = regex.firstMatch(name);

  if (regMatches == null) {
    return "Only include letters, numbers, and spaces";
  }

  return "0"; // "0" indicates success
}

// Regex for join code (alphanumeric characters only)
String regexJoinCode(String code) {
  RegExp regex = RegExp(r'^[A-Za-z0-9]+$');
  RegExpMatch? regMatches = regex.firstMatch(code);

  if (regMatches == null) {
    return "Only include letters and numbers";
  }

  return "0"; // "0" indicates success
}
