import 'package:flutter/material.dart';
import '../models/project.dart';
import '../../../usser/usserObject.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../common/enums/notification_frequency.dart';

// Project editing modal dialog - adapted from Add Project modal
class EditProjectModal extends StatefulWidget {
  final String projectId;
  final String projectName;
  final String description;
  final DateTime deadline;
  final String googleDriveLink;
  final String discordLink;
  final NotificationFrequency notificationPreference;
  final Color projectColor;
  final Function()? onProjectUpdated;

  const EditProjectModal({
    Key? key,
    required this.projectId,
    required this.projectName,
    required this.description,
    required this.deadline,
    this.googleDriveLink = '',
    this.discordLink = '',
    required this.notificationPreference,
    required this.projectColor,
    this.onProjectUpdated,
  }) : super(key: key);

  @override
  State<EditProjectModal> createState() => _EditProjectModalState();
}

class _EditProjectModalState extends State<EditProjectModal> {
  // Controllers for form fields
  late TextEditingController projectNameController;
  late TextEditingController descriptionController;
  late TextEditingController deadlineController;
  late TextEditingController googleDriveController;
  late TextEditingController discordController;
  
  // Focus nodes for keyboard navigation
  final FocusNode nameFocusNode = FocusNode();
  final FocusNode descriptionFocusNode = FocusNode();
  final FocusNode deadlineFocusNode = FocusNode();
  final FocusNode googleDriveFocusNode = FocusNode();
  final FocusNode discordFocusNode = FocusNode();
  
  // Form state tracking
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late NotificationFrequency notificationPreference;
  late ValueNotifier<NotificationFrequency> notificationFrequencyNotifier;
  late Color selectedColor;
  late DateTime selectedDeadline;
  bool isLoading = false;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with existing project data
    projectNameController = TextEditingController(text: widget.projectName);
    descriptionController = TextEditingController(text: widget.description);
    googleDriveController = TextEditingController(text: widget.googleDriveLink);
    discordController = TextEditingController(text: widget.discordLink);
    
    // Format the deadline for display
    deadlineController = TextEditingController(
      text: "${widget.deadline.day}/${widget.deadline.month}/${widget.deadline.year}"
    );
    
