// lib/home/home.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'settings_page.dart';
import '../providers/tasks_provider.dart';
import '../Objects/task.dart';
import 'components/components.dart';
import 'components/compact/compact_components.dart';
import 'components/add_task_screen.dart';

enum Role { editor, reader }

extension RoleExtension on Role {
  String get name {
    switch (this) {
      case Role.editor:
        return 'Editor';
      case Role.reader:
        return 'Reader';
      default:
        return '';
    }
  }
}

class DatePickerField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(DateTime) onDateSelected;

  const DatePickerField({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  State<DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      readOnly: true,
      decoration: InputDecoration(
        hintText: "Pick Date",
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: _pickEndDate,
        ),
      ),
      validator: (value) => value == null || value.isEmpty ? "Please select a date" : null,
      onTap: () => _pickEndDate(), 
      onFieldSubmitted: (_) {
        FocusScope.of(context).nextFocus(); 
      },
    );
  }

  void _pickEndDate() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selectedDate != null) {
      widget.onDateSelected(selectedDate);
      widget.controller.text = DateFormat('yyyy-MM-dd').format(selectedDate);
    }
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Layout variables from home_screen.dart
  String screenTitle = "Team 7C"; // User name 
  //To create a task retrieve and change variables of project's name, project's tasks' name list, 
  //project's capacity(remaining percentage), notification preference(enabled/daily)
  // Task functionality variables from original home.dart
  int projectCapacity = 78;
  List<Task> tasks = [];
  List<String> projectTasks = ["Task1", "Task 2"];
  String projectName = "MyProject";
  List<String> get possibleTaskParent => [projectName, ...projectTasks]; // dynamically construction when accessing it
  List<String> projectMembers = ['Alice','Bob','Charlie'];
  Map<String, String> taskMember = {};
  String username = "Alice";
  

  final TextEditingController endDateController = TextEditingController();
  final TextEditingController tagController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController percentageWeightingController = TextEditingController();
  final TextEditingController priorityController = TextEditingController();
  
  late String _selectedUsername;
  Role _selectedRole = Role.editor;

  final ValueNotifier<List<Map<String, String>>> _membersListNotifier =
      ValueNotifier([]);

  final notificationFrequencyNotifier = ValueNotifier<NotificationFrequency>(NotificationFrequency.daily);
  late final ValueNotifier<String> taskParentNotifier;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List<String> tags = [];
  NotificationFrequency notificationFrequency = NotificationFrequency.daily; //retrieve project's value
  bool notificationPreference = true; //retrieve project's value
  // Focus Nodes
  FocusNode titleFocusNode = FocusNode();
  FocusNode descriptionFocusNode = FocusNode();
  FocusNode endDateFocusNode = FocusNode();
  FocusNode tagFocusNode = FocusNode();
  FocusNode percentageFocusNode = FocusNode();
  FocusNode priorityFocusNode = FocusNode();

  

  @override
  void initState() {
    super.initState();
    _selectedUsername = username;
    taskMember = {username: _selectedRole.name};
     taskParentNotifier = ValueNotifier<String>(possibleTaskParent.first);

  }

  @override
  void dispose() {
    notificationFrequencyNotifier.dispose(); 
    taskParentNotifier.dispose();
    titleFocusNode.dispose();
    descriptionFocusNode.dispose();
    tagFocusNode.dispose();
    percentageFocusNode.dispose();
    priorityFocusNode.dispose();
    endDateController.dispose();
    endDateFocusNode.dispose();
    tagController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    percentageWeightingController.dispose();
    priorityController.dispose();
    _membersListNotifier.dispose();
    super.dispose();
  }

  
  // Updated Home Body layout from home_screen.dart
  Widget createHomeBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Top row with three equal columns
          Expanded(
            flex: 2,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Projects List - Compact Version
                Expanded(
                  child: CompactProjectList(),
                ),
                const SizedBox(width: 16),
                // Groups List - Compact Version
                Expanded(
                  child: CompactGroupsList(),
                ),
                const SizedBox(width: 16),
                // Activity Tracker - Compact Version
                Expanded(
                  child: CompactActivityTracker(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Middle row with Kanban
          Expanded(
            flex: 3,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 1500),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "My Tasks",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Expanded(
                        child: KanbanBoard(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Bottom row with deadline manager
          Expanded(
            flex: 2,
            child: const DeadlineManager(),
          ),
        ],
      ),
    );
  }

  // Original task body from home.dart
  Widget createTaskBody() {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        return ListView.builder(
          itemCount: taskProvider.tasks.length,
          itemBuilder: (context, index) {
            final task = taskProvider.tasks[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ExpansionTile(
                title: Text(task.title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                    "Priority: ${task.priority} | Due: ${DateFormat('yyyy-MM-dd').format(task.endDate)}"),
                children: [
                  ListTile(
                    title: const Text("Parent Project"),
                    subtitle: Text(task.parentProject ?? "N/A"),
                  ),
                  ListTile(
                    title: const Text("Percentage Weighting"),
                    subtitle: Text("${task.percentageWeighting}%"),
                  ),
                  ListTile(
                    title: const Text("Tags"),
                    subtitle:
                        task.listOfTags.isNotEmpty
                            ? Wrap(
                                spacing: 8,
                                children: task.listOfTags!
                                    .map((tag) => Chip(label: Text(tag)))
                                    .toList(),
                              )
                            : const Text("None"),
                  ),
                  ListTile(
                    title: const Text("Start Date"),
                    subtitle:
                        Text(DateFormat('yyyy-MM-dd').format(task.startDate)),
                  ),
                  ListTile(
                    title: const Text("Members"),
                    subtitle: Text(
                        task.members.isNotEmpty
                            ? task.members.entries
                                .map((e) => "${e.key}: ${e.value}")
                                .join(", ")
                            : "None"),
                  ),
                  ListTile(
                    title: const Text("Notification Preference"),
                    subtitle: Text(
                        task.notificationPreference ? "Enabled" : "Disabled"),
                  ),
                  ListTile(
                    title: const Text("Notification Frequency"),
                    subtitle: Text(
                        task.notificationFrequency.toString().split('.').last),
                  ),
                  ListTile(
                    title: const Text("Description"),
                    subtitle: Text(task.description),
                  ),
                  ListTile(
                    title: const Text("Directory Path"),
                    subtitle: Text(task.directoryPath),
                  ),
                  ListTile(
                    title: const Text("Comments"),
                    subtitle: Text(task.comments?.join("\n") ?? "No comments"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Task form methods from original home.dart
  void addTag() {
    formKey.currentState!.validate();
  }

  void clearForm() {
    setState(() {
      titleController.clear();
      descriptionController.clear();
      tagController.clear();
      percentageWeightingController.clear();
      priorityController.clear();
      endDateController.clear();
      tags = [];
      taskMember.clear();
      taskParentNotifier.value = possibleTaskParent.first;
      notificationPreference = true;
      formKey.currentState?.reset();
    });
  }

  void submitTask() {
    
    if (formKey.currentState!.validate()) {
      Task newTask = Task(
        title: titleController.text,
        parentProject: taskParentNotifier.value,
        percentageWeighting:
        double.tryParse(percentageWeightingController.text) ?? 0.0,
        listOfTags: tags,
        priority: int.tryParse(priorityController.text) ?? 1,
        startDate: DateTime.now(),
        endDate: DateTime.parse(endDateController.text),
        description: descriptionController.text,
        members: Map.from(taskMember),
        notificationPreference: notificationPreference,
        notificationFrequency: notificationFrequencyNotifier.value,
        directoryPath: "path/to/directory",
      );

      Provider.of<TaskProvider>(context, listen: false).addTask(newTask);
      clearForm();
    }
  }
//Format ENUM for Frequency

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

  // Original add task body from home.dart
  Widget createAddTaskBody() {
    final theme = Theme.of(context);    

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: formKey,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column
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
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Title cannot be empty";
                      } else if (value.length > 50) {
                        return "Title cannot exceed 50 characters";
                      } else if (projectTasks.contains(value)) {
                        return "Choose a different name.";}
                      return null;
                    },
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
                    validator: (value) => value == null || value.trim().isEmpty
                        ? "Description cannot be empty"
                        : null,
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
                  Text("This belongs to:", style: theme.textTheme.titleMedium),
                  DropdownButtonFormField<String>(
                    value: taskParentNotifier.value, 
                    items: possibleTaskParent.map((parent) {
                      return DropdownMenuItem(
                        value: parent,
                        child: Text(
                          parent,
                          style: TextStyle(color: theme.colorScheme.onSurface),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        taskParentNotifier.value = value; 
                      }
                    },
                    decoration: InputDecoration(
                      hintText: "Select Parent Task",
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
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
                      if (value == null || value.trim().isEmpty) {
                        return "Percentage cannot be empty";
                      }
                      final percentage = int.tryParse(value);
                      if (percentage == null ||
                          percentage < 1 ||
                          percentage > 100) {
                        return "Enter a value between 1 and 100";}
                      if(percentage > projectCapacity){
                        return "Task weight must be less than $projectCapacity .";
                      
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(tagFocusNode);
                    },
                  ),

                  const SizedBox(height: 16),
                  Text("Tags", style: theme.textTheme.titleMedium),
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
                          style: TextStyle(color: theme.colorScheme.onSurface),
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
                  Wrap(
                    children: tags
                        .map((tag) => Chip(
                              label: Text(tag,
                                  style: TextStyle(
                                      color: theme.colorScheme.onPrimary)),
                              backgroundColor: theme.colorScheme.primary,
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  Text("Assignee(s)", style: theme.textTheme.titleMedium),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedUsername,
                          decoration: InputDecoration(
                            hintText: "Assignee",                            
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          items: projectMembers.map((member) {
                            return DropdownMenuItem<String>(
                              value: member,
                              child: Text(member),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedUsername = value!;
                            });
                          },
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
                          taskMember[_selectedUsername] = _selectedRole.name;
                          
                          _selectedUsername = username;
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
                          tags = [];
                          taskMember.clear();
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Only 3 tabs now
      initialIndex: 0,
      child: Scaffold(
        backgroundColor: Colors.grey[850],
        appBar: AppBar(
          title: Text(screenTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
          ],
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(text: "Home"),
              Tab(text: "Tasks"),
              Tab(
                  text:
                      "Add Task"), // Using singular form as in original home.dart
            ],
          ),
        ),
        body: TabBarView(children: <Widget>[
          createHomeBody(),
          createTaskBody(),
          createAddTaskBody(),
        ]),
      ),
    );
  }
}
