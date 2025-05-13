import 'package:flutter/material.dart';
import '../Objects/task.dart';
import '../Objects/tags_enum.dart';
import '../providers/tasks_provider.dart';
import '../shared/components/date_picker_field.dart';
import 'package:provider/provider.dart';
import 'validation/add_task_validation.dart';
import '../providers/projects_provider.dart';
import '../projects/project_model.dart';
import '../usser/usserObject.dart';


class AddTaskScreen extends StatefulWidget {
  final String? projectUuid;
  
  const AddTaskScreen({Key? key, this.projectUuid}) : super(key: key);

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  //To create a task retrieve and change variables of project's name, project's tasks' name list, 
  //project's capacity(remaining percentage), notification preference(enabled/daily)
  // Task functionality variables from original home.dart
  int projectCapacity = 78;
  List<Task> tasks = [];
  //List<String> projectMembers = ['Alice','Bob','Charlie'];  // Voula's hardcoded - replaced with Luke's database driven members
  List<String> projectMembers = [];  // Will load from selected project
  Map<String, String> taskMember = {};
  String username = "Alice";  // Default username - no longer automatically added
  int? selectedProjectUid;
  List<Project> userProjects = [];
  

  final TextEditingController endDateController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController percentageWeightingController = TextEditingController();
  final TextEditingController priorityController = TextEditingController();
  
  late String? _selectedUsername;  // Make nullable to handle empty member lists
  Role _selectedRole = Role.editor;

  final ValueNotifier<List<Map<String, String>>> _membersListNotifier =
      ValueNotifier([]);

  final notificationFrequencyNotifier = ValueNotifier<NotificationFrequency>(NotificationFrequency.daily);
  late final ValueNotifier<int?> taskProjectNotifier;
  GlobalKey<FormState>? formKey = GlobalKey<FormState>();
  TagsEnum? selectedTag;  // Single tag since database uses enum
  NotificationFrequency notificationFrequency = NotificationFrequency.daily; 
  bool notificationPreference = true; 
 
  FocusNode titleFocusNode = FocusNode();
  FocusNode descriptionFocusNode = FocusNode();
  FocusNode endDateFocusNode = FocusNode();
  FocusNode percentageFocusNode = FocusNode();
  FocusNode priorityFocusNode = FocusNode();

@override
void initState() {
  super.initState();

  _selectedUsername = null;  // Start with no selection
  taskMember = {};  // Start with empty members
  taskProjectNotifier = ValueNotifier<int?>(null);
  selectedProjectUid = widget.projectUuid != null ? int.tryParse(widget.projectUuid!) : null;
  
  // Get user projects
  WidgetsBinding.instance.addPostFrameCallback((_) {
    userProjects = Provider.of<ProjectsProvider>(context, listen: false).projects;
    if (userProjects.isNotEmpty && selectedProjectUid == null) {
      // Select first project by default if none provided
      Project firstProject = userProjects.first;
      if (firstProject.projectUid != null) {
        selectedProjectUid = firstProject.projectUid;
        taskProjectNotifier.value = selectedProjectUid;
        // Load initial project members
        projectMembers = List.from(firstProject.members.keys);
        _selectedUsername = projectMembers.isNotEmpty ? projectMembers.first : null;
      }
    }
  });
}



  @override
  void dispose() {
    notificationFrequencyNotifier.dispose(); 
    taskProjectNotifier.dispose();
    titleFocusNode.dispose();
    descriptionFocusNode.dispose();
    percentageFocusNode.dispose();
    priorityFocusNode.dispose();
    endDateController.dispose();
    endDateFocusNode.dispose();
    titleController.dispose();
    descriptionController.dispose();
    percentageWeightingController.dispose();
    priorityController.dispose();
    _membersListNotifier.dispose();
    super.dispose();
  }

  void clearForm() {
    setState(() {
      formKey = GlobalKey<FormState>();
      titleController.clear();
      descriptionController.clear();
      percentageWeightingController.clear();
      priorityController.clear();
      endDateController.clear();
      selectedTag = null;  // Clear selected tag
      taskMember.clear();  // Keep members empty on clear
      // Find first project
      if (userProjects.isNotEmpty) {
        Project firstProject = userProjects.first;
        if (firstProject.projectUid != null) {
          taskProjectNotifier.value = firstProject.projectUid;
        }
      }
      notificationPreference = true;
      formKey!.currentState?.reset();
      _membersListNotifier.value = [];
      _selectedUsername = projectMembers.isNotEmpty ? projectMembers.first : null;  // Select first project member if available        
    _selectedRole = Role.editor;  
      FocusScope.of(context).unfocus();
    });
  }

