import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/tasks_provider.dart';
import '../../../models/task/task.dart'; // Updated import path to new Task model
import '../utilities/date_picker_field.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../usser/usserObject.dart';
import '../../../common/enums/notification_frequency.dart';

// Task creation modal dialog [full-screen form for adding tasks to projects]
class AddTaskModal extends StatefulWidget {
  final String projectName;
  final String? projectId;
  final List<String> projectMembers;
  final Function(Task)? onTaskAdded;

  const AddTaskModal({
    Key? key,
    required this.projectName,
    this.projectId,
    required this.projectMembers,
    this.onTaskAdded,
  }) : super(key: key);

  @override
  State<AddTaskModal> createState() => _AddTaskModalState();
}

class _AddTaskModalState extends State<AddTaskModal> {
  // Controllers for form fields [handle text input]
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController tagController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController percentageWeightingController = TextEditingController();
  final TextEditingController priorityController = TextEditingController();
  
  // Focus nodes for keyboard navigation [improves form UX]
  final FocusNode titleFocusNode = FocusNode();
  final FocusNode descriptionFocusNode = FocusNode();
  final FocusNode endDateFocusNode = FocusNode();
  final FocusNode tagFocusNode = FocusNode();
  final FocusNode percentageFocusNode = FocusNode();
  final FocusNode priorityFocusNode = FocusNode();
  
  // Form state tracking [manages validation and submission]
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List<String> tags = [];
  Map<String, String> taskMembers = {};
  bool notificationPreference = true;
  NotificationFrequency notificationFrequency = NotificationFrequency.daily;
  final ValueNotifier<NotificationFrequency> notificationFrequencyNotifier = 
      ValueNotifier<NotificationFrequency>(NotificationFrequency.daily);
  
  // Currently selected assignee values [temp storage before adding to list]
  late String _selectedUsername;
  Role _selectedRole = Role.editor;
  
  // Project capacity limit [will come from project settings when DB setup]
  int projectCapacity = 100;

  // Method to get user IDs for usernames - simplified version that won't fail
  Future<List<Map<String, dynamic>>> _getAssigneesWithIds() async {
    final List<Map<String, dynamic>> assignees = [];
    
    print('Task members: ${taskMembers.entries.map((e) => "${e.key}:${e.value}").join(", ")}');
    
    // First, try to look up just one user to use as primary assignee
    if (taskMembers.isNotEmpty) {
      final entry = taskMembers.entries.first;
      final username = entry.key;
      final role = entry.value;
      
      try {
        // Try to get user ID for the first user specifically
        final response = await http.get(
          Uri.parse('http://127.0.0.1:5000/get/user/id?email=$username'),
        );
        
        if (response.statusCode == 200 && response.body != "0") {
          // We found a valid user ID!
          final userId = int.tryParse(response.body.trim()) ?? 0;
          if (userId > 0) {
            print('Found valid user ID for primary assignee: $userId');
            
            // Add all users with the first one having the real ID
            for (final entry in taskMembers.entries) {
              final memberUsername = entry.key;
              final memberRole = entry.value;
              
              if (memberUsername == username) {
                // This is the user we found the ID for
                assignees.add({
                  'user_id': userId,
                  'username': username,
                  'role': role
                });
              } else {
                // Other users will be looked up by username on the server
                assignees.add({
                  'user_id': 0,  
                  'username': memberUsername,
                  'role': memberRole
                });
              }
            }
            
            print('Final assignees list with primary: $assignees');
            return assignees;
          }
        }
      } catch (e) {
        print('Error getting user ID for primary: $e');
      }
    }
    
    // Fallback to current user's ID if we can't get any valid ID
    try {
      final usser = context.read<Usser>();
      if (usser.usserID.isNotEmpty) {
        final userId = int.tryParse(usser.usserID);
        if (userId != null && userId > 0) {
          print('Using current user ID: $userId as primary assignee');
          
          // Add all members with the first one having the current user's ID
          bool addedPrimary = false;
          
          for (final entry in taskMembers.entries) {
            final username = entry.key;
            final role = entry.value;
            
            if (!addedPrimary) {
              // Make the first user have the current user ID
              assignees.add({
                'user_id': userId,
                'username': username,
                'role': role
              });
              addedPrimary = true;
            } else {
              // Other users will be looked up by username
              assignees.add({
                'user_id': 0,
                'username': username,
                'role': role
              });
            }
          }
          
          print('Final assignees list with current user: $assignees');
          return assignees;
        }
      }
    } catch (e) {
      print('Error using current user ID: $e');
    }
    
    // If all else fails, just add all users by username
    for (final entry in taskMembers.entries) {
      final username = entry.key;
      final role = entry.value;
      
      assignees.add({
        'user_id': null,  // Use NULL instead of 0
        'username': username,
        'role': role
      });
    }
    
    print('Final assignees list with nulls: $assignees');
    return assignees;
  }
  
