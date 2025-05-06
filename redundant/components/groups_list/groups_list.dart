// lib/home/components/groups_list/groups_list.dart
import 'package:flutter/material.dart';
import 'group_item.dart';

class GroupsList extends StatelessWidget {
  const GroupsList({super.key});

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
                  "Groups",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add, color: colorScheme.primary),
                  onPressed: () {
                    // Update: Implement add group functionality
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: 3, // Update: Replace with actual group count
                itemBuilder: (context, index) {
                  return GroupItem(
                    title: "Group ${index + 1}",
                    memberCount: 8,
                    isActive: true,
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
