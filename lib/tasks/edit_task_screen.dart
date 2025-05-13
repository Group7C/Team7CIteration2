import 'package:flutter/material.dart';
import '../Objects/task.dart';
import '../providers/tasks_provider.dart';
import '../shared/components/date_picker_field.dart';
import 'package:provider/provider.dart';
import '../providers/projects_provider.dart';
import '../projects/project_model.dart';

// screen for modifying or deleting existing tasks
// [inspired by voula's add task screen implementation - just recreated it for task editing, much copy pasting]
class EditTaskScreen extends StatefulWidget {
  const EditTaskScreen({Key? key}) : super(key: key);

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  // form field controllers [for user input]
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController priorityController = TextEditingController();
  final TextEditingController percentageWeightingController = TextEditingController();
  final TextEditingController tagController = TextEditingController();
  final TextEditingController projectController = TextEditingController();
  
  // focus management for form navigation
  final FocusNode titleFocusNode = FocusNode();
  final FocusNode descriptionFocusNode = FocusNode();
  final FocusNode endDateFocusNode = FocusNode();
  final FocusNode priorityFocusNode = FocusNode();
  final FocusNode percentageFocusNode = FocusNode();
  final FocusNode tagFocusNode = FocusNode();
  
  // form validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  // task selection state
  int? selectedTaskIndex;
  Task? selectedTask;
  String? selectedProjectId;
  
  // member management
  List<String> projectMembers = [];
  Map<String, String> taskMembers = {};
  String? _selectedUsername;
  Role _selectedRole = Role.editor;
  
  // notification settings
  final ValueNotifier<NotificationFrequency> notificationFrequencyNotifier = 
      ValueNotifier<NotificationFrequency>(NotificationFrequency.daily);
  bool notificationPreference = true;
  
  // task metadata
  List<String> tags = [];
  
  // project data
  List<Project> userProjects = [];
  String? taskParentProject;
  
  @override
  void initState() {
    super.initState();
    _loadProjectsAndTasks();
  }
  
  // loads all tasks for all user projects
  // [handles fixing project references]
  void _loadProjectsAndTasks() async {
    // get user projects
    userProjects = Provider.of<ProjectsProvider>(context, listen: false).projects;
    
    // access task provider
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    
    // clear existing tasks
    taskProvider.tasks.clear();
    
    // fetch tasks for each project
    for (var project in userProjects) {
      if (project.projectUid != null) {
        await taskProvider.fetchTasksForProject(project.projectUid.toString());
        
        // fix parent project references
        for (var task in taskProvider.tasks) {
          if (task.parentProject == project.projectUid.toString()) {
            task.parentProject = project.projectName;
          }
        }
      }
    }
    
    // set initial selection if tasks exist
    if (mounted) {
      setState(() {
        if (taskProvider.tasks.isNotEmpty) {
          _selectTask(0);
        }
      });
    }
  }
  
  // populates form with selected task data
  // [updates all fields and dropdowns]
  void _selectTask(int index) {
    final tasks = Provider.of<TaskProvider>(context, listen: false).tasks;
    if (index >= 0 && index < tasks.length) {
      final task = tasks[index];
      setState(() {
        selectedTaskIndex = index;
        selectedTask = task;
        
        // find project for this task
        Project? taskProject = userProjects.firstWhere(
          (project) => project.projectName == task.parentProject,
          orElse: () => userProjects.first,
        );
        selectedProjectId = taskProject.projectUid?.toString();
        
        // get project members with duplicates removed
        projectMembers = taskProject.members.keys.toSet().toList();
        _selectedUsername = projectMembers.isNotEmpty ? projectMembers.first : null;
        
        // populate all form fields from task data
        titleController.text = task.title;
        descriptionController.text = task.description;
        endDateController.text = "${task.endDate.year}-${task.endDate.month.toString().padLeft(2, '0')}-${task.endDate.day.toString().padLeft(2, '0')}";
        priorityController.text = task.priority.toString();
        percentageWeightingController.text = task.percentageWeighting.toStringAsFixed(0);
        projectController.text = task.parentProject ?? '';
        tags = List.from(task.listOfTags);
        taskMembers = Map.from(task.members);
        notificationFrequencyNotifier.value = task.notificationFrequency;
        notificationPreference = task.notificationPreference;
      });
    }
  }
  