  @override
  void initState() {
    super.initState();
    // Set default selected member to first in the list or a placeholder
    _selectedUsername = widget.projectMembers.isNotEmpty 
        ? widget.projectMembers.first 
        : "No members";
    
    // Default task member assignment
    if (widget.projectMembers.isNotEmpty) {
      taskMembers = {widget.projectMembers.first: _selectedRole.name};
    }
  }
  
  @override
  void dispose() {
    // Clean up controllers and focus nodes
    titleController.dispose();
    descriptionController.dispose();
    tagController.dispose();
    percentageWeightingController.dispose();
    priorityController.dispose();
    endDateController.dispose();
    
    titleFocusNode.dispose();
    descriptionFocusNode.dispose();
    tagFocusNode.dispose();
    percentageFocusNode.dispose();
    priorityFocusNode.dispose();
    endDateFocusNode.dispose();
    
    notificationFrequencyNotifier.dispose();
    
    super.dispose();
  }

  // Resets all form fields to initial state
  void clearForm() {
    setState(() {
      titleController.clear();
      descriptionController.clear();
      tagController.clear();
      percentageWeightingController.clear();
      priorityController.clear();
      endDateController.clear();
      tags = [];
      taskMembers.clear();
      notificationPreference = true;
      formKey.currentState?.reset();
    });
  }

