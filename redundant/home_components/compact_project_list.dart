// lib/features/home/widgets/compact_project_list.dart
import 'package:flutter/material.dart';

class CompactProjectList extends StatelessWidget {
  const CompactProjectList({super.key});

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
                  "Projects",
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
                  return _buildProjectItem(context, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectItem(BuildContext context, int index) {
    // Sample project data
    final projectNames = ["Team Project", "Research Paper", "UI Design"];
    final memberCounts = [5, 3, 2];
    final progressValues = [75, 45, 10];

    return Card(
      child: ListTile(
        leading: Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: _getProgressColor(progressValues[index]),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        title: Text(projectNames[index]),
        subtitle: Text("${memberCounts[index]} members"),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getProgressColor(progressValues[index]).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            "${progressValues[index]}%",
            style: TextStyle(
              color: _getProgressColor(progressValues[index]),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: () {
          // Navigate to project details
        },
      ),
    );
  }

  // Get appropriate color based on progress percentage
  Color _getProgressColor(int progress) {
    if (progress >= 75) return Colors.green;
    if (progress >= 40) return Colors.blue;
    if (progress >= 10) return Colors.amber;
    return Colors.red;
  }
}
