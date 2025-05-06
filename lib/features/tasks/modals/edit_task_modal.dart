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
import '../../../features/kanban/board/models/kanban_task.dart';

// Task editing modal dialog [full-screen form for editing existing tasks]
class EditTaskModal extends StatefulWidget {
  final KanbanTask task; // The task to edit
  final String projectName;
  final String? projectId;
  final List<String> projectMembers;
  final Function(KanbanTask)? onTaskUpdated;

  const EditTaskModal({
    Key? key,
    required this.task,
    required this.projectName,
    this.projectId,
    required this.projectMembers,
    this.onTaskUpdated,
  }) : super(key: key);

  @override
  State<EditTaskModal> createState() => _EditTaskModalState();
}

class _EditTaskModalState extends State<EditTaskModal> {
  // Controllers for form fields [handle text input]
  late TextEditingController endDateController;
  late TextEditingController tagController;
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController percentageWeightingController;
  late TextEditingController priorityController;
  
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
  late NotificationFrequency notificationFrequency;
  late ValueNotifier<NotificationFrequency> notificationFrequencyNotifier;
  
  // Currently selected assignee values [temp storage before adding to list]
  late String _selectedUsername;
  Role _selectedRole = Role.editor;
  
  // Project capacity limit [will come from project settings when DB setup]
  int projectCapacity = 100;

  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _originalTaskData;
  
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
    
