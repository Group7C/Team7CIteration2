import 'package:flutter/material.dart';
import 'item_card.dart';

class ItemList extends StatelessWidget {
  final List<dynamic> items;
  final ItemCardBuilder itemBuilder;
  final String emptyMessage;
  final IconData emptyIcon;
  final bool scrollable;

  const ItemList({
    Key? key,
    required this.items,
    required this.itemBuilder,
    this.emptyMessage = 'No items',
    this.emptyIcon = Icons.info_outline,
    this.scrollable = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              emptyIcon,
              color: Colors.blue.shade200,
              size: 50,
            ),
            const SizedBox(height: 8),
            Text(
              emptyMessage,
              style: const TextStyle(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      );
    }

    Widget listContent = ListView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: scrollable 
          ? const AlwaysScrollableScrollPhysics() 
          : const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        return itemBuilder(context, items[index]);
      },
    );

    return scrollable
        ? Scrollbar(
            child: listContent,
          )
        : listContent;
  }
}

// Type definition for the item builder function
typedef ItemCardBuilder = Widget Function(BuildContext context, dynamic item);

// Example functions for building different item types
class ItemListBuilders {
  // Project item builder
  static ItemCardBuilder projectBuilder() {
    return (context, project) {
      return ItemCard(
        title: project.projName,
        subtitle: project.joinCode.isNotEmpty ? 'Join code: ${project.joinCode}' : null,
        date: project.deadline,
        leadingIcon: const Icon(
          Icons.folder_outlined,
          color: Colors.blue,
        ),
        onTap: () {
          // Navigate to project details
        },
      );
    };
  }

  // Task item builder
  static ItemCardBuilder taskBuilder() {
    return (context, task) {
      return ItemCard(
        title: task.taskName,
        description: task.description,
        date: task.endDate,
        leadingIcon: const Icon(
          Icons.task_outlined,
          color: Colors.green,
        ),
        tags: [
          if (task.tags != null)
            ItemTag(
              label: task.tags,
              color: Colors.amber,
            ),
          ItemTag(
            label: 'Priority ${task.priority}',
            color: task.priority > 2 ? Colors.red : Colors.green,
          ),
        ],
        onTap: () {
          // Navigate to task details
        },
      );
    };
  }

  // Deadline item builder
  static ItemCardBuilder deadlineBuilder() {
    return (context, deadline) {
      final daysLeft = deadline.date.difference(DateTime.now()).inDays;
      final isLate = daysLeft < 0;
      
      return ItemCard(
        title: deadline.title,
        subtitle: deadline.description,
        date: deadline.date,
        leadingIcon: Icon(
          isLate ? Icons.warning_amber_rounded : Icons.event,
          color: isLate ? Colors.red : Colors.amber,
        ),
        showBorder: isLate,
        borderColor: Colors.red,
        onTap: () {
          // Navigate to related item
        },
      );
    };
  }
}
