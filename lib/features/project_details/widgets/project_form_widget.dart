import 'package:flutter/material.dart';
import '../controllers/project_form_controller.dart';
import '../../../features/common/models/project_model.dart';
import '../../../features/tasks/widgets/date_picker_field.dart';

class ProjectFormWidget extends StatefulWidget {
  final Project project;
  final VoidCallback? onSubmitSuccess;
  
  const ProjectFormWidget({
    Key? key,
    required this.project,
    this.onSubmitSuccess,
  }) : super(key: key);

  @override
  State<ProjectFormWidget> createState() => _ProjectFormWidgetState();
}

class _ProjectFormWidgetState extends State<ProjectFormWidget> {
  late final ProjectFormController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = ProjectFormController();
    
    // Initialize form with project data
    _controller.initWithProject(widget.project);
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
          // Project Name field
          Text("Project Name", style: theme.textTheme.titleMedium?.copyWith(color: Colors.white)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _controller.nameController,
            focusNode: _controller.nameFocusNode,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Enter project name",
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              filled: true,
              fillColor: const Color(0xFF3A3D42),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Project name cannot be empty";
              } else if (value.length > 100) {
                return "Project name cannot exceed 100 characters";
              }
              return null;
            },
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(_controller.deadlineDateFocusNode);
            },
          ),
          
          const SizedBox(height: 24),
          
          // Deadline Date field
          Text("Deadline", style: theme.textTheme.titleMedium?.copyWith(color: Colors.white)),
          const SizedBox(height: 8),
          DatePickerField(
            controller: _controller.deadlineDateController,
            focusNode: _controller.deadlineDateFocusNode,
            onDateSelected: (selectedDate) {},
          ),
          
          const SizedBox(height: 24),
          
          // Notification Preference
          Text("Notification Preference", style: theme.textTheme.titleMedium?.copyWith(color: Colors.white)),
          const SizedBox(height: 8),
          DropdownButtonFormField<NotificationFrequency>(
            value: _controller.notificationFrequency,
            dropdownColor: const Color(0xFF3A3D42),
            style: const TextStyle(color: Colors.white),
            items: NotificationFrequency.values.map((frequency) {
              return DropdownMenuItem(
                value: frequency,
                child: Text(
                  frequency == NotificationFrequency.daily
                      ? "Daily"
                      : frequency == NotificationFrequency.weekly
                          ? "Weekly"
                          : "Monthly",
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
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              filled: true,
              fillColor: const Color(0xFF3A3D42),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Google Drive Link
          Text("Google Drive Link", style: theme.textTheme.titleMedium?.copyWith(color: Colors.white)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _controller.googleDriveLinkController,
            focusNode: _controller.googleDriveLinkFocusNode,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Enter Google Drive link (optional)",
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              filled: true,
              fillColor: const Color(0xFF3A3D42),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.drive_folder_upload, color: Colors.white70),
            ),
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                // Simple URL validation
                if (!value.startsWith('http://') && !value.startsWith('https://')) {
                  return "Please enter a valid URL starting with http:// or https://";
                }
              }
              return null;
            },
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(_controller.discordLinkFocusNode);
            },
          ),
          
          const SizedBox(height: 24),
          
          // Discord Link
          Text("Discord Link", style: theme.textTheme.titleMedium?.copyWith(color: Colors.white)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _controller.discordLinkController,
            focusNode: _controller.discordLinkFocusNode,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Enter Discord link (optional)",
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              filled: true,
              fillColor: const Color(0xFF3A3D42),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.discord, color: Colors.white70),
            ),
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                // Simple URL validation
                if (!value.startsWith('http://') && !value.startsWith('https://')) {
                  return "Please enter a valid URL starting with http:// or https://";
                }
              }
              return null;
            },
          ),
          
          const SizedBox(height: 32),
          
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () {
                  // Reset form to original project values
                  setState(() {
                    _controller.initWithProject(widget.project);
                  });
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white54),
                  foregroundColor: Colors.white,
                ),
                child: const Text("Reset"),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () async {
                  final success = await _controller.submitProjectUpdates(widget.project.projectUid);
                  if (success && mounted) {
                    if (widget.onSubmitSuccess != null) {
                      widget.onSubmitSuccess!();
                    }
                    Navigator.of(context).pop();
                    
                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Project updated successfully'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } else if (mounted) {
                    // Show error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to update project'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Save Changes"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
