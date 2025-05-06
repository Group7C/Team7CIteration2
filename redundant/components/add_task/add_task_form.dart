// lib/home/components/add_task/add_task_form.dart
import 'package:flutter/material.dart';

class AddTaskForm extends StatefulWidget {
  const AddTaskForm({super.key});

  @override
  State<AddTaskForm> createState() => _AddTaskFormState();
}

class _AddTaskFormState extends State<AddTaskForm> {
  final TextEditingController taskTitleController = TextEditingController();
  final TextEditingController taskDescriptionController =
      TextEditingController();
  final TextEditingController subtaskController = TextEditingController();
  final TextEditingController percentageWeightingController =
      TextEditingController();
  final TextEditingController tagController = TextEditingController();
  final List<String> subtasks = [];
  final List<String> tags = [];
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  DateTime? dueDate;

  void addSubtask() {
    if (subtaskController.text.isNotEmpty) {
      setState(() {
        subtasks.add(subtaskController.text);
      });
      subtaskController.clear();
    }
  }

  void addTag() {
    if (tagController.text.isNotEmpty) {
      setState(() {
        tags.add(tagController.text);
      });
      tagController.clear();
    }
  }

  Future<void> pickDueDate() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (selectedDate != null) {
      setState(() {
        dueDate = selectedDate;
      });
    }
  }

  void clearForm() {
    setState(() {
      taskTitleController.clear();
      taskDescriptionController.clear();
      subtaskController.clear();
      tagController.clear();
      percentageWeightingController.clear();
      subtasks.clear();
      tags.clear();
      dueDate = null;
    });
  }

  void createTask() {
    if (formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Task '${taskTitleController.text}' created successfully!")),
      );
    }
  }

  @override
  void dispose() {
    taskTitleController.dispose();
    taskDescriptionController.dispose();
    subtaskController.dispose();
    percentageWeightingController.dispose();
    tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                  Text("Title",
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                      )),
                  TextFormField(
                    controller: taskTitleController,
                    decoration: InputDecoration(
                      hintText: "Enter task title",
                      hintStyle: TextStyle(
                          color: colorScheme.onSurface.withAlpha(153)),
                      filled: true,
                      fillColor: colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    style: TextStyle(color: colorScheme.onSurface),
                    validator: (value) =>
                        value!.isEmpty ? "Title cannot be empty" : null,
                  ),
                  const SizedBox(height: 16),
                  Text("Subtasks",
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                      )),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: subtaskController,
                          decoration: InputDecoration(
                            hintText: "Add a subtask",
                            hintStyle: TextStyle(
                                color: colorScheme.onSurface.withAlpha(153)),
                            filled: true,
                            fillColor: colorScheme.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          style: TextStyle(color: colorScheme.onSurface),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add, color: colorScheme.primary),
                        onPressed: addSubtask,
                      ),
                    ],
                  ),
                  Wrap(
                    children: subtasks
                        .map((subtask) => Chip(
                              label: Text(subtask,
                                  style:
                                      TextStyle(color: colorScheme.onPrimary)),
                              backgroundColor: colorScheme.primary,
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  Text("Description",
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                      )),
                  TextFormField(
                    controller: taskDescriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Enter task description",
                      hintStyle: TextStyle(
                          color: colorScheme.onSurface.withAlpha(153)),
                      filled: true,
                      fillColor: colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    style: TextStyle(color: colorScheme.onSurface),
                    validator: (value) =>
                        value!.isEmpty ? "Description cannot be empty" : null,
                  ),
                  const SizedBox(height: 16),
                  Text("Priority Level",
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                      )),
                  DropdownButtonFormField<int>(
                    items: [1, 2, 3, 4, 5]
                        .map((level) => DropdownMenuItem(
                              value: level,
                              child: Text("Priority $level",
                                  style:
                                      TextStyle(color: colorScheme.onSurface)),
                            ))
                        .toList(),
                    onChanged: (value) {},
                    decoration: InputDecoration(
                      hintText: "Select priority",
                      filled: true,
                      fillColor: colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text("Due Date",
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                      )),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          dueDate == null
                              ? "No date selected"
                              : "${dueDate!.day}/${dueDate!.month}/${dueDate!.year}",
                          style: TextStyle(color: colorScheme.onSurface),
                        ),
                      ),
                      TextButton(
                        onPressed: pickDueDate,
                        child: Text("Pick Date",
                            style: TextStyle(color: colorScheme.primary)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 32), // Spacing between columns

            // Right Column
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Percentage Weighting",
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                      )),
                  TextFormField(
                    controller: percentageWeightingController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Enter percentage",
                      hintStyle: TextStyle(
                          color: colorScheme.onSurface.withAlpha(153)),
                      filled: true,
                      fillColor: colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  const SizedBox(height: 16),

                  Text("Tags",
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                      )),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: tagController,
                          decoration: InputDecoration(
                            hintText: "Add a tag",
                            hintStyle: TextStyle(
                                color: colorScheme.onSurface.withAlpha(153)),
                            filled: true,
                            fillColor: colorScheme.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          style: TextStyle(color: colorScheme.onSurface),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add, color: colorScheme.primary),
                        onPressed: addTag,
                      ),
                    ],
                  ),
                  Wrap(
                    children: tags
                        .map((tag) => Chip(
                              label: Text(tag,
                                  style:
                                      TextStyle(color: colorScheme.onPrimary)),
                              backgroundColor: colorScheme.primary,
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),

                  Text("File Drop",
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                      )),
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colorScheme.outline),
                    ),
                    child: Center(
                      child: Text(
                        "Drop files here (Doesn't have any functionality yet)",
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                    ),
                  ),
                  const Spacer(),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: clearForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.error,
                          foregroundColor: colorScheme.onError,
                        ),
                        child: const Text("Clear"),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: createTask,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primaryContainer,
                          foregroundColor: colorScheme.onPrimaryContainer,
                        ),
                        child: const Text("Create"),
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