  void submitTask() async {
    
    if (formKey!.currentState!.validate()) {
      // Check if a project is selected
      if (taskProjectNotifier.value == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please select a project first."),
            backgroundColor: Colors.orange,
          )
        );
        return;
      }
      
      // Find the selected project
      Project? selectedProject = userProjects.firstWhere(
        (project) => project.projectUid == taskProjectNotifier.value,
        orElse: () => userProjects.first,
      );
      
      Task newTask = Task(
        title: titleController.text,
        parentProject: selectedProject.projectName,
        status: Status.todo,
        percentageWeighting:
        double.tryParse(percentageWeightingController.text) ?? 0.0,
        listOfTags: selectedTag != null ? [selectedTag!.databaseValue] : [],
        priority: int.tryParse(priorityController.text) ?? 1,
        startDate: DateTime.now(),
        endDate: DateTime.parse(endDateController.text),
        description: descriptionController.text,
        members: Map.from(taskMember),
        notificationPreference: notificationPreference,
        notificationFrequency: notificationFrequencyNotifier.value,
        directoryPath: "path/to/directory",
      );

      // Call createTaskOnline instead of just addTask
      // Use the projectUid (integer) for the backend API
      bool success = await Provider.of<TaskProvider>(context, listen: false)
          .createTaskOnline(newTask, selectedProject.projectUid!);
      
