import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../Objects/task.dart'; 
import '../providers/projects_provider.dart';
import '../usser/usserObject.dart';
import 'project_model.dart';
import '../shared/components/date_picker_field.dart';
import 'validation/add_project_validation.dart';
import '../shared/components/small_modal.dart';

// screen for creating new projects or joining existing ones
// provides form for project details and option to enter join code
// [inspired by Voula's add task screen implementation - basically just a recreation of that for adding projects]
class AddProjectScreen extends StatefulWidget {
  const AddProjectScreen({Key? key}) : super(key: key);

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  // text input controllers [for form fields]
  final TextEditingController projectNameController = TextEditingController();
  final TextEditingController joinCodeController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();
  final TextEditingController googleDriveLinkController = TextEditingController();
  final TextEditingController discordLinkController = TextEditingController();
  
  // focus nodes for managing keyboard navigation
  final FocusNode projectNameFocusNode = FocusNode();
  final FocusNode joinCodeFocusNode = FocusNode();
  final FocusNode deadlineFocusNode = FocusNode();
  final FocusNode googleDriveLinkFocusNode = FocusNode();
  final FocusNode discordLinkFocusNode = FocusNode();
  
  // form validation key
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  // error messages for feedback
  String? projectNameErrorText;
  String? joinCodeErrorText;
  
  // separate controller for project joining modal
  final TextEditingController joinProjectCodeController = TextEditingController();
  
  // track notification settings with value notifier [for dropdown]
  final ValueNotifier<NotificationFrequency> notificationFrequencyNotifier = 
      ValueNotifier<NotificationFrequency>(NotificationFrequency.weekly);
  
  // resets all form values and clears focus
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
  
  // creates project after validation
  void submitProject() {
    // reset previous error messages
    setState(() {
      projectNameErrorText = null;
      joinCodeErrorText = null;
    });
    
    if (_formKey.currentState!.validate()) {
      // run regex validation for project name and join code
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
      
      // generate unique id for new project
      final uuid = const Uuid().v4();
      
      // create project object with form data
      final Project newProject = Project(
        projectName: projectNameController.text,
        joinCode: joinCodeController.text,
        deadline: DateTime.parse(deadlineController.text),
        notificationFrequency: notificationFrequencyNotifier.value,
        uuid: uuid,
        googleDriveLink: googleDriveLinkController.text.isEmpty ? null : googleDriveLinkController.text,
        discordLink: discordLinkController.text.isEmpty ? null : discordLinkController.text,
      );
      
      // get current user id for backend
      String userId = Provider.of<Usser>(context, listen: false).usserID;
      
      // send project to server [handles creation and user assignment]
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
      
      // clear form regardless of server response
      clearForm();
    }
  }
  
  // converts enum to display string for dropdown
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
    // clean up controllers to prevent memory leaks
    projectNameController.dispose();
    joinCodeController.dispose();
    deadlineController.dispose();
    googleDriveLinkController.dispose();
    discordLinkController.dispose();
    joinProjectCodeController.dispose();
    
    // clean up focus nodes
    projectNameFocusNode.dispose();
    joinCodeFocusNode.dispose();
    deadlineFocusNode.dispose();
    googleDriveLinkFocusNode.dispose();
    discordLinkFocusNode.dispose();
    
    // clean up notifiers
    notificationFrequencyNotifier.dispose();
    
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // main form with two column layout [left and right sides]
          Expanded(
            child: Form(
              key: _formKey,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            // left column [essential project details]
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
            
            // right column [optional links and action buttons]
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
                  
                  // push buttons to bottom of column
                  const Spacer(),
                  
                  // action buttons [clear and create]
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
          ),
          
          // join existing project section [alternative to creating]
          Column(
            children: [
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: theme.colorScheme.outline,
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'or join a project',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: theme.colorScheme.outline,
                      thickness: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  // opens modal popup to join existing project with code
                  showSmallModal(
                    context: context,
                    title: 'Join Existing Project',
                    showActionButtons: false,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Enter a join code to join an existing project',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: joinProjectCodeController,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 8.0,
                            color: theme.colorScheme.primary,
                          ),
                          decoration: InputDecoration(
                            hintText: "Enter join code",
                            hintStyle: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              letterSpacing: 0,
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              // validate join code
                              final joinCode = joinProjectCodeController.text.trim();
                              if (joinCode.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Please enter a join code"))
                                );
                                return;
                              }
                              
                              // get current user id
                              final userId = Provider.of<Usser>(context, listen: false).usserID;
                              
                              // show loading spinner
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                              
                              // join project on server [adds user to project member list]
                              Provider.of<ProjectsProvider>(context, listen: false)
                                .joinProjectWithCode(joinCode, userId)
                                .then((result) {
                                  // hide spinner
                                  Navigator.of(context).pop();
                                  // close join modal
                                  Navigator.of(context).pop();
                                  
                                  // show success/error message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(result['message'] ?? 'Unknown error'),
                                      backgroundColor: result['status'] == 'success' 
                                          ? Colors.green 
                                          : Colors.red,
                                    )
                                  );
                                });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                            ),
                            child: const Text("Join Now"),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.person_add),
                label: const Text("Join Project"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  textStyle: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}