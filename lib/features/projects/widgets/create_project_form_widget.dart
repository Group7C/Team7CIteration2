import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/create_project_controller.dart';
import '../../../features/tasks/widgets/date_picker_field.dart';
import '../../../usser/usserObject.dart';

class CreateProjectFormWidget extends StatefulWidget {
  final VoidCallback? onSubmitSuccess;
  
  const CreateProjectFormWidget({
    Key? key,
    this.onSubmitSuccess,
  }) : super(key: key);

  @override
  State<CreateProjectFormWidget> createState() => _CreateProjectFormWidgetState();
}

class _CreateProjectFormWidgetState extends State<CreateProjectFormWidget> {
  late final CreateProjectController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = CreateProjectController();
    
    // Initialize form with default values
    _controller.initDefaults();
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
          
          // Optional Integrations heading
          Text("Optional Integrations", 
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Google Drive Link
          Text("Google Drive Link (Optional)", style: theme.textTheme.titleMedium?.copyWith(color: Colors.white)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _controller.googleDriveLinkController,
            focusNode: _controller.googleDriveLinkFocusNode,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Enter Google Drive link",
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
              // No validation needed - allow any format of URLs
              return null;
            },
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(_controller.discordLinkFocusNode);
            },
          ),
          
          const SizedBox(height: 24),
          
          // Discord Link
          Text("Discord Link (Optional)", style: theme.textTheme.titleMedium?.copyWith(color: Colors.white)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _controller.discordLinkController,
            focusNode: _controller.discordLinkFocusNode,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Enter Discord link",
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
              // No validation needed - allow any format of URLs
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
                  // Reset form to default values
                  setState(() {
                    _controller.clearForm();
                    _controller.initDefaults();
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
                  // Get the current user
                  final currentUser = Provider.of<Usser>(context, listen: false);
                  
                  // Submit the form
                  final projectId = await _controller.submitProject(currentUser);
                  
                  if (projectId != null && mounted) {
                    if (widget.onSubmitSuccess != null) {
                      widget.onSubmitSuccess!();
                    }
                    Navigator.of(context).pop();
                    
                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Project created successfully'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } else if (mounted) {
                    // Show error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to create project'),
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
                child: const Text("Create Project"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
