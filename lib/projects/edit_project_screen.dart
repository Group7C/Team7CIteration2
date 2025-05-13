import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Objects/task.dart'; 
import '../providers/projects_provider.dart';
import 'project_model.dart';
import '../shared/components/date_picker_field.dart';
import 'validation/edit_project_validation.dart';
import '../services/project_services.dart';
import '../usser/usserObject.dart';

// screen for modifying or deleting existing projects
// allows editing project details and managing members
// [inspired by Voula's add task screen implementation - basically just a recreation of that for editing projects]
class EditProjectScreen extends StatefulWidget {
  const EditProjectScreen({Key? key}) : super(key: key);

  @override
  State<EditProjectScreen> createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends State<EditProjectScreen> {
  // text input controllers [for form fields]
  final TextEditingController projectNameController = TextEditingController();
  final TextEditingController joinCodeController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();
  final TextEditingController googleDriveLinkController = TextEditingController();
  final TextEditingController discordLinkController = TextEditingController();
  
  // focus nodes for form navigation
  final FocusNode projectNameFocusNode = FocusNode();
  final FocusNode joinCodeFocusNode = FocusNode();
  final FocusNode deadlineFocusNode = FocusNode();
  final FocusNode googleDriveLinkFocusNode = FocusNode();
  final FocusNode discordLinkFocusNode = FocusNode();
  
  // form validation key
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  // tracks selected project
  int? selectedProjectIndex;
  Project? selectedProject;
  
  // local copy of project members for display and management
  Map<String, String> projectMembers = {};
  
  // notification settings with value notifier [for dropdown]
  final ValueNotifier<NotificationFrequency> notificationFrequencyNotifier = 
      ValueNotifier<NotificationFrequency>(NotificationFrequency.weekly);
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadProjects();
  }
  
  // loads projects and selects first one by default
  void _loadProjects() {
    final projects = Provider.of<ProjectsProvider>(context, listen: false).projects;
    if (projects.isNotEmpty && selectedProjectIndex == null) {
      _selectProject(0);
    }
  }
  
  // loads project data into form fields when selected
  void _selectProject(int index) {
    final projects = Provider.of<ProjectsProvider>(context, listen: false).projects;
    if (index >= 0 && index < projects.length) {
      final project = projects[index];
      setState(() {
        selectedProjectIndex = index;
        selectedProject = project;
        
        // fill form with existing project data
        projectNameController.text = project.projectName;
        joinCodeController.text = project.joinCode;
        deadlineController.text = project.deadline.toString().split(' ')[0]; // just date part
        googleDriveLinkController.text = project.googleDriveLink ?? '';
        discordLinkController.text = project.discordLink ?? '';
        notificationFrequencyNotifier.value = project.notificationFrequency;
        
        // copy members for local management
        projectMembers = Map.from(project.members);
      });
    }
  }
  
  // saves updated project to server
  void _saveProject() async {
    if (_formKey.currentState!.validate() && selectedProject != null) {
      // show spinner while updating
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );
      
      // update project with form values
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
      selectedProject!.members = Map.from(projectMembers); 
      
      // send to server [uses project service]
      bool success = await ProjectServices.updateProject(selectedProject!);
      
      // hide spinner
      Navigator.pop(context);
      
      if (success) {
        // refresh projects after update
        final projectsProvider = Provider.of<ProjectsProvider>(context, listen: false);
        final usser = Provider.of<Usser>(context, listen: false);
        await projectsProvider.fetchProjects(usser.usserID);
        
        // update ui
        selectedProject!.notifyListeners();
        
        // show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Project '${selectedProject!.projectName}' updated successfully!"))
        );
      } else {
        // show error if failed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to update project. Please try again."),
            backgroundColor: Colors.red,
          )
        );
      }
    }
  }
  
  // handles project deletion with confirmation
  void _deleteProject() async {
    if (selectedProject != null) {
      // confirm before deleting [prevents accidental deletion]
      bool? confirmDelete = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete Project'),
            content: Text('Are you sure you want to delete "${selectedProject!.projectName}"? This action cannot be undone.'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          );
        },
      );
      
      if (confirmDelete == true) {
        // show spinner while deleting
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        );
        
        // delete from server
        bool success = await ProjectServices.deleteProject(selectedProject!.uuid, Provider.of<Usser>(context, listen: false).usserID);
        
        // hide spinner
        Navigator.pop(context);
        
        if (success) {
          // refresh projects list after deletion
          final projectsProvider = Provider.of<ProjectsProvider>(context, listen: false);
          final usser = Provider.of<Usser>(context, listen: false);
          await projectsProvider.fetchProjects(usser.usserID);
          
          // show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Project '${selectedProject!.projectName}' deleted successfully!"))
          );
          
          // select first project in list if any remain
          _selectProject(0);
        } else {
          // show error if failed
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Failed to delete project. Please try again."),
              backgroundColor: Colors.red,
            )
          );
        }
      }
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
    final projects = Provider.of<ProjectsProvider>(context).projects;
    
    // handle empty state
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
          // project selection dropdown [at top]
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
          
          // main edit form [only shows when project selected]
          Expanded(
            child: selectedProject == null
                ? const Center(child: Text("Please select a project to edit"))
                : Form(
                    key: _formKey,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // left column [basic project details]
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
                        
                        // right column [optional links, members, buttons]
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
                              
                              const SizedBox(height: 16),
                              Text("Project Members", style: theme.textTheme.titleMedium),
                              const SizedBox(height: 8),
                              // member chips with delete option [shows role in brackets]
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: projectMembers.entries
                                    .map((entry) => Chip(
                                          label: Text("${entry.key} (${entry.value})"),
                                          backgroundColor: theme.colorScheme.primary,
                                          labelStyle: TextStyle(
                                              color: theme.colorScheme.onPrimary),
                                          onDeleted: () {
                                            setState(() {
                                              projectMembers.remove(entry.key);
                                            });
                                          },
                                        ))
                                    .toList(),
                              ),
                              
                              const Spacer(),
                              
                              // action buttons [delete and save]
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed: _deleteProject,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: theme.colorScheme.error,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                    ),
                                    child: Text(
                                      "Delete Project",
                                      style: TextStyle(color: theme.colorScheme.onError),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
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