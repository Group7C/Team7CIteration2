
/* 
    this is the validation for the add task screen.
*/ 

String? titleValidator(String? value, bool containsValue) {
    if (value == null || value.trim().isEmpty) {
                        return "Title cannot be empty";
                      } else if (value.length > 50) {
                        return "Title cannot exceed 50 characters";
                      } else if (containsValue) {
                        return "Choose a different name.";}
                      return null;
}


String? descriptionValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
        return "Description cannot be empty";
    } 
    else {
        return null;
    }
}


// this returns a list. The first item in the list is an error message
// if first element is null then theres no error. However, if the first element
// in the list is a string, that will be the error message.

// the second item in the list is the percentage, this is required so if there's 
// no errors, you can decrease the project capacity by the appropriate amount

List<dynamic> taskWeightValidator(String? value, int projectCapacity) {
    if (value == null || value.trim().isEmpty) {
      return ["Percentage cannot be empty", null];
    }
    int? percentage = int.tryParse(value);
    if (percentage == null ||
        percentage < 1 ||
        percentage > 100) {
      return ["Enter a value between 1 and 100", null ];}
    if(percentage > projectCapacity){
      return ["Task weight must be less than $projectCapacity .", null];
    }
    return [null, percentage];
}



// I MUST BE THE GREATEST TO EVER DO IT 
// https://www.youtube.com/watch?v=oeQ5bvU8LRI

// THIS SHOULD BE THE ADD TASK VALIDATION COMPLETE, FINGERS CROSSED...