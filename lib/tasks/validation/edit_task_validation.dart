// Task validation functions for edit task screen

// Validates the task title
String? taskTitleFieldValidation(String? value, {bool duplicateCheck = false}) {
  if (value == null || value.trim().isEmpty) {
    return "Task title must not be empty";
  }
  else if (value.length > 50) {
    return "Task title must be 50 or less characters";
  }
  if (duplicateCheck) {
    return "A task with this name already exists";
  }
  return null;
}

// Validates the task description
String? taskDescriptionFieldValidation(String? value) {
  if (value == null || value.trim().isEmpty) {
    return "Task description must not be empty";
  }
  else if (value.length > 400) {
    return "Task description must be 400 or less characters";
  }
  return null;
}

// Validates the task weight (percentage)
List<dynamic> taskWeightFieldValidation(String? value, int projectCapacity, int currentTaskWeight) {
  if (value == null || value.trim().isEmpty) {
    return ["Task weight must not be empty", null];
  }
  
  int? percentage = int.tryParse(value);
  if (percentage == null || percentage < 1 || percentage > 100) {
    return ["Task weight must be between 1 and 100", null];
  }
  
  // Only check capacity if the weight is increasing
  if (percentage > currentTaskWeight && (percentage - currentTaskWeight) > projectCapacity) {
    return ["Task weight increase must be less than available capacity ($projectCapacity)", null];
  }
  
  return [null, percentage];
}