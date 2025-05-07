import 'package:flutter/material.dart';
import 'item_card.dart';
import '../services/project_navigation_service.dart';

class HorizontalItemList extends StatelessWidget {
  final List<dynamic> items;
  final ItemCardBuilder itemBuilder;
  final String emptyMessage;
  final IconData emptyIcon;
  final double itemWidth;
  final double itemHeight;
  final EdgeInsets padding;

  const HorizontalItemList({
    Key? key,
    required this.items,
    required this.itemBuilder,
    this.emptyMessage = 'No items',
    this.emptyIcon = Icons.info_outline,
    this.itemWidth = 250,
    this.itemHeight = 150,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
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

    return Padding(
      padding: padding,
      child: SizedBox(
        height: itemHeight,
        child: RawScrollbar(
          thumbVisibility: true,
          thickness: 8,
          radius: const Radius.circular(4),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return SizedBox(
                width: itemWidth,
                child: itemBuilder(context, items[index]),
              );
            },
          ),
        ),
      ),
    );
  }
}

// Using the same ItemCardBuilder type defined in item_list.dart
typedef ItemCardBuilder = Widget Function(BuildContext context, dynamic item);

// Example builders for deadlines
class HorizontalItemBuilders {
  // Deadline item builder
  static ItemCardBuilder deadlineBuilder() {
    return (context, deadline) {
      final Color statusColor = deadline.isLate 
          ? Colors.red
          : (deadline.daysRemaining < 3 ? Colors.amber : Colors.green);
      
      return ItemCard(
        title: deadline.projectName,
        subtitle: deadline.status,
        description: deadline.description,
        date: deadline.date,
        leadingIcon: Icon(
          deadline.isLate ? Icons.warning_amber_rounded : Icons.event,
          color: statusColor,
        ),
        showBorder: deadline.isLate,
        borderColor: Colors.red,
        textColor: Colors.white,
        tags: deadline.isLate ? [
        ItemTag(
        label: 'Overdue',
        color: Colors.red,
        ),
        ] : [],
        onTap: () {
          // Navigate to project details
          if (deadline.projectId != null) {
            ProjectNavigationService.navigateToProjectDetails(
              context,
              deadline.projectId,
            );
          }
        },
      );
    };
  }
}
