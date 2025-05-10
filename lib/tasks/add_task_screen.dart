import 'package:flutter/material.dart';
import '../Objects/task.dart';
import '../providers/tasks_provider.dart';
import '../shared/components/date_picker_field.dart';
import 'package:provider/provider.dart';
import 'validation/add_task_validation.dart';


class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({Key? key}) : super(key: key);

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  //To create a task retrieve and change variables of project's name, project's tasks' name list, 
  //project's capacity(remaining percentage), notification preference(enabled/daily)
  // Task functionality variables from original home.dart
  int projectCapacity = 78;
  List<Task> tasks = [];
  List<String> projectTasks = ["Task1", "Task 2"];
  String projectName = "MyProject";
  List<String> get possibleTaskParent => [projectName, ...projectTasks]; // dynamically construction when accessing it
  List<String> projectMembers = ['Alice','Bob','Charlie'];
  Map<String, String> taskMember = {};
  String username = "Alice";
  

  final TextEditingController endDateController = TextEditingController();
  final TextEditingController tagController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController percentageWeightingController = TextEditingController();
  final TextEditingController priorityController = TextEditingController();
  
  late String _selectedUsername;
  Role _selectedRole = Role.editor;

  final ValueNotifier<List<Map<String, String>>> _membersListNotifier =
      ValueNotifier([]);

  final notificationFrequencyNotifier = ValueNotifier<NotificationFrequency>(NotificationFrequency.daily);
  late final ValueNotifier<String> taskParentNotifier;
  GlobalKey<FormState>? formKey = GlobalKey<FormState>();
  List<String> tags = [];
  NotificationFrequency notificationFrequency = NotificationFrequency.daily; //retrieve project's value
  bool notificationPreference = true; //retrieve project's value
  // Focus Nodes
  FocusNode titleFocusNode = FocusNode();
  FocusNode descriptionFocusNode = FocusNode();
  FocusNode endDateFocusNode = FocusNode();
  FocusNode tagFocusNode = FocusNode();
  FocusNode percentageFocusNode = FocusNode();
  FocusNode priorityFocusNode = FocusNode();

