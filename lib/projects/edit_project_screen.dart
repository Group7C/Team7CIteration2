import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Objects/task.dart'; 
import '../providers/projects_provider.dart';
import 'project_model.dart';
import '../shared/components/date_picker_field.dart';
import 'validation/edit_project_validation.dart';

// BASED ON VOULAS ADD TASK SCREEN - NOT CLAIMING TO BE ORIGINAL

class EditProjectScreen extends StatefulWidget {
  const EditProjectScreen({Key? key}) : super(key: key);

  @override
  State<EditProjectScreen> createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends State<EditProjectScreen> {
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
  
  // Project Selection
  int? selectedProjectIndex;
  Project? selectedProject;
  
  // Notification frequency
  final ValueNotifier<NotificationFrequency> notificationFrequencyNotifier = 
      ValueNotifier<NotificationFrequency>(NotificationFrequency.weekly);
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadProjects();
  }
  
  void _loadProjects() {
    final projects = Provider.of<ProjectsProvider>(context, listen: false).projects;
    if (projects.isNotEmpty && selectedProjectIndex == null) {
      _selectProject(0);
    }
  }
  
  void _selectProject(int index) {
    final projects = Provider.of<ProjectsProvider>(context, listen: false).projects;
    if (index >= 0 && index < projects.length) {
      final project = projects[index];
      setState(() {
        selectedProjectIndex = index;
        selectedProject = project;
        
        // Populate form with project data
        projectNameController.text = project.projectName;
        joinCodeController.text = project.joinCode;
        deadlineController.text = project.deadline.toString().split(' ')[0]; // Just the date part
        googleDriveLinkController.text = project.googleDriveLink ?? '';
        discordLinkController.text = project.discordLink ?? '';
        notificationFrequencyNotifier.value = project.notificationFrequency;
      });
    }
  }
  
  void _saveProject() {
    if (_formKey.currentState!.validate() && selectedProject != null) {
      // Update the project with new values
      selectedProject!.projectName = projectNameController.text;
      selectedProject!.joinCode = joinCodeController.text;
      selectedProject!.deadline = DateTime.parse(deadlineController.text);
      selectedProject!.notificationFrequency = notificationFrequencyNotifier.value;
      selectedProject!.googleDriveLink = googleDriveLinkController.text.isEmpty 
          ? null 
          : googleDriveLinkController.text;
      selectedProject!.discordLink = discordLinkController.text.isEmpty 
          ? null 
          : discordLinkController.text;
      
      // Notify listeners of changes
      selectedProject!.notifyListeners();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Project '${selectedProject!.projectName}' updated successfully!"))
      );
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
    final projects = Provider.of<ProjectsProvider>(context).projects;
    
    if (projects.isEmpty) {
      return const Center(
        child: Text(
          "No projects available to edit",
          style: TextStyle(fontSize: 18),
        ),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project Selection Dropdown
          Row(
            children: [
              Text("Select Project to Edit:", style: theme.textTheme.titleMedium),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: selectedProjectIndex,
                  items: List.generate(projects.length, (index) {
                    return DropdownMenuItem(
                      value: index,
                      child: Text(projects[index].projectName),
                    );
                  }),
                  onChanged: (index) {
                    if (index != null) {
                      _selectProject(index);
                    }
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Project Edit Form
          Expanded(
            child: selectedProject == null
                ? const Center(child: Text("Please select a project to edit"))
                : Form(
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
                                ),
                                style: TextStyle(color: theme.colorScheme.onSurface),
                                validator: (value) => value != null ? null : "Cannot be empty",
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
                                ),
                                style: TextStyle(color: theme.colorScheme.onSurface),
                                validator: (value) => value != null ? null : "Cannot be empty",
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
                                validator: (value) => null,
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
                                validator: (value) => null,
                              ),
                              
                              // Project Members (just display, not editable for simplicity - but might implement removal as feature)
                              const SizedBox(height: 16),
                              Text("Project Members", style: theme.textTheme.titleMedium),
                              Card(
                                color: theme.colorScheme.surface,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      for (String member in selectedProject!.members)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.person, size: 16),
                                              const SizedBox(width: 8),
                                              Text(member),
                                            ],
                                          ),
                                        ),
                                      if (selectedProject!.members.isEmpty)
                                        Text(
                                          "No members assigned to this project",
                                          style: TextStyle(
                                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              
                              const Spacer(),
                              
                              // Save Button
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed: _saveProject,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: theme.colorScheme.primary,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                    ),
                                    child: Text(
                                      "Save Changes",
                                      style: TextStyle(color: theme.colorScheme.onPrimary),
                                    ),
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
        ],
      ),
    );
  }
}
