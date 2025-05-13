import 'package:flutter/material.dart';
import '../container_template.dart';
import '../list_card.dart';

class GroupsComponent extends StatelessWidget {
  const GroupsComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return ContainerTemplate(
      title: 'Groups',
      scrollableChild: true,
      height: 250,
      child: Column(
        children: const [
          ListCard(
            title: 'Task A',
            subtitle: 'High priority task that needs completion',
            leadingIcon: Icons.assignment,
            trailingIcon: Icons.priority_high,
          ),
          ListCard(
            title: 'Task B',
            subtitle: 'Medium priority task in progress',
            leadingIcon: Icons.assignment_turned_in,
            trailingIcon: Icons.access_time,
          ),
          ListCard(
            title: 'Task C',
            subtitle: 'Low priority task scheduled for later',
            leadingIcon: Icons.assignment_late,
            trailingIcon: Icons.schedule,
          ),
          ListCard(
            title: 'Task D',
            subtitle: 'Completed task for reference',
            leadingIcon: Icons.done,
            trailingIcon: Icons.check_circle,
          ),
          ListCard(
            title: 'Task E',
            subtitle: 'Pending review and approval',
            leadingIcon: Icons.rate_review,
            trailingIcon: Icons.hourglass_empty,
          ),
          ListCard(
            title: 'Task F',
            subtitle: 'Additional task to show scrolling',
            leadingIcon: Icons.add_task,
            trailingIcon: Icons.more_horiz,
          ),
        ],
      ),
    );
  }
}