    // Fallback: if we couldn't get a valid ID, use known valid ID from original data
    if (_originalTaskData != null && _originalTaskData!['assignee_id'] != null) {
      final primaryId = _originalTaskData!['assignee_id'];
      if (primaryId != null && primaryId != 0) {
        print('Using original assignee ID: $primaryId as primary assignee');
        
        // Add all members with the first one having the valid primary ID
        bool addedPrimary = false;
        
        for (final entry in taskMembers.entries) {
          final username = entry.key;
          final role = entry.value;
          
          if (!addedPrimary) {
            // Make the first user have the known valid ID
            assignees.add({
              'user_id': primaryId,
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
        
        print('Final assignees list with original primary: $assignees');
        return assignees;
      }
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
    // Initialize controllers with existing task data
    titleController = TextEditingController(text: widget.task.title);
    descriptionController = TextEditingController(text: widget.task.description);
    
    // Try to extract priority from the task ID if possible, otherwise default to "1"
    String priorityValue = "1";
    try {
      // Some task implementations store priority in the ID
      final idParts = widget.task.id.split('_');
      if (idParts.length > 1) {
        final possiblePriority = int.tryParse(idParts.last);
        if (possiblePriority != null && possiblePriority >= 1 && possiblePriority <= 5) {
          priorityValue = possiblePriority.toString();
        }
      }
    } catch (e) {
      print('Error parsing priority from ID: $e');
    }
    
    priorityController = TextEditingController(text: priorityValue);
    endDateController = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(widget.task.dueDate)
    );
    tagController = TextEditingController();
    percentageWeightingController = TextEditingController(text: "0"); // Default value
    
    // Initialize notification preferences
    notificationFrequency = NotificationFrequency.daily; // Default
    notificationFrequencyNotifier = ValueNotifier<NotificationFrequency>(notificationFrequency);
    
    // Ensure the selected username exists in the project members list
    if (widget.projectMembers.contains(widget.task.assigneeName)) {
      _selectedUsername = widget.task.assigneeName;
    } else if (widget.projectMembers.isNotEmpty) {
      _selectedUsername = widget.projectMembers.first;
    } else {
      // Fallback to a default value
      _selectedUsername = "Unassigned";
    }
    
    // Add the current assignee to the task members
    taskMembers = {_selectedUsername: 'Editor'};
    
    // Fetch the full task details from the API to get any missing fields
    _fetchTaskDetails();
  }
  
  // Fetch all task details to properly populate the form
  Future<void> _fetchTaskDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Fetch complete task details from the API
      final response = await http.get(
        Uri.parse('http://127.0.0.1:5000/project/${widget.projectId}/tasks')
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> allTasks = json.decode(response.body);
        
        // Find our specific task
        final taskData = allTasks.firstWhere(
          (t) => t['id'].toString() == widget.task.id,
          orElse: () => <String, dynamic>{}
        );
        
        if (taskData.isNotEmpty) {
          setState(() {
            _originalTaskData = taskData;
            
            // Update controllers with the full data
            titleController.text = taskData['title'] ?? widget.task.title;
            descriptionController.text = taskData['description'] ?? widget.task.description;
            priorityController.text = (taskData['priority'] ?? 1).toString();
            
            // Handle percentage weighting
            percentageWeightingController.text = 
                (taskData['percentage_weighting'] ?? 0).toString();
            
            // Parse tags if available
            if (taskData['tags'] != null) {
              try {
                if (taskData['tags'] is String) {
                  // Try to parse tags from JSON string
                  final parsed = json.decode(taskData['tags']);
                  if (parsed is List) {
                    tags = List<String>.from(parsed);
                  }
                } else if (taskData['tags'] is List) {
                  tags = List<String>.from(taskData['tags']);
                }
              } catch (e) {
                print('Error parsing tags: $e');
              }
            }
            
            // Parse notification preferences
            final notificationsString = taskData['notification_frequency']?.toString().toLowerCase() ?? 'daily';
            notificationFrequency = _parseNotificationFrequency(notificationsString);
            notificationFrequencyNotifier.value = notificationFrequency;
            
            // Parse members JSON if available
            if (taskData['members'] != null) {
              try {
                if (taskData['members'] is String) {
                  final parsed = json.decode(taskData['members']);
                  if (parsed is Map) {
                    taskMembers = Map<String, String>.from(parsed);
                  }
                } else if (taskData['members'] is Map) {
                  taskMembers = Map<String, String>.from(taskData['members']);
                }
              } catch (e) {
                print('Error parsing members: $e');
              }
            }
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to load task details: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
      print('Error fetching task details: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Parse notification frequency from string
  NotificationFrequency _parseNotificationFrequency(String value) {
    switch (value.toLowerCase()) {
      case 'daily':
        return NotificationFrequency.daily;
      case 'weekly':
        return NotificationFrequency.weekly;
      case 'monthly':
        return NotificationFrequency.monthly;
      case 'none':
        return NotificationFrequency.none;
      default:
        return NotificationFrequency.daily;
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

  // Resets the form to the original task values
  void resetForm() {
    setState(() {
      titleController.text = widget.task.title;
      descriptionController.text = widget.task.description;
      endDateController.text = DateFormat('dd/MM/yyyy').format(widget.task.dueDate);
      priorityController.text = '1'; // Default if no original value
      percentageWeightingController.text = '0'; // Default if no original value
      tags = [];
      taskMembers = {widget.task.assigneeName: 'Editor'};
      notificationFrequency = NotificationFrequency.daily;
      notificationFrequencyNotifier.value = notificationFrequency;
      formKey.currentState?.reset();
    });
    
    // If we have the original data, use it to reset the form
    if (_originalTaskData != null) {
      setState(() {
        titleController.text = _originalTaskData!['title'] ?? widget.task.title;
        descriptionController.text = _originalTaskData!['description'] ?? widget.task.description;
        priorityController.text = (_originalTaskData!['priority'] ?? 1).toString();
        percentageWeightingController.text = 
            (_originalTaskData!['percentage_weighting'] ?? 0).toString();
      });
    }
  }
  
  // Validates and updates the task [sends to provider and DB]
  void updateTask() async {
    if (formKey.currentState!.validate()) {
      // Show loading indicator
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      try {
        // Format the due date in ISO format
        DateTime? parsedDate;
        try {
          if (endDateController.text.isNotEmpty) {
            // Parse the date in dd/MM/yyyy format
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
          parsedDate = widget.task.dueDate; // Fallback to original date
        }
        
        final dueDateString = parsedDate?.toIso8601String() ?? widget.task.dueDate.toIso8601String();
        final int priorityValue = int.tryParse(priorityController.text) ?? 1;
        final double weightingValue = double.tryParse(percentageWeightingController.text) ?? 0.0;

        // Get assignees with their user IDs
        final assignees = await _getAssigneesWithIds();

        // Make sure we have at least one valid assignee - create a fallback if needed
        if (assignees.isEmpty && _originalTaskData != null && _originalTaskData!['assignee_id'] != null) {
          // Use the original assignee_id as fallback
          final originalAssigneeId = int.tryParse(_originalTaskData!['assignee_id'].toString());
          
          if (originalAssigneeId != null) {
            print('No valid assignees found - using original assignee_id: $originalAssigneeId');
            assignees.add({
              'user_id': originalAssigneeId,
              'username': _originalTaskData!['assignee_username'] ?? 'Unknown',
              'role': 'Editor'
            });
          }
        }
        
        // If still no assignees, create a dummy one to prevent crashes
        if (assignees.isEmpty) {
          // Add a fallback assignee to prevent backend issues
          final usser = context.read<Usser>();
          int fallbackId = 0;
          
          try {
            if (usser.usserID.isNotEmpty) {
              fallbackId = int.parse(usser.usserID);
            }
          } catch (e) {
            print('Error parsing current user ID: $e');
          }
          
          print('No assignees - adding fallback assignee with ID: $fallbackId');
          assignees.add({
            'user_id': fallbackId,
            'username': usser.usserName ?? 'Current User',
            'role': 'Editor'
          });
        }

        // Update task data structure
        final updateData = {
          'title': titleController.text,
          'description': descriptionController.text,
          'due_date': dueDateString,
          'assignees': assignees, // All assignees
          'priority': priorityValue,
          'percentage_weighting': weightingValue,
          'notification_frequency': notificationFrequencyNotifier.value.name.toLowerCase(),
          'status': widget.task.status, // Preserve the current status
        };
        
        // Only add assignee_id if we have a valid one
        if (assignees.isNotEmpty && assignees.first['user_id'] != null && assignees.first['user_id'] != 0) {
          updateData['assignee_id'] = assignees.first['user_id'];
        }
        
        print('Updating task with data: ${json.encode(updateData)}');
        
        // Call the API to update the task
        final updateUrl = 'http://127.0.0.1:5000/task/${widget.task.id}';
        print('Using endpoint: $updateUrl');
        
        final updateResponse = await http.put(
          Uri.parse(updateUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(updateData),
        );
        
        print('Response status: ${updateResponse.statusCode}');
        print('Response body: ${updateResponse.body}');
        
        if (updateResponse.statusCode == 200) {
          // Create updated KanbanTask object for local state
          final updatedTask = KanbanTask(
            id: widget.task.id,
            title: titleController.text,
            description: descriptionController.text,
            dueDate: parsedDate ?? widget.task.dueDate,
            status: widget.task.status, // Preserve status
            projectId: widget.task.projectId,
            projectName: widget.task.projectName,
            assigneeId: assignees.isNotEmpty ? assignees.first['user_id'].toString() : widget.task.assigneeId,
            assigneeName: taskMembers.keys.isNotEmpty ? taskMembers.keys.first : widget.task.assigneeName,
            projectColour: widget.task.projectColour,
          );
          
          // Call the callback if provided
          if (widget.onTaskUpdated != null) {
            widget.onTaskUpdated!(updatedTask);
          }
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Close the modal
          Navigator.of(context).pop();
        } else {
          // If updating the task failed, show error
          setState(() {
            _errorMessage = 'Failed to update task: ${updateResponse.body}';
            _isLoading = false;
          });
        }
      } catch (e) {
        // Show error message
        setState(() {
          _errorMessage = 'Error updating task: $e';
          _isLoading = false;
        });
        print('Error updating task: $e');
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
                'Edit Task: ${widget.task.title}',
                style: theme.textTheme.headlineSmall,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const Divider(),
          
          // Loading state
          if (_isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          // Error state
          else if (_errorMessage != null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading task details',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(_errorMessage!),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchTaskDetails,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            )
          // Form
          else
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
                              onPressed: resetForm,
                              child: const Text('Reset'),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: updateTask,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                              ),
                              child: const Text('Save Changes'),
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
          value: priorityController.text,
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
          onDateSelected: (selectedDate) {
            endDateController.text = DateFormat('dd/MM/yyyy').format(selectedDate);
          },
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
                child: Builder(builder: (context) {
                  // Make sure the selected username is in the project members list
                  if (!widget.projectMembers.contains(_selectedUsername) && widget.projectMembers.isNotEmpty) {
                    _selectedUsername = widget.projectMembers.first;
                  }
                  
                  return DropdownButtonFormField<String>(
                    value: widget.projectMembers.contains(_selectedUsername) ? _selectedUsername : null,
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
                  );
                }),
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