  // Validates and creates new task object [sends to provider and DB]
  void submitTask() async {
    if (formKey.currentState!.validate()) {
      try {
        // Get assignees with their user IDs
        final assignees = await _getAssigneesWithIds();
        
        // If no assignees were found, add the current user as fallback
        if (assignees.isEmpty) {
          final usser = context.read<Usser>();
          if (usser.usserID.isEmpty) {
            await usser.getID();
          }
          
          int userId = 0;
          try {
            userId = int.parse(usser.usserID);
          } catch (e) {
            print('Error parsing current user ID: $e');
          }
          
          print('No assignees found - adding current user as fallback');
          assignees.add({
            'user_id': userId,
            'username': usser.usserName ?? 'Current User',
            'role': 'Editor'
          });
        }
        
        // Get primary assignee (first in list or current user)
        String assigneeId = assignees.isNotEmpty ? assignees.first['user_id'].toString() : '0';
        String assigneeName = assignees.isNotEmpty ? assignees.first['username'].toString() : 'Unassigned';

        // Format the due date in ISO format
        DateTime? parsedDate;
        try {
          if (endDateController.text.isNotEmpty) {
            // Assuming the date is in dd/MM/yyyy format from DatePickerField
            final parts = endDateController.text.split('/');
            if (parts.length == 3) {
              parsedDate = DateTime(
                int.parse(parts[2]), // year
                int.parse(parts[1]), // month
                int.parse(parts[0]), // day
              );
            }
          }
        } catch (e) {
          print('Date parsing error: $e');
        }
        
        final dueDateString = parsedDate?.toIso8601String() ?? DateTime.now().toIso8601String();

        // Update request data structure
        final requestData = {
          'title': titleController.text,
          'description': descriptionController.text,
          'due_date': dueDateString,
          'assignees': assignees,
          'priority': int.tryParse(priorityController.text) ?? 1,
          'percentage_weighting': double.tryParse(percentageWeightingController.text) ?? 0.0,
          'notification_frequency': notificationFrequencyNotifier.value.name.toLowerCase(),
        };
        
        // Only add assignee_id if we have a valid one
        if (assignees.isNotEmpty && assignees.first['user_id'] != null && assignees.first['user_id'] != 0) {
          requestData['assignee_id'] = assignees.first['user_id'];
        }
        
        print('Sending request with data: ${json.encode(requestData)}');
        print('Using endpoint: http://127.0.0.1:5000/project/${widget.projectId}/tasks');

        // Call the API to create the task using the correct endpoint format
        final createResponse = await http.post(
          Uri.parse('http://127.0.0.1:5000/project/${widget.projectId}/tasks'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(requestData),
        );

        print('Response status: ${createResponse.statusCode}');
        print('Response body: ${createResponse.body}');

        if (createResponse.statusCode == 201) {
          final responseData = json.decode(createResponse.body);
          
          // Create Task object for local state management
          Task newTask = Task(
            title: titleController.text,
            parentProject: widget.projectName,
            percentageWeighting: double.tryParse(percentageWeightingController.text) ?? 0.0,
            listOfTags: tags,
            priority: int.tryParse(priorityController.text) ?? 1,
            startDate: DateTime.now(),
            endDate: parsedDate ?? DateTime.now(),
            description: descriptionController.text,
            members: Map.from(taskMembers),
            notificationPreference: notificationPreference,
            notificationFrequency: notificationFrequencyNotifier.value,
            directoryPath: "path/to/directory",
          );

          // Add to the provider for local state
          Provider.of<TaskProvider>(context, listen: false).addTask(newTask);
          
          // Call the callback if provided
          if (widget.onTaskAdded != null) {
            widget.onTaskAdded!(newTask);
          }
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Clear the form and close the modal
          clearForm();
          Navigator.of(context).pop();
        } else {
          throw Exception('Failed to create task: ${createResponse.body}');
        }
      } catch (e, stackTrace) {
        print('Error creating task: $e');
        print('Stack trace: $stackTrace');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating task: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    
    return Container(
      height: size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Add Task to ${widget.projectName}',
                style: theme.textTheme.headlineSmall,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const Divider(),
          // Form
          Expanded(
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Two column layout for larger screens
                    if (size.width > 600)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left column
                          Expanded(
                            child: _buildLeftColumn(theme),
                          ),
                          const SizedBox(width: 24),
                          // Right column
                          Expanded(
                            child: _buildRightColumn(theme),
                          ),
                        ],
                      )
                    // Single column layout for smaller screens
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLeftColumn(theme),
                          const SizedBox(height: 16),
                          _buildRightColumn(theme),
                        ],
                      ),
                    
                    // Action buttons
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: clearForm,
                            child: const Text('Clear'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: submitTask,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                            ),
                            child: const Text('Add Task'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Builds left side form fields [title, description, priority, dates]
  Widget _buildLeftColumn(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Title", style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
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
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "Title cannot be empty";
            } else if (value.length > 50) {
              return "Title cannot exceed 50 characters";
            }
            return null;
          },
          onFieldSubmitted: (_) {
            FocusScope.of(context).requestFocus(descriptionFocusNode);
          },
        ),
        
        const SizedBox(height: 16),
        Text("Description", style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
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
          validator: (value) => 
            value == null || value.trim().isEmpty ? "Description cannot be empty" : null,
          onFieldSubmitted: (_) {
            FocusScope.of(context).requestFocus(priorityFocusNode);
          },
        ),
        
        const SizedBox(height: 16),
        Text("Priority Level", style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        DropdownButtonFormField(
          items: ["1", "2", "3", "4", "5"]
              .map((level) => DropdownMenuItem(
                    value: level,
                    child: Text("Priority $level"),
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
        Text("Due Date", style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        DatePickerField(
          controller: endDateController,
          focusNode: endDateFocusNode,
          onDateSelected: (selectedDate) {},
        ),
        
        const SizedBox(height: 16),
        Text("Notification", style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        ValueListenableBuilder<NotificationFrequency>(
          valueListenable: notificationFrequencyNotifier,
          builder: (context, frequency, child) {
            return DropdownButtonFormField<NotificationFrequency>(
              value: frequency,
              items: NotificationFrequency.values.map((frequency) {
                return DropdownMenuItem(
                  value: frequency,
                  child: Text(frequency.name),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  notificationFrequencyNotifier.value = value; 
                }
                if (value == NotificationFrequency.none) {
                  setState(() {
                    notificationPreference = false;
                  });
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
      ],
    );
  }
  
  // Builds right side form fields [weight, tags, assignees]
  Widget _buildRightColumn(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Task's Weight", style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
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
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "Percentage cannot be empty";
            }
            final percentage = int.tryParse(value);
            if (percentage == null || percentage < 1 || percentage > 100) {
              return "Enter a value between 1 and 100";
            }
            if (percentage > projectCapacity) {
              return "Task weight must be less than $projectCapacity";
            }
            return null;
          },
          onFieldSubmitted: (_) {
            FocusScope.of(context).requestFocus(tagFocusNode);
          },
        ),

        const SizedBox(height: 16),
        Text("Tags", style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
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
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: tags.map((tag) => Chip(
            label: Text(tag, style: TextStyle(color: theme.colorScheme.onPrimary)),
            backgroundColor: theme.colorScheme.primary,
            onDeleted: () {
              setState(() {
                tags.remove(tag);
              });
            },
          )).toList(),
        ),
        
        const SizedBox(height: 16),
        Text("Assignee(s)", style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        if (widget.projectMembers.isEmpty)
          const Text("No members available to assign")
        else
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
                  items: widget.projectMembers.map((member) {
                    return DropdownMenuItem<String>(
                      value: member,
                      child: Text(member),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedUsername = value;
                      });
                    }
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
                    if (value != null) {
                      setState(() {
                        _selectedRole = value;
                      });
                    }
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.add, color: theme.colorScheme.primary),
                onPressed: () {
                  setState(() {
                    taskMembers[_selectedUsername] = _selectedRole.name;
                  });
                },
              ),
            ],
          ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: taskMembers.entries.map((entry) {
            return Chip(
              label: Text(
                "${entry.key} (${entry.value})",
                style: TextStyle(color: theme.colorScheme.onPrimary),
              ),
              backgroundColor: theme.colorScheme.primary,
              onDeleted: () {
                setState(() {
                  taskMembers.remove(entry.key);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

// Task member permission levels
enum Role { editor, reader }

// Converts role enum to display text
extension RoleExtension on Role {
  String get name {
    switch (this) {
      case Role.editor:
        return 'Editor';
      case Role.reader:
        return 'Reader';
      default:
        return '';
    }
  }
}
