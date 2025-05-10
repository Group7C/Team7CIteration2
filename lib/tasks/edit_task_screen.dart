import 'package:flutter/material.dart';
import '../Objects/task.dart';
import '../providers/tasks_provider.dart';
import '../shared/components/date_picker_field.dart';
import 'package:provider/provider.dart';

// BASED ON VOULAS ADD TASK SCREEN - NOT CLAIMING TO BE ORIGINAL

class EditTaskScreen extends StatefulWidget {
  const EditTaskScreen({Key? key}) : super(key: key);

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  // Controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController priorityController = TextEditingController();
  final TextEditingController percentageWeightingController = TextEditingController();
  final TextEditingController tagController = TextEditingController();
  
  // Focus Nodes
  final FocusNode titleFocusNode = FocusNode();
  final FocusNode descriptionFocusNode = FocusNode();
  final FocusNode endDateFocusNode = FocusNode();
  final FocusNode priorityFocusNode = FocusNode();
  final FocusNode percentageFocusNode = FocusNode();
  final FocusNode tagFocusNode = FocusNode();
  
  // Form Key
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  // Task Selection
  int? selectedTaskIndex;
  Task? selectedTask;
  
  // Members Management
  List<String> projectMembers = ['Alice', 'Bob', 'Charlie'];
  Map<String, String> taskMembers = {};
  String _selectedUsername = 'Alice';
  Role _selectedRole = Role.editor;
  
  // Notifications
  final ValueNotifier<NotificationFrequency> notificationFrequencyNotifier = 
      ValueNotifier<NotificationFrequency>(NotificationFrequency.daily);
  bool notificationPreference = true;
  
  // Tags
  List<String> tags = [];
  
  // Parent Project
  String projectName = "MyProject";
  List<String> projectTasks = ["Task1", "Task 2"];
  List<String> get possibleTaskParent => [projectName, ...projectTasks];
  late final ValueNotifier<String> taskParentNotifier;
  
  @override
  void initState() {
    super.initState();
    taskParentNotifier = ValueNotifier<String>(possibleTaskParent.first);
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadTasks();
  }
  
  void _loadTasks() {
    final tasks = Provider.of<TaskProvider>(context, listen: false).tasks;
    if (tasks.isNotEmpty && selectedTaskIndex == null) {
      _selectTask(0);
    }
  }
  
  void _selectTask(int index) {
    final tasks = Provider.of<TaskProvider>(context, listen: false).tasks;
    if (index >= 0 && index < tasks.length) {
      final task = tasks[index];
      setState(() {
        selectedTaskIndex = index;
        selectedTask = task;
        
        // Populate form with task data
        titleController.text = task.title;
        descriptionController.text = task.description;
        endDateController.text = task.endDate.toString().split(' ')[0]; // Just the date part
        priorityController.text = task.priority.toString();
        percentageWeightingController.text = task.percentageWeighting.toString();
        taskParentNotifier.value = task.parentProject ?? possibleTaskParent.first;
        tags = List.from(task.listOfTags);
        taskMembers = Map.from(task.members);
        notificationFrequencyNotifier.value = task.notificationFrequency;
        notificationPreference = task.notificationPreference;
      });
    }
  }
  
  void _saveTask() {
    if (_formKey.currentState!.validate() && selectedTask != null) {
      final updatedTask = Task(
        title: titleController.text,
        parentProject: taskParentNotifier.value,
        status: selectedTask!.status, // Keep current status
        percentageWeighting: double.tryParse(percentageWeightingController.text) ?? 0.0,
        listOfTags: tags,
        priority: int.tryParse(priorityController.text) ?? 1,
        startDate: selectedTask!.startDate, // Keep original start date
        endDate: DateTime.parse(endDateController.text),
        description: descriptionController.text,
        members: Map.from(taskMembers),
        notificationPreference: notificationPreference,
        notificationFrequency: notificationFrequencyNotifier.value,
        directoryPath: selectedTask!.directoryPath,
        comments: selectedTask!.comments,
      );
      
      Provider.of<TaskProvider>(context, listen: false).updateTask(updatedTask);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Task '${updatedTask.title}' updated successfully!"))
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
    titleController.dispose();
    descriptionController.dispose();
    endDateController.dispose();
    priorityController.dispose();
    percentageWeightingController.dispose();
    tagController.dispose();
    
    // Dispose focus nodes
    titleFocusNode.dispose();
    descriptionFocusNode.dispose();
    endDateFocusNode.dispose();
    priorityFocusNode.dispose();
    percentageFocusNode.dispose();
    tagFocusNode.dispose();
    
    // Dispose notifiers
    notificationFrequencyNotifier.dispose();
    taskParentNotifier.dispose();
    
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tasks = Provider.of<TaskProvider>(context).tasks;
    
    if (tasks.isEmpty) {
      return const Center(
        child: Text(
          "No tasks available to edit",
          style: TextStyle(fontSize: 18),
        ),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Task Selection Dropdown
          Row(
            children: [
              Text("Select Task to Edit:", style: theme.textTheme.titleMedium),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: selectedTaskIndex,
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
          
          // Task Edit Form
          Expanded(
            child: selectedTask == null
                ? const Center(child: Text("Please select a task to edit"))
                : Form(
                    key: _formKey,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column
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
                                DropdownButtonFormField(
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
                        
                        // Right Column
                        Expanded(
                          flex: 1,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("This belongs to:", style: theme.textTheme.titleMedium),
                                ValueListenableBuilder<String>(
                                  valueListenable: taskParentNotifier,
                                  builder: (context, parentValue, child) {
                                    return DropdownButtonFormField<String>(
                                      value: parentValue,
                                      items: possibleTaskParent
                                          .map((parent) => DropdownMenuItem(
                                                value: parent,
                                                child: Text(parent),
                                              ))
                                          .toList(),
                                      onChanged: (value) {
                                        if (value != null) {
                                          taskParentNotifier.value = value;
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
                                Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        value: _selectedUsername,
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
                                        setState(() {
                                          taskMembers[_selectedUsername] = _selectedRole.name;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 8),
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
                                
                                // Save Button
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
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
