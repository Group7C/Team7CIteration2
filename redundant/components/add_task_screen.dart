import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sevenc_iteration_two/Objects/task.dart'; 
import 'package:sevenc_iteration_two/home/components/date_picker_field.dart';



class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tagController = TextEditingController();
  final _titleFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _priorityFocusNode = FocusNode();
  final _endDateFocusNode = FocusNode();
  final _percentageWeightingFocusNode = FocusNode();
  final _tagFocusNode = FocusNode();

  //To create a task retrieve and 
  //change variables of project's name, project's tasks' name list, 
  //project's capacity(remaining percentage), notification preference(enabled/daily)
    final int _projectCapacity = 70;
    final String _userName = "Sofia";
    final List<String> _projectTasks = ["Task1", "Task 2"];
    final String _projectName = "MyProject";
    final bool _projectNotificationPreference = true;
    final _usernameController = TextEditingController();
    final _roleController = TextEditingController();
    final ValueNotifier<List<Map<String, String>>> _membersListNotifier =
      ValueNotifier<List<Map<String, String>>>([]);

  @override
  void dispose() {
    _tagController.dispose();
    _titleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _priorityFocusNode.dispose();
    _endDateFocusNode.dispose();
    _percentageWeightingFocusNode.dispose();
    _tagFocusNode.dispose();
    _roleController.dispose();
    _usernameController.dispose();
    _membersListNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
  
    List<String>  possibleTaskParent = [_projectName, ..._projectTasks]; 
    
    return Scaffold(
      body: ChangeNotifierProvider(
        create: (context) => Task(
          title: '',
          parentProject: _projectName,
          percentageWeighting: 0,
          listOfTags: [],
          priority: 1,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(hours: 1)),
          description: '',
          members: {_userName: "editor"},
          notificationPreference: _projectNotificationPreference,
          notificationFrequency: NotificationFrequency.daily,
          directoryPath: '',
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Consumer<Task>(
              builder: (context, task, _) => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Title", style: theme.textTheme.titleMedium),
                        TextFormField(
                          initialValue: task.title,
                          focusNode: _titleFocusNode,
                          decoration: InputDecoration(
                            hintText: "Enter task title",
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          style: TextStyle(color: theme.colorScheme.onSurface),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Title cannot be empty";
                            } else if (value.length > 50) {
                              return "Title cannot exceed 50 characters";
                            }
                            return null;
                          },
                          onChanged: (value) {
                            task.updateTitle(value);
                          },
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_descriptionFocusNode);
                          },
                        ),
                        const SizedBox(height: 16),
                        Text("Description", style: theme.textTheme.titleMedium),
                        TextFormField(
                          initialValue: task.description,
                          focusNode: _descriptionFocusNode,
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
                          validator: (value) => value == null || value.trim().isEmpty
                              ? "Description cannot be empty"
                              : null,
                          onChanged: (value) => task.updateDescription(value),
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_priorityFocusNode);
                          },
                        ),
                        const SizedBox(height: 16),
                        Text("Priority Level", style: theme.textTheme.titleMedium),
                        DropdownButtonFormField(
                          value: task.priority.toString(),
                          items: ["1", "2", "3", "4", "5"]
                              .map((level) => DropdownMenuItem(
                            value: level,
                            child: Text("Priority $level",
                                style: TextStyle(
                                    color: theme.colorScheme.onSurface)),
                          ))
                              .toList(),
                          onChanged: (value) {
                            task.updatePriority(int.parse(value ?? "1"));
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
                          initialDate: task.endDate,
                          onDateSelected: (selectedDate) {
                            task.updateEndDate(selectedDate);
                          },
                        ),
                        const SizedBox(height: 16),
                        Text("Notification", style: theme.textTheme.titleMedium),
                        DropdownButtonFormField<NotificationFrequency>(
                          value: task.notificationFrequency,
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
                              task.updateNotificationFrequency(value);
                            }
                            if (value == NotificationFrequency.none) {
                              task.updateNotificationPreference(false);
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
                          value: _projectName,
                          items: possibleTaskParent 
                              .map((parent) {
                            return DropdownMenuItem(
                              value: parent,
                              child: Text(
                                parent,
                                style: TextStyle(color: theme.colorScheme.onSurface),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            task.parentProject = value;
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
                          initialValue: task.percentageWeighting.toString(),
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
                            if (value == null || value.trim().isEmpty) {
                              return "Percentage cannot be empty";
                            }
                            final percentage = int.tryParse(value);
                            if (percentage == null ||
                                percentage < 1 ||
                                percentage > 100) {
                              return "Enter a value between 1 and 100";
                            }
                            if(percentage > _projectCapacity){
                              return "Task weight must be less than $_projectCapacity .";
                            
                            }
                            return null;
                          },
                          onChanged: (value) {
                            final percentage = double.tryParse(value);
                            if (percentage != null) {
                              task.updatePercentageWeighting(percentage);
                            }
                          },
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_tagFocusNode);
                          },
                        ),
                        const SizedBox(height: 16),
                        Text("Tags", style: theme.textTheme.titleMedium),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _tagController,
                                focusNode: _tagFocusNode,
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
                                if (_tagController.text.trim().isNotEmpty) {
                                  task.addOrUpdateTag("", _tagController.text.trim());
                                  _tagController.clear();
                                }
                              },
                            ),
                          ],
                        ),
                        Wrap(
                          children: task.listOfTags
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
                              child: TextFormField(
                                controller: _usernameController,
                                decoration: InputDecoration(
                                  hintText: "Name",
                                  filled: true,
                                  fillColor: theme.colorScheme.surface,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                style: TextStyle(color: theme.colorScheme.onSurface),                                
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _roleController,
                                decoration: InputDecoration(
                                  hintText: "Role",
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
                                if (_usernameController.text.trim().isNotEmpty &&
                                    _roleController.text.trim().isNotEmpty) {
                                  _membersListNotifier.value =
                                      List.from(_membersListNotifier.value)
                                        ..add({
                                          'username': _usernameController.text.trim(),
                                          'role': _roleController.text.trim(),
                                        });
                                  _usernameController.clear();
                                  _roleController.clear();
                                }
                              },
                            ),
                          ],
                        ),
                        ValueListenableBuilder<List<Map<String, String>>>(
                          valueListenable: _membersListNotifier,
                          builder: (context, membersList, child) {
                            return Wrap(
                              children: membersList.map((member) {
                                return Chip(
                                  label: Text(
                                    "${member['username']} (${member['role']})",
                                    style: TextStyle(color: theme.colorScheme.onPrimary),
                                  ),
                                  backgroundColor: theme.colorScheme.primary,
                                  onDeleted: () {
                                    _membersListNotifier.value =
                                        List.from(_membersListNotifier.value)
                                          ..remove(member);
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
                              onPressed: () {                               
                                                            
                                _usernameController.clear();
                                _roleController.clear();
                                _formKey.currentState?.reset();
                                _tagController.clear();
                                _membersListNotifier.value.clear();
                                Provider.of<Task>(context, listen: false).setTask();
                                
                              },
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
                                if (_formKey.currentState!.validate()) {
                                  // TODO: Implement submit task logic
                                  print("Submitting task: ${task.title}");
                                  // You can access all the task details here:
                                  print("Description: ${task.description}");
                                  print("Priority: ${task.priority}");
                                  print("End Date: ${task.endDate}");
                                  print("Percentage Weighting: ${task.percentageWeighting}");
                                  print("Tags: ${task.listOfTags}");
                                  print("Parent Project: ${task.parentProject}");
                                  print("Notification Frequency: ${task.notificationFrequency}");
                                  ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          "Task '${task.title}' created successfully!")),
                                );
                                
                                }
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
          ),
        ),
      ),
    );
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
}
