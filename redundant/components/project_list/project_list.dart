// lib/home/components/project_list/project_list.dart
import 'package:flutter/material.dart';
import 'project_item.dart';

class ProjectList extends StatelessWidget {
  const ProjectList({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Projects",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add, color: colorScheme.primary),
                  onPressed: () {
                    // Update: Probably replace this later
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: 3, // TODO: Replace with actual project count
                itemBuilder: (context, index) {
                  return ProjectItem(
                    title: "Project ${index + 1}",
                    memberCount: 5,
                    progress: 75,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