  // saves task changes to backend and local state
  // [performs validation before saving]
  void _saveTask() async {
    if (_formKey.currentState!.validate() && selectedTask != null && selectedProjectId != null) {
      // save original title for identification
      final String originalTitle = selectedTask!.title;
      
      // create updated task object
      final updatedTask = Task(
        taskId: selectedTask!.taskId,  
        title: titleController.text,
        parentProject: taskParentProject ?? selectedTask!.parentProject,
        status: selectedTask!.status, 
        percentageWeighting: double.tryParse(percentageWeightingController.text) ?? 0.0,
        listOfTags: tags,
        priority: int.tryParse(priorityController.text) ?? 1,
        startDate: selectedTask!.startDate, 
        endDate: DateTime.parse(endDateController.text),
        description: descriptionController.text,
        members: Map.from(taskMembers),
        notificationPreference: notificationPreference,
        notificationFrequency: notificationFrequencyNotifier.value,
        directoryPath: selectedTask!.directoryPath,
        comments: selectedTask!.comments,
      );
      
      // send updated task to backend
      bool success = await Provider.of<TaskProvider>(context, listen: false)
          .updateTaskOnline(updatedTask, selectedProjectId!);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Task '${updatedTask.title}' updated successfully!"))
        );
        
        // refresh task list
        _loadProjectsAndTasks();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to update task. Please try again."),
            backgroundColor: Colors.red,
          )
        );
      }
    }
  }
  
  // deletes task with confirmation
  // [shows loading during processing]
  void _deleteTask() async {
    if (selectedTask != null && selectedProjectId != null) {
      // confirm deletion first
      bool? confirmDelete = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete Task'),
            content: Text('Are you sure you want to delete "${selectedTask!.title}"? This action cannot be undone.'),
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
        // show loading spinner
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        );
        
        // perform deletion
        bool success = await Provider.of<TaskProvider>(context, listen: false)
            .deleteTaskOnline(selectedTask!.taskId.toString(), selectedProjectId!);
        
        // hide spinner
        Navigator.pop(context);
        
        if (success) {
          // show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Task '${selectedTask!.title}' deleted successfully!"))
          );
          
          // refresh task list
          _loadProjectsAndTasks();
        } else {
          // show error message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Failed to delete task. Please try again."),
              backgroundColor: Colors.red,
            )
          );
        }
      }
    }
  }
  
  // formats notification frequency for display
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
    // clean up controllers
    titleController.dispose();
    descriptionController.dispose();
    endDateController.dispose();
    priorityController.dispose();
    percentageWeightingController.dispose();
    tagController.dispose();
    projectController.dispose();
    
    // clean up focus nodes
    titleFocusNode.dispose();
    descriptionFocusNode.dispose();
    endDateFocusNode.dispose();
    priorityFocusNode.dispose();
    percentageFocusNode.dispose();
    tagFocusNode.dispose();
    
    // clean up notifiers
    notificationFrequencyNotifier.dispose();
    
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tasks = Provider.of<TaskProvider>(context).tasks;
    
    // loading state or empty state
    if (tasks.isEmpty) {
      return const Center(
        child: Text(
          "No tasks available to edit. Loading...",
          style: TextStyle(fontSize: 18),
        ),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // task selection dropdown [at top]
          Row(
            children: [
              Text("Select Task to Edit:", style: theme.textTheme.titleMedium),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: selectedTaskIndex,
                  hint: const Text("Select a task"),
                  items: List.generate(tasks.length, (index) {
                    return DropdownMenuItem(
                      value: index,
                      child: Text(tasks[index].title),
                    );
                  }),
                  onChanged: (index) {
                    if (index != null) {
                      _selectTask(index);
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
          
          // main edit form [two column layout]
          Expanded(
            child: selectedTask == null
                ? const Center(child: Text("Please select a task to edit"))
                : Form(
                    key: _formKey,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // left column [basics and dates]
                        Expanded(
                          flex: 1,
                          child: SingleChildScrollView(
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
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return "Title cannot be empty";
                                    } else if (value.length > 50) {
                                      return "Title cannot exceed 50 characters";
                                    }
                                    return null;
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
                                  validator: (value) => value == null || value.trim().isEmpty
                                      ? "Description cannot be empty"
                                      : null,
                                ),
                                
                                const SizedBox(height: 16),
                                Text("Priority Level", style: theme.textTheme.titleMedium),
                                // priority dropdown with 1-5 scale
                                DropdownButtonFormField<String>(
                                  value: priorityController.text.isNotEmpty 
                                      ? priorityController.text 
                                      : "1",
                                  items: ["1", "2", "3", "4", "5"]
                                      .map((level) => DropdownMenuItem(
                                            value: level,
                                            child: Text("Priority $level"),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    priorityController.text = value ?? "1";
                                  },
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: theme.colorScheme.surface,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 16),
                                Text("Due Date", style: theme.textTheme.titleMedium),
                                DatePickerField(
                                  controller: endDateController,
                                  focusNode: endDateFocusNode,
                                  onDateSelected: (selectedDate) {},
                                ),
                                
                                const SizedBox(height: 16),
                                Text("Notification Frequency", style: theme.textTheme.titleMedium),
                                ValueListenableBuilder<NotificationFrequency>(
                                  valueListenable: notificationFrequencyNotifier,
                                  builder: (context, frequency, child) {
                                    return DropdownButtonFormField<NotificationFrequency>(
                                      value: frequency,
                                      items: NotificationFrequency.values
                                          .map((freq) => DropdownMenuItem(
                                                value: freq,
                                                child: Text(_formatFrequency(freq)),
                                              ))
                                          .toList(),
                                      onChanged: (value) {
                                        if (value != null) {
                                          notificationFrequencyNotifier.value = value;
                                          if (value == NotificationFrequency.none) {
                                            notificationPreference = false;
                                          }
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
                        ),
                        
                        const SizedBox(width: 32),
                        
                        // right column [metadata and members]
                        Expanded(
                          flex: 1,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Project:", style: theme.textTheme.titleMedium),
                                // non-editable project field [determined by task]
                                TextFormField(
                                  controller: projectController,
                                  enabled: false,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: theme.colorScheme.surface.withOpacity(0.5),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  style: TextStyle(color: theme.colorScheme.onSurface),
                                ),
                                
                                const SizedBox(height: 16),
                                Text("Task's Weight", style: theme.textTheme.titleMedium),
                                TextFormField(
                                  controller: percentageWeightingController,
                                  focusNode: percentageFocusNode,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: "Weighting Percentage (1-100)",
                                    filled: true,
                                    fillColor: theme.colorScheme.surface,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return "Percentage cannot be empty";
                                    }
                                    final percentage = int.tryParse(value);
                                    if (percentage == null ||
                                        percentage < 1 ||
                                        percentage > 100) {
                                      return "Enter a value between 1 and 100";
                                    }
                                    return null;
                                  },
                                ),
                                
                                const SizedBox(height: 16),
                                Text("Tags", style: theme.textTheme.titleMedium),
                                // tag input with add button
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: tagController,
                                        focusNode: tagFocusNode,
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
                                        if (tagController.text.trim().isNotEmpty) {
                                          setState(() {
                                            tags.add(tagController.text.trim());
                                          });
                                          tagController.clear();
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                
                                // tags chips display [removable]
                                Wrap(
                                  spacing: 8,
                                  children: tags
                                      .map((tag) => Chip(
                                            label: Text(tag),
                                            backgroundColor: theme.colorScheme.primary,
                                            labelStyle: TextStyle(
                                                color: theme.colorScheme.onPrimary),
                                            onDeleted: () {
                                              setState(() {
                                                tags.remove(tag);
                                              });
                                            },
                                          ))
                                      .toList(),
                                ),
                                
                                const SizedBox(height: 16),
                                Text("Members", style: theme.textTheme.titleMedium),
                                // member selection controls
                                Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        value: _selectedUsername,
                                        hint: const Text("Select member"),
                                        items: projectMembers
                                            .map((member) => DropdownMenuItem(
                                                  value: member,
                                                  child: Text(member),
                                                ))
                                            .toList(),
                                        onChanged: (value) {
                                          if (value != null) {
                                            setState(() {
                                              _selectedUsername = value;
                                            });
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
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: DropdownButtonFormField<Role>(
                                        value: _selectedRole,
                                        items: Role.values
                                            .map((role) => DropdownMenuItem(
                                                  value: role,
                                                  child: Text(role.name),
                                                ))
                                            .toList(),
                                        onChanged: (value) {
                                          if (value != null) {
                                            setState(() {
                                              _selectedRole = value;
                                            });
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
                                    IconButton(
                                      icon: Icon(Icons.add, color: theme.colorScheme.primary),
                                      onPressed: () {
                                        if (_selectedUsername != null) {
                                          setState(() {
                                            taskMembers[_selectedUsername!] = _selectedRole.name;
                                          });
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 8),
                                // member chips display [removable]
                                Wrap(
                                  spacing: 8,
                                  children: taskMembers.entries
                                      .map((entry) => Chip(
                                            label: Text("${entry.key} (${entry.value})"),
                                            backgroundColor: theme.colorScheme.primary,
                                            labelStyle: TextStyle(
                                                color: theme.colorScheme.onPrimary),
                                            onDeleted: () {
                                              setState(() {
                                                taskMembers.remove(entry.key);
                                              });
                                            },
                                          ))
                                      .toList(),
                                ),
                                
                                const SizedBox(height: 32),
                                
                                // action buttons [delete and save]
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                      onPressed: _deleteTask,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: theme.colorScheme.error,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                      ),
                                      child: Text(
                                        "Delete Task",
                                        style: TextStyle(color: theme.colorScheme.onError),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    ElevatedButton(
                                      onPressed: _saveTask,
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