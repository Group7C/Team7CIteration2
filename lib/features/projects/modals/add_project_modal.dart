import 'dart:math';
import 'package:flutter/material.dart';
import '../models/project.dart';
import '../../../usser/usserObject.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../common/enums/notification_frequency.dart';

// Project creation modal dialog - matches design of Add Task modal
class AddProjectModal extends StatefulWidget {
  const AddProjectModal({Key? key}) : super(key: key);

  @override
  State<AddProjectModal> createState() => _AddProjectModalState();
}

class _AddProjectModalState extends State<AddProjectModal> {
  // Controllers for form fields
  final TextEditingController projectNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();
  final TextEditingController googleDriveController = TextEditingController();
  final TextEditingController discordController = TextEditingController();
  
  // Focus nodes for keyboard navigation
  final FocusNode nameFocusNode = FocusNode();
  final FocusNode descriptionFocusNode = FocusNode();
  final FocusNode deadlineFocusNode = FocusNode();
  final FocusNode googleDriveFocusNode = FocusNode();
  final FocusNode discordFocusNode = FocusNode();
  
  // Form state tracking
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  NotificationFrequency notificationPreference = NotificationFrequency.weekly;
  final ValueNotifier<NotificationFrequency> notificationFrequencyNotifier = 
      ValueNotifier<NotificationFrequency>(NotificationFrequency.weekly);
  Color selectedColor = Colors.blue;
  DateTime? selectedDeadline;
  bool isLoading = false;
  
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

  // Resets all form fields to initial state
  void clearForm() {
    setState(() {
      projectNameController.clear();
      descriptionController.clear();
      deadlineController.clear();
      googleDriveController.clear();
      discordController.clear();
      notificationPreference = NotificationFrequency.weekly;
      selectedColor = Colors.blue;
      selectedDeadline = null;
      formKey.currentState?.reset();
    });
  }

  // Generate a unique join code
  String generateJoinCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(
        8, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  // Validates and creates new project
  Future<void> submitProject() async {
    if (formKey.currentState!.validate() && selectedDeadline != null) {
      setState(() {
        isLoading = true;
      });
      
      try {
        final usser = context.read<Usser>();
        
        // Create the request body
        final requestBody = {
          'user_id': usser.usserID,
          'name': projectNameController.text,
          'join_code': generateJoinCode(),
          'deadline': "${selectedDeadline!.year}-${selectedDeadline!.month.toString().padLeft(2, '0')}-${selectedDeadline!.day.toString().padLeft(2, '0')}",
          'description': descriptionController.text,
          'notification_preference': notificationPreference.name,
          'google_drive_link': googleDriveController.text.isEmpty ? null : googleDriveController.text,
          'discord_link': discordController.text.isEmpty ? null : discordController.text,
        };
        
        // Make the API call
        final response = await http.post(
          Uri.parse('http://127.0.0.1:5000/create/project'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(requestBody),
        );
        
        if (response.statusCode == 201) {
          // Success
          final responseData = json.decode(response.body);
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Project created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Clear the form and close the modal
          clearForm();
          Navigator.of(context).pop(true); // Return true to indicate success
        } else {
          // Error
          final errorData = json.decode(response.body);
          throw Exception(errorData['error'] ?? 'Failed to create project');
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
                  'Create New Project',
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
                            onPressed: clearForm,
                            child: const Text('Clear'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: isLoading ? null : submitProject,
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
                              : const Text('Create Project'),
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
            final DateTime? selectedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2030),
            );
            
            if (selectedDate != null) {
              setState(() {
                selectedDeadline = selectedDate;
                deadlineController.text = "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
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
    final isSelected = selectedColor == color;
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
