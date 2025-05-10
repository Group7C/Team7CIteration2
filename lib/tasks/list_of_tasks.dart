import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sevenc_iteration_two/providers/tasks_provider.dart';
import 'package:intl/intl.dart';
import '../Objects/task.dart';
import 'task_utils.dart';

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
                    "Priority: ${task.priority} | Due: ${DateFormat('dd-MM-yyyy').format(task.endDate)} | Status: ${task.status.displayName}"),
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
                                children: task.listOfTags
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