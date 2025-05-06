// lib/features/home/widgets/compact_groups_list.dart
import 'package:flutter/material.dart';

class CompactGroupsList extends StatelessWidget {
  const CompactGroupsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Groups",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {},
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 3,
                itemBuilder: (context, index) {
                  return _buildGroupItem(context, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupItem(BuildContext context, int index) {
    // Sample group data
    final groupNames = ["Development Team", "Design Team", "Research Team"];
    final memberCounts = [8, 5, 3];
    final statuses = ["Active", "Active", "Inactive"];
    final isActive = statuses[index] == "Active";

    return Card(
      child: ListTile(
        title: Text(groupNames[index]),
        subtitle: Text("${memberCounts[index]} members"),
        trailing: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: isActive ? Colors.green[100] : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            statuses[index],
            style: TextStyle(
              color: isActive ? Colors.green : Colors.grey,
            ),
          ),
        ),
        onTap: () {
          // Navigate to group details
        },
      ),
    );
  }
}