    // Initialize state variables
    notificationPreference = widget.notificationPreference;
    notificationFrequencyNotifier = ValueNotifier<NotificationFrequency>(widget.notificationPreference);
    selectedColor = widget.projectColor;
    selectedDeadline = widget.deadline;
  }
  
  @override
  void dispose() {
    // Clean up controllers and focus nodes
    projectNameController.dispose();
    descriptionController.dispose();
    deadlineController.dispose();
    googleDriveController.dispose();
    discordController.dispose();
    
    nameFocusNode.dispose();
    descriptionFocusNode.dispose();
    deadlineFocusNode.dispose();
    googleDriveFocusNode.dispose();
    discordFocusNode.dispose();
    
    notificationFrequencyNotifier.dispose();
    
    super.dispose();
  }

  // Resets all form fields to the original project values
  void resetForm() {
    setState(() {
      projectNameController.text = widget.projectName;
      descriptionController.text = widget.description;
      deadlineController.text = "${widget.deadline.day}/${widget.deadline.month}/${widget.deadline.year}";
      googleDriveController.text = widget.googleDriveLink;
      discordController.text = widget.discordLink;
      notificationPreference = widget.notificationPreference;
      notificationFrequencyNotifier.value = widget.notificationPreference;
      selectedColor = widget.projectColor;
      selectedDeadline = widget.deadline;
      formKey.currentState?.reset();
    });
  }

  // Validates and updates the project
  Future<void> updateProject() async {
    if (formKey.currentState!.validate() && selectedDeadline != null) {
      setState(() {
        isLoading = true;
      });
      
      try {
        // Create the request body with fields to update
        final requestBody = {
          'name': projectNameController.text,
          'deadline': "${selectedDeadline.year}-${selectedDeadline.month.toString().padLeft(2, '0')}-${selectedDeadline.day.toString().padLeft(2, '0')}",
          'description': descriptionController.text,
          'notification_preference': notificationPreference.name,
          'google_drive_link': googleDriveController.text.isEmpty ? null : googleDriveController.text,
          'discord_link': discordController.text.isEmpty ? null : discordController.text,
        };
        
        // Make the API call to update the project
        final response = await http.put(
          Uri.parse('http://127.0.0.1:5000/project/${widget.projectId}'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(requestBody),
        );
        
        if (response.statusCode == 200) {
          // Success
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Project updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Call the callback if provided
          if (widget.onProjectUpdated != null) {
            widget.onProjectUpdated!();
          }
          
          // Close the modal
          Navigator.of(context).pop(true); // Return true to indicate success
        } else {
          // Error
          final errorData = json.decode(response.body);
          throw Exception(errorData['error'] ?? 'Failed to update project');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
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
              Flexible(
                child: Text(
                  'Edit Project: ${widget.projectName}',
                  style: theme.textTheme.headlineSmall,
                  overflow: TextOverflow.ellipsis,
                ),
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
                            onPressed: resetForm,
                            child: const Text('Reset'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: isLoading ? null : updateProject,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                            ),
                            child: isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Save Changes'),
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
  
  // Builds left side form fields
  Widget _buildLeftColumn(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Project Name", style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: projectNameController,
          focusNode: nameFocusNode,
          decoration: InputDecoration(
            hintText: "Enter project name",
            filled: true,
            fillColor: theme.colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "Project name cannot be empty";
            } else if (value.length > 20) {
              return "Project name cannot exceed 20 characters";
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
            hintText: "Enter project description",
            filled: true,
            fillColor: theme.colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          validator: (value) => 
            value == null || value.trim().isEmpty ? "Description cannot be empty" : null,
          onFieldSubmitted: (_) {
          },
        ),
        
        const SizedBox(height: 16),
        Text("Notification Preference", style: theme.textTheme.titleMedium),
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
                  notificationPreference = value;
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
  
  // Builds right side form fields
  Widget _buildRightColumn(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Deadline", style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: deadlineController,
          focusNode: deadlineFocusNode,
          readOnly: true,
          decoration: InputDecoration(
            hintText: "Select deadline",
            filled: true,
            fillColor: theme.colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          onTap: () async {
            final DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: selectedDeadline,
              firstDate: DateTime.now(),
              lastDate: DateTime(2030),
            );
            
            if (pickedDate != null) {
              setState(() {
                selectedDeadline = pickedDate;
                deadlineController.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
              });
            }
          },
          validator: (value) => 
            value == null || value.trim().isEmpty ? "Deadline is required" : null,
        ),
        
        const SizedBox(height: 16),
        Text("Google Drive Link (Optional)", style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: googleDriveController,
          focusNode: googleDriveFocusNode,
          decoration: InputDecoration(
            hintText: "Enter Google Drive link",
            filled: true,
            fillColor: theme.colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onFieldSubmitted: (_) {
            FocusScope.of(context).requestFocus(discordFocusNode);
          },
        ),
        
        const SizedBox(height: 16),
        Text("Discord Link (Optional)", style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: discordController,
          focusNode: discordFocusNode,
          decoration: InputDecoration(
            hintText: "Enter Discord link",
            filled: true,
            fillColor: theme.colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        Text("Project Color", style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Container(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildColorOption(Colors.blue),
              _buildColorOption(Colors.purple),
              _buildColorOption(Colors.green),
              _buildColorOption(Colors.orange),
              _buildColorOption(Colors.red),
              _buildColorOption(Colors.teal),
              _buildColorOption(Colors.indigo),
              _buildColorOption(Colors.brown),
            ],
          ),
        ),
      ],
    );
  }
  
  // Builds color selection option
  Widget _buildColorOption(Color color) {
    final isSelected = selectedColor.value == color.value;
    return GestureDetector(
      onTap: () => setState(() => selectedColor = color),
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: isSelected 
            ? Border.all(color: Colors.white, width: 3)
            : null,
        ),
        child: isSelected
          ? const Icon(Icons.check, color: Colors.white)
          : null,
      ),
    );
  }
}