      if (selectedProject.projectUid == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Project does not have a valid ID. Please sync with the server."),
            backgroundColor: Colors.red,
          )
        );
        return;
      }
      
      if (success) {
        // Refresh all project and task data to keep in sync with backend
        String userId = Provider.of<Usser>(context, listen: false).usserID;
        
        // Refresh projects (which includes member data)
        await Provider.of<ProjectsProvider>(context, listen: false)
            .fetchProjects(userId);
        
        // Refresh tasks for this project
        await Provider.of<TaskProvider>(context, listen: false)
            .fetchTasksForProject(selectedProject.projectUid!.toString());
        
        clearForm();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Task '${newTask.title}' created successfully!"))
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to create task. Please try again."),
            backgroundColor: Colors.red,
          )
        );
      }
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final projects = Provider.of<ProjectsProvider>(context).projects;
    
    // Update userProjects if they've changed
    if (projects != userProjects) {
      userProjects = projects;
    }
    
    // If no projects available, show message
    if (userProjects.isEmpty) {
      return const Center(
        child: Text(
          "No projects available. Please create a project first.",
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: formKey!,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [            
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Title", style: theme.textTheme.titleMedium),
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
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    validator: (value) => titleValidator(value, false),
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(descriptionFocusNode);
                    },
                  ),
                  const SizedBox(height: 16),
                  Text("Description", style: theme.textTheme.titleMedium),
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
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    validator: (value) => descriptionValidator(value),
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(priorityFocusNode);
                    },
                  ),
                  const SizedBox(height: 16),
                  Text("Priority Level", style: theme.textTheme.titleMedium),
                  DropdownButtonFormField(
                    items: ["1", "2", "3", "4", "5"]
                        .map((level) => DropdownMenuItem(
                              value: level,
                              child: Text("Priority $level",
                                  style: TextStyle(
                                      color: theme.colorScheme.onSurface)),
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
                  Text("Due Date:", style: theme.textTheme.titleMedium),
                  DatePickerField(
                    controller: endDateController,
                    focusNode: endDateFocusNode,
                    onDateSelected: (selectedDate) {},
                  ),
                  const SizedBox(height: 16),
                  Text("Notification", style: theme.textTheme.titleMedium),                  
                    Expanded(
                      child: ValueListenableBuilder<NotificationFrequency>(
                        valueListenable: notificationFrequencyNotifier,
                        builder: (context, frequency, child) {
                          return DropdownButtonFormField<NotificationFrequency>(
                            items: NotificationFrequency.values.map((frequency) {
                              return DropdownMenuItem(
                                value: frequency,
                                child: Text(
                                  _formatFrequency(frequency),
                                  style: TextStyle(color: theme.colorScheme.onSurface),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                notificationFrequencyNotifier.value = value; 
                              }
                              if(value == NotificationFrequency.none){
                                notificationPreference = false;
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
                  const SizedBox(height: 16),
                  Text("This belongs to:", style: theme.textTheme.titleMedium),
                  ValueListenableBuilder<int?>(
                    valueListenable: taskProjectNotifier,
                    builder: (context, selectedProjectUid, child) {
                      return DropdownButtonFormField<int>(
                        value: selectedProjectUid,
                        items: userProjects
                            .where((project) => project.projectUid != null)
                            .map((project) {
                          return DropdownMenuItem(
                            value: project.projectUid,  // Use projectUid (integer)
                            child: Text(
                              project.projectName,
                              style: TextStyle(color: theme.colorScheme.onSurface),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            taskProjectNotifier.value = value;
                            // Load members for the selected project
                            Project? selectedProject = userProjects.firstWhere(
                              (project) => project.projectUid == value,
                              orElse: () => userProjects.first,
                            );
                            setState(() {
                              projectMembers = List.from(selectedProject.members.keys);
                              // Reset selected username to first member or keep current if still valid
                              if (!projectMembers.contains(_selectedUsername)) {
                                _selectedUsername = projectMembers.isNotEmpty ? projectMembers.first : null;
                              }
                            });
                          }
                        },
                        decoration: InputDecoration(
                          hintText: "Select Project",
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null) {
                            return "Please select a project";
                          }
                          return null;
                        },
                      );
                    },
                  ),                   
                  const SizedBox(height: 16),
                  Text("Task's Weight", style: theme.textTheme.titleMedium),
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
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    validator: (value) {
                        String? message= taskWeightValidator(value, projectCapacity)[0];
                        int? percentage= taskWeightValidator(value, projectCapacity)[1];
                        if (message == null) {
                          projectCapacity -= percentage!;
                          return null;
                        }
                        return message;
                      },
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(percentageFocusNode);
                    },
                  ),

                  const SizedBox(height: 16),
                  Text("Tag", style: theme.textTheme.titleMedium),
                  DropdownButtonFormField<TagsEnum>(
                    value: selectedTag,
                    decoration: InputDecoration(
                      hintText: "Select a tag",
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: TagsEnum.values.map((tag) {
                      return DropdownMenuItem(
                        value: tag,
                        child: Text(
                          tag.displayName,
                          style: TextStyle(color: theme.colorScheme.onSurface),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedTag = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Text("Assignee(s)", style: theme.textTheme.titleMedium),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedUsername,
                          hint: const Text("Select assignee"),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          items: projectMembers.isNotEmpty 
                            ? projectMembers.map((member) {
                                return DropdownMenuItem<String>(
                                  value: member,
                                  child: Text(member),
                                );
                              }).toList()
                            : null,
                          onChanged: projectMembers.isNotEmpty 
                            ? (value) {
                                setState(() {
                                  _selectedUsername = value!;
                                });
                              }
                            : null,
                        ),
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
                            setState(() {
                              _selectedRole = value!;
                            });
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add, color: theme.colorScheme.primary),
                        onPressed: () {
                          if (_selectedUsername != null) {
                            taskMember[_selectedUsername!] = _selectedRole.name;
                          }
                          
                          _selectedUsername = projectMembers.isNotEmpty ? projectMembers.first : null;
                          _selectedRole = Role.editor;
                          setState(() {}); 
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ValueListenableBuilder<List<Map<String, String>>>(
                    valueListenable: _membersListNotifier,
                    builder: (context, membersList, child) {
                      return Wrap(
                        spacing: 8,
                         children: taskMember.entries.map((entry) {
                          return Chip(
                            label: Text(
                              "${entry.key} (${entry.value})",
                              style: TextStyle(color: theme.colorScheme.onPrimary),
                            ),
                            backgroundColor: theme.colorScheme.primary,
                              onDeleted: () {
                                taskMember.remove(entry.key);
                                setState(() {}); 
                              },
                            );
                          }).toList(),
                      );
                    },
                  ),
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
                            style:
                                TextStyle(color: theme.colorScheme.onPrimary)),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          submitTask();
                          //Update the project remaining capacity all over
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.secondary,
                        ),
                        child: Text("Submit",
                            style: TextStyle(
                                color: theme.colorScheme.onSecondary)),
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