import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../Objects/task.dart'; 
import '../providers/projects_provider.dart';
import '../usser/usserObject.dart';
import 'project_model.dart';
import '../shared/components/date_picker_field.dart';
import 'validation/add_project_validation.dart';

/// IMPLEMENTATION DIRECTLY INSPIRED BY VOULAS WORK ON THE ADD TASK SCREEN

class AddProjectScreen extends StatefulWidget {
  const AddProjectScreen({Key? key}) : super(key: key);

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  // Controllers
  final TextEditingController projectNameController = TextEditingController();
  final TextEditingController joinCodeController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();
  final TextEditingController googleDriveLinkController = TextEditingController();
  final TextEditingController discordLinkController = TextEditingController();
  
  // Focus Nodes
  final FocusNode projectNameFocusNode = FocusNode();
  final FocusNode joinCodeFocusNode = FocusNode();
  final FocusNode deadlineFocusNode = FocusNode();
  final FocusNode googleDriveLinkFocusNode = FocusNode();
  final FocusNode discordLinkFocusNode = FocusNode();
  
  // Form key for validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  // Error text variables
  String? projectNameErrorText;
  String? joinCodeErrorText;
  
  // Notification frequency
  final ValueNotifier<NotificationFrequency> notificationFrequencyNotifier = 
      ValueNotifier<NotificationFrequency>(NotificationFrequency.weekly);
  
  void clearForm() {
    setState(() {
      projectNameController.clear();
      joinCodeController.clear();
      deadlineController.clear();
      googleDriveLinkController.clear();
      discordLinkController.clear();
      notificationFrequencyNotifier.value = NotificationFrequency.weekly;
      _formKey.currentState?.reset();
      FocusScope.of(context).unfocus();
    });
  }
  
  void submitProject() {
    // Reset error text
    setState(() {
      projectNameErrorText = null;
      joinCodeErrorText = null;
    });
    
    if (_formKey.currentState!.validate()) {
      // Perform regex validation
      String projectNameRegOutcome = regexProjectName(projectNameController.text);
      if (projectNameRegOutcome != "0") {
        setState(() {
          projectNameErrorText = projectNameRegOutcome;
        });
        return;
      }
      
      String joinCodeRegOutcome = regexJoinCode(joinCodeController.text);
      if (joinCodeRegOutcome != "0") {
        setState(() {
          joinCodeErrorText = joinCodeRegOutcome;
        });
        return;
      }
      
      // Generate a UUID for the project
      final uuid = const Uuid().v4();
      
      // Create new project object
      final Project newProject = Project(
        projectName: projectNameController.text,
        joinCode: joinCodeController.text,
        deadline: DateTime.parse(deadlineController.text),
        notificationFrequency: notificationFrequencyNotifier.value,
        uuid: uuid,
        googleDriveLink: googleDriveLinkController.text.isEmpty ? null : googleDriveLinkController.text,
        discordLink: discordLinkController.text.isEmpty ? null : discordLinkController.text,
      );
      
      // Get user ID from Usser object
      String userId = Provider.of<Usser>(context, listen: false).usserID;
      
      // Create project online
      Provider.of<ProjectsProvider>(context, listen: false)
        .createProjectOnline(newProject, userId)
        .then((success) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Project '${newProject.projectName}' created successfully!"))
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Failed to create project. Please try again."))
            );
          }
        });
      
      // Clear form in either case
      clearForm();
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
  void dispose() {
    // Dispose controllers
    projectNameController.dispose();
    joinCodeController.dispose();
    deadlineController.dispose();
    googleDriveLinkController.dispose();
    discordLinkController.dispose();
    
    // Dispose focus nodes
    projectNameFocusNode.dispose();
    joinCodeFocusNode.dispose();
    deadlineFocusNode.dispose();
    googleDriveLinkFocusNode.dispose();
    discordLinkFocusNode.dispose();
    
    // Dispose notifiers
    notificationFrequencyNotifier.dispose();
    
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Project Name", style: theme.textTheme.titleMedium),
                  TextFormField(
                    controller: projectNameController,
                    focusNode: projectNameFocusNode,
                    decoration: InputDecoration(
                      hintText: "Enter project name",
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      errorText: projectNameErrorText,
                    ),
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    validator: (value) {
                      return projectNameValidator(value ?? '');
                    },
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(joinCodeFocusNode);
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  Text("Join Code", style: theme.textTheme.titleMedium),
                  TextFormField(
                    controller: joinCodeController,
                    focusNode: joinCodeFocusNode,
                    decoration: InputDecoration(
                      hintText: "Enter join code",
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      errorText: joinCodeErrorText,
                    ),
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    validator: (value) {
                      return joinCodeValidator(value ?? '');
                    },
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(deadlineFocusNode);
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  Text("Deadline", style: theme.textTheme.titleMedium),
                  DatePickerField(
                    controller: deadlineController,
                    focusNode: deadlineFocusNode,
                    onDateSelected: (selectedDate) {},
                  ),
                  
                  const SizedBox(height: 16),
                  Text("Notification Frequency", style: theme.textTheme.titleMedium),
                  ValueListenableBuilder<NotificationFrequency>(
                    valueListenable: notificationFrequencyNotifier,
                    builder: (context, frequency, child) {
                      return DropdownButtonFormField<NotificationFrequency>(
                        value: frequency,
                        items: [NotificationFrequency.daily, NotificationFrequency.weekly]
                            .map((freq) => DropdownMenuItem(
                                  value: freq,
                                  child: Text(
                                    _formatFrequency(freq),
                                    style: TextStyle(color: theme.colorScheme.onSurface),
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            notificationFrequencyNotifier.value = value;
                          }
                        },
                        decoration: InputDecoration(
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
              ),
            ),
            
            const SizedBox(width: 32),
            
            // Right Column
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Google Drive Link (Optional)", style: theme.textTheme.titleMedium),
                  TextFormField(
                    controller: googleDriveLinkController,
                    focusNode: googleDriveLinkFocusNode,
                    decoration: InputDecoration(
                      hintText: "Enter Google Drive link",
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    validator: (value) {
                      return googleDriveLinkValidator(value);
                    },
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(discordLinkFocusNode);
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  Text("Discord Link (Optional)", style: theme.textTheme.titleMedium),
                  TextFormField(
                    controller: discordLinkController,
                    focusNode: discordLinkFocusNode,
                    decoration: InputDecoration(
                      hintText: "Enter Discord link",
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    validator: (value) {
                      return discordLinkValidator(value);
                    },
                  ),
                  
                  // Push buttons to bottom
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
                            style: TextStyle(color: theme.colorScheme.onPrimary)),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: submitProject,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.secondary,
                        ),
                        child: Text("Create Project",
                            style: TextStyle(color: theme.colorScheme.onSecondary)),
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