@override
void initState() {
  super.initState();

  _selectedUsername = username;
  taskMember = {username: _selectedRole.name};
  taskParentNotifier = ValueNotifier<String>(possibleTaskParent.first);
}



  @override
  void dispose() {
    notificationFrequencyNotifier.dispose(); 
    taskParentNotifier.dispose();
    titleFocusNode.dispose();
    descriptionFocusNode.dispose();
    tagFocusNode.dispose();
    percentageFocusNode.dispose();
    priorityFocusNode.dispose();
    endDateController.dispose();
    endDateFocusNode.dispose();
    tagController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    percentageWeightingController.dispose();
    priorityController.dispose();
    _membersListNotifier.dispose();
    super.dispose();
  }

  void clearForm() {
    setState(() {
      formKey = GlobalKey<FormState>();
      titleController.clear();
      descriptionController.clear();
      tagController.clear();
      percentageWeightingController.clear();
      priorityController.clear();
      endDateController.clear();
      tags = [];
      taskMember.clear();
      taskParentNotifier.value = possibleTaskParent.first;
      notificationPreference = true;
      formKey!.currentState?.reset();
      _membersListNotifier.value = [];
      _selectedUsername = username;        
    _selectedRole = Role.editor;  
      FocusScope.of(context).unfocus();
    });
  }

  void submitTask() {
    
    if (formKey!.currentState!.validate()) {
      Task newTask = Task(
        title: titleController.text,
        parentProject: taskParentNotifier.value,
        status: Status.todo,
        percentageWeighting:
        double.tryParse(percentageWeightingController.text) ?? 0.0,
        listOfTags: tags,
        priority: int.tryParse(priorityController.text) ?? 1,
        startDate: DateTime.now(),
        endDate: DateTime.parse(endDateController.text),
        description: descriptionController.text,
        members: Map.from(taskMember),
        notificationPreference: notificationPreference,
        notificationFrequency: notificationFrequencyNotifier.value,
        directoryPath: "path/to/directory",
      );

      Provider.of<TaskProvider>(context, listen: false).addTask(newTask);
      clearForm();
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Task '${newTask.title}' created successfully!")));
    }
  }

  String _formatFrequency(NotificationFrequency frequency) {
    switch (frequency) {
      case NotificationFrequency.daily:
        return "Daily";
      case NotificationFrequency.weekly:
        return "Weekly";
      case NotificationFrequency.monthly:
        return "Monthly";
      case NotificationFrequency.none:
        return "None";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: formKey!,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [            
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Title", style: theme.textTheme.titleMedium),
                  TextFormField(
                    controller: titleController,
                    focusNode: titleFocusNode,
                    decoration: InputDecoration(
                      hintText: "Enter task title",
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    validator: (value) => titleValidator(value, projectTasks.contains(value)),
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(descriptionFocusNode);
                    },
                  ),
                  const SizedBox(height: 16),
                  Text("Description", style: theme.textTheme.titleMedium),
                  TextFormField(
                    controller: descriptionController,
                    focusNode: descriptionFocusNode,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Enter task description",
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    validator: (value) => descriptionValidator(value),
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(priorityFocusNode);
                    },
                  ),
                  const SizedBox(height: 16),
                  Text("Priority Level", style: theme.textTheme.titleMedium),
                  DropdownButtonFormField(
                    items: ["1", "2", "3", "4", "5"]
                        .map((level) => DropdownMenuItem(
                              value: level,
                              child: Text("Priority $level",
                                  style: TextStyle(
                                      color: theme.colorScheme.onSurface)),
                            ))
                        .toList(),
                    onChanged: (value) {
                      priorityController.text = value ?? "1";
                    },
                    decoration: InputDecoration(
                      hintText: "Select priority",
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text("Due Date:", style: theme.textTheme.titleMedium),
                  DatePickerField(
                    controller: endDateController,
                    focusNode: endDateFocusNode,
                    onDateSelected: (selectedDate) {},
                  ),
                  const SizedBox(height: 16),
                  Text("Notification", style: theme.textTheme.titleMedium),                  
                    Expanded(
                      child: ValueListenableBuilder<NotificationFrequency>(
                        valueListenable: notificationFrequencyNotifier,
                        builder: (context, frequency, child) {
                          return DropdownButtonFormField<NotificationFrequency>(
                            items: NotificationFrequency.values.map((frequency) {
                              return DropdownMenuItem(
                                value: frequency,
                                child: Text(
                                  _formatFrequency(frequency),
                                  style: TextStyle(color: theme.colorScheme.onSurface),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                notificationFrequencyNotifier.value = value; 
                              }
                              if(value == NotificationFrequency.none){
                                notificationPreference = false;
                              }
                            },
                            decoration: InputDecoration(
                              hintText: "Select Frequency",
                              filled: true,
                              fillColor: theme.colorScheme.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        },
                      ),
                    ),                   
                ],
              ),
            ),
            const SizedBox(width: 32), 
            // Right Column
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("This belongs to:", style: theme.textTheme.titleMedium),
                  DropdownButtonFormField<String>(
                    value: taskParentNotifier.value, 
                    items: possibleTaskParent.map((parent) {
                      return DropdownMenuItem(
                        value: parent,
                        child: Text(
                          parent,
                          style: TextStyle(color: theme.colorScheme.onSurface),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        taskParentNotifier.value = value; 
                      }
                    },
                    decoration: InputDecoration(
                      hintText: "Select Parent Task",
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),                   
                  const SizedBox(height: 16),
                  Text("Task's Weight", style: theme.textTheme.titleMedium),
                  TextFormField(
                    controller: percentageWeightingController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Weighting Percentage (1-100)",
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    validator: (value) {
                        String? message= taskWeightValidator(value, projectCapacity)[0];
                        int? percentage= taskWeightValidator(value, projectCapacity)[1];
                        if (message == null) {
                          projectCapacity -= percentage!;
                          return null;
                        }
                        return message;
                      },
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(tagFocusNode);
                    },
                  ),

                  const SizedBox(height: 16),
                  Text("Tags", style: theme.textTheme.titleMedium),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: tagController,
                          focusNode: tagFocusNode,
                          decoration: InputDecoration(
                            hintText: "Add a tag",
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          style: TextStyle(color: theme.colorScheme.onSurface),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add, color: theme.colorScheme.primary),
                        onPressed: () {
                          if (tagController.text.trim().isNotEmpty) {
                            setState(() {
                              tags.add(tagController.text.trim());
                            });
                            tagController.clear();
                          }
                        },
                      ),
                    ],
                  ),
                  Wrap(
                    children: tags
                        .map((tag) => Chip(
                              label: Text(tag,
                                  style: TextStyle(
                                      color: theme.colorScheme.onPrimary)),
                              backgroundColor: theme.colorScheme.primary,
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  Text("Assignee(s)", style: theme.textTheme.titleMedium),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedUsername,
                          decoration: InputDecoration(
                            hintText: "Assignee",                            
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          items: projectMembers.map((member) {
                            return DropdownMenuItem<String>(
                              value: member,
                              child: Text(member),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedUsername = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<Role>(
                          value: _selectedRole,
                          decoration: InputDecoration(
                            hintText: "Role",
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          items: Role.values.map((role) {
                            return DropdownMenuItem<Role>(
                              value: role,
                              child: Text(role.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedRole = value!;
                            });
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add, color: theme.colorScheme.primary),
                        onPressed: () {
                          taskMember[_selectedUsername] = _selectedRole.name;
                          
                          _selectedUsername = username;
                          _selectedRole = Role.editor;
                          setState(() {}); 
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ValueListenableBuilder<List<Map<String, String>>>(
                    valueListenable: _membersListNotifier,
                    builder: (context, membersList, child) {
                      return Wrap(
                        spacing: 8,
                         children: taskMember.entries.map((entry) {
                          return Chip(
                            label: Text(
                              "${entry.key} (${entry.value})",
                              style: TextStyle(color: theme.colorScheme.onPrimary),
                            ),
                            backgroundColor: theme.colorScheme.primary,
                              onDeleted: () {
                                taskMember.remove(entry.key);
                                setState(() {}); 
                              },
                            );
                          }).toList(),
                      );
                    },
                  ),
                  const Spacer(),
                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: clearForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                        ),
                        child: Text("Clear",
                            style:
                                TextStyle(color: theme.colorScheme.onPrimary)),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          submitTask();
                          //Update the project remaining capacity all over
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.secondary,
                        ),
                        child: Text("Submit",
                            style: TextStyle(
                                color: theme.colorScheme.onSecondary)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}