import 'package:flutter/material.dart';
import '../controllers/task_edit_controller.dart';
import '../controllers/task_form_controller.dart'; // Import for NotificationFrequency enum
import '../widgets/date_picker_field.dart';
import '../../../features/common/models/project_model.dart';
import '../../../features/common/models/task_model.dart';

class TaskEditWidget extends StatefulWidget {
  final Task task;
  final int projectId;
  final List<ProjectMember> members;
  final VoidCallback? onTaskUpdated;
  
  const TaskEditWidget({
    Key? key,
    required this.task,
    required this.projectId,
    required this.members,
    this.onTaskUpdated,
  }) : super(key: key);

  @override
  State<TaskEditWidget> createState() => _TaskEditWidgetState();
}

class _TaskEditWidgetState extends State<TaskEditWidget> {
  late final TaskEditController _controller;
  int? _selectedMemberId;
  String _selectedRole = 'Editor';
  
  @override
  void initState() {
    super.initState();
    // Initialize with existing task data
    _controller = TaskEditController(widget.task);
    
    // Set initial selected member if available
    if (widget.members.isNotEmpty) {
      _selectedMemberId = widget.members.first.membersId;
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Form(
      key: _controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Two column layout
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title field
                    Text("Title", style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _controller.titleController,
                      focusNode: _controller.titleFocusNode,
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
                        FocusScope.of(context).requestFocus(_controller.descriptionFocusNode);
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Description field
                    Text("Description", style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _controller.descriptionController,
                      focusNode: _controller.descriptionFocusNode,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Enter task description",
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) => value == null || value.trim().isEmpty
                          ? "Description cannot be empty"
                          : null,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_controller.priorityFocusNode);
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Priority field
                    Text("Priority Level", style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    DropdownButtonFormField(
                      value: _controller.priorityController.text,
                      items: ["1", "2", "3", "4", "5"]
                          .map((level) => DropdownMenuItem(
                                value: level,
                                child: Text("Priority $level"),
                              ))
                          .toList(),
                      onChanged: (value) {
                        _controller.priorityController.text = value ?? "1";
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
                    
                    // Due date field
                    Text("Due Date", style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    DatePickerField(
                      controller: _controller.endDateController,
                      focusNode: _controller.dateFocusNode,
                      onDateSelected: (selectedDate) {},
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Notification frequency
                    Text("Notification Frequency", style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<NotificationFrequency>(
                      value: _controller.notificationFrequency,
                      items: NotificationFrequency.values.map((frequency) {
                        return DropdownMenuItem<NotificationFrequency>(
                          value: frequency,
                          child: Text(
                            frequency == NotificationFrequency.daily
                                ? "Daily"
                                : "Weekly",
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _controller.notificationFrequency = value;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        hintText: "Select frequency",
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
              
              const SizedBox(width: 24),
              
              // Right column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Task weight
                    Text("Task Weight", style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _controller.weightingController,
                      focusNode: _controller.weightingFocusNode,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "Enter percentage (1-100)",
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Weight percentage is required";
                        }
                        
                        final weightValue = int.tryParse(value);
                        if (weightValue == null || weightValue < 1 || weightValue > 100) {
                          return "Enter a value between 1 and 100";
                        }
                        
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Tags
                    Text("Tags", style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _controller.tagController,
                            focusNode: _controller.tagFocusNode,
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
                            if (_controller.tagController.text.trim().isNotEmpty) {
                              setState(() {
                                _controller.addTag(_controller.tagController.text);
                                _controller.tagController.clear();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _controller.tags.map((tag) {
                        return Chip(
                          label: Text(tag),
                          backgroundColor: theme.colorScheme.primary,
                          labelStyle: TextStyle(color: theme.colorScheme.onPrimary),
                          deleteIcon: Icon(
                            Icons.close,
                            size: 18,
                            color: theme.colorScheme.onPrimary,
                          ),
                          onDeleted: () {
                            setState(() {
                              _controller.removeTag(tag);
                            });
                          },
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Assignees
                    Text("Assignee(s)", style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Member dropdown
                        Expanded(
                          child: DropdownButtonFormField<int?>(
                            value: _selectedMemberId,
                            items: widget.members.map((member) {
                              return DropdownMenuItem<int?>(
                                value: member.membersId,
                                // Handle nullable username
                                child: Text(member.username ?? 'Unknown User'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedMemberId = value;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: "Select member",
                              filled: true,
                              fillColor: theme.colorScheme.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 8),
                        
                        // Role dropdown
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedRole,
                            items: const [
                              DropdownMenuItem(value: 'Editor', child: Text('Editor')),
                              DropdownMenuItem(value: 'Viewer', child: Text('Viewer')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedRole = value ?? 'Editor';
                              });
                            },
                            decoration: InputDecoration(
                              hintText: "Select role",
                              filled: true,
                              fillColor: theme.colorScheme.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        
                        // Add member button
                        IconButton(
                          icon: Icon(Icons.add, color: theme.colorScheme.primary),
                          onPressed: () {
                            if (_selectedMemberId != null) {
                              setState(() {
                                _controller.assignMember(_selectedMemberId!, _selectedRole);
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Display assigned members
                    Wrap(
                      spacing: 8,
                      children: _controller.assignedMembers.entries.map((entry) {
                        // Find the member name
                        final memberName = widget.members
                            .firstWhere(
                              (m) => m.membersId == entry.key,
                              orElse: () => ProjectMember(
                                membersId: 0,
                                projectUid: 0,
                                userId: 0,
                                isOwner: false,
                                memberRole: 'Editor',
                                joinDate: DateTime.now(),
                                username: 'Unknown',
                              ),
                            )
                            .username ?? 'Unknown';
                            
                        return Chip(
                          label: Text('$memberName (${entry.value})'),
                          backgroundColor: theme.colorScheme.primary,
                          labelStyle: TextStyle(color: theme.colorScheme.onPrimary),
                          deleteIcon: Icon(
                            Icons.close,
                            size: 18,
                            color: theme.colorScheme.onPrimary,
                          ),
                          onDeleted: () {
                            setState(() {
                              _controller.removeMember(entry.key);
                            });
                          },
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Cancel and close modal
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.colorScheme.primary,
                          ),
                          child: const Text("Cancel"),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () async {
                            final result = await _controller.submitTask(widget.projectId);
                            if (result['success'] == true && mounted) {
                              if (widget.onTaskUpdated != null) {
                                widget.onTaskUpdated!();
                              }
                              Navigator.of(context).pop();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                          ),
                          child: const Text("Save Changes"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}