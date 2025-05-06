// lib/home/components/deadline_manager/deadline_timeline.dart
// TODO: Luke:  Fix alignment of circles, try and figure out how to sort their BG, what about the truncation of the tasks vertically?
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/deadline_task.dart';

class DeadlineTimeline extends StatefulWidget {
  const DeadlineTimeline({super.key});

  @override
  State<DeadlineTimeline> createState() => _DeadlineTimelineState();
}

class _DeadlineTimelineState extends State<DeadlineTimeline> {
  late List<DeadlineTask> tasks;
  late List<MapEntry<String, List<DeadlineTask>>> deadlineDates;
  int selectedDateIndex = 0;
  int visibleRangeStart = 0;
  final visibleRangeSize = 5;

  @override
  void initState() {
    super.initState();
    tasks = DeadlineSampleData.generateTasks();
    
    // Group tasks by date
    final groupedTasks = DeadlineSampleData.groupTasksByDate(tasks);
    deadlineDates = groupedTasks.entries.toList()
      ..sort((a, b) => a.value.first.date.compareTo(b.value.first.date));
  }

  // Get days between today and target date
  int getDaysFromToday(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    return targetDate.difference(today).inDays;
  }

  // Format date as Today, Tomorrow or MMM d
  String formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = DateTime(today.year, today.month, today.day + 1);
    final targetDate = DateTime(date.year, date.month, date.day);
    
    if (targetDate.isAtSameMomentAs(today)) return "Today";
    if (targetDate.isAtSameMomentAs(tomorrow)) return "Tomorrow";
    return DateFormat.MMMd().format(date);
  }

  // Nav methods
  void showPrevious() => setState(() {
    if (visibleRangeStart > 0) {
      visibleRangeStart = (visibleRangeStart - 3).clamp(0, deadlineDates.length - visibleRangeSize);
    }
  });
  
  void showNext() => setState(() {
    if (visibleRangeStart + visibleRangeSize < deadlineDates.length) {
      visibleRangeStart = (visibleRangeStart + 3).clamp(0, deadlineDates.length - visibleRangeSize);
    }
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Calculate visible dates
    final endIndex = (visibleRangeStart + visibleRangeSize).clamp(0, deadlineDates.length);
    final visibleDates = deadlineDates.sublist(visibleRangeStart, endIndex);
    
    // Ensure selected index is valid
    if (selectedDateIndex < visibleRangeStart || selectedDateIndex >= endIndex) {
      selectedDateIndex = visibleRangeStart;
    }

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 4,
          offset: const Offset(0, 2),
        )],
      ),
      child: Column(
        children: [
          // Header with selected deadline details
          _buildHeader(colorScheme),
          
          // Timeline section
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Stack(
                children: [
                  // Timeline line - cuts through circle centers
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 40,
                    child: Container(height: 1, color: colorScheme.outlineVariant),
                  ),
                  
                  // Nav buttons if needed
                  if (visibleRangeStart > 0)
                    _buildNavButton(colorScheme, left: true),
                  
                  if (visibleRangeStart + visibleRangeSize < deadlineDates.length)
                    _buildNavButton(colorScheme, left: false),
                  
                  // Date circles
                  _buildDateCircles(visibleDates, colorScheme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    if (deadlineDates.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
        ),
        child: Center(
          child: Text(
            "No upcoming deadlines",
            style: TextStyle(color: colorScheme.onPrimary),
          ),
        ),
      );
    }

    final selectedDate = deadlineDates[selectedDateIndex].value.first.date;
    final daysFromToday = getDaysFromToday(selectedDate);
    final tasks = deadlineDates[selectedDateIndex].value;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Upcoming Deadlines",
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.tune,
                  color: colorScheme.onPrimary.withOpacity(0.8),
                  size: 20,
                ),
                onPressed: () {/* Filter functionality */},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          
          const SizedBox(height: 4),
          
          Row(
            children: [
              Text(
                daysFromToday == 0 ? "Today" : "In $daysFromToday days",
                style: TextStyle(
                  color: colorScheme.onPrimary.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                formatDate(selectedDate),
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 6),
          
          Container(
            constraints: const BoxConstraints(maxHeight: 40),
            child: ListView.builder(
              itemCount: tasks.length,
              shrinkWrap: true,
              itemBuilder: (context, index) => _buildTaskItem(tasks[index], colorScheme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(DeadlineTask task, ColorScheme colorScheme) {
    final priorityColors = {
      'high': Colors.red,
      'medium': Colors.amber,
      'low': Colors.green,
    };
    
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.onPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: priorityColors[task.priority] ?? Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              task.title,
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            task.time,
            style: TextStyle(
              color: colorScheme.onPrimary.withOpacity(0.8),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(ColorScheme colorScheme, {required bool left}) {
    return Positioned(
      left: left ? 4 : null,
      right: left ? null : 4,
      top: 20,
      child: Material(
        elevation: 2,
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: left ? showPrevious : showNext,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            child: Icon(
              left ? Icons.chevron_left : Icons.chevron_right,
              size: 18,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateCircles(List<MapEntry<String, List<DeadlineTask>>> dates, ColorScheme colorScheme) {
    if (dates.isEmpty) {
      return const Center(
        child: Text(
          "No deadlines available",
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
      );
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        dates.length,
        (index) {
          final actualIndex = index + visibleRangeStart;
          final dateEntry = dates[index];
          final date = dateEntry.value.first.date;
          final daysFromToday = getDaysFromToday(date);
          final hasHighPriority = dateEntry.value.any((task) => task.priority == 'high');
          final isSelected = selectedDateIndex == actualIndex;
          
          return GestureDetector(
            onTap: () => setState(() => selectedDateIndex = actualIndex),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Days label
                Text(
                  daysFromToday == 0 ? "Today" : daysFromToday == 1 ? "Tmrw" : "In ${daysFromToday}d",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: hasHighPriority ? Colors.red : colorScheme.primary,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // Circle with badge
                Stack(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? colorScheme.primary
                            : hasHighPriority
                                ? Colors.red.withOpacity(0.1)
                                : colorScheme.primary.withOpacity(0.1),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : hasHighPriority
                                  ? Colors.red.withOpacity(0.3)
                                  : colorScheme.primary.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "${date.day}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isSelected
                              ? colorScheme.onPrimary
                              : hasHighPriority
                                  ? Colors.red.shade700
                                  : colorScheme.primary,
                        ),
                      ),
                    ),
                    
                    // Task count badge
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: hasHighPriority ? Colors.red : colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: colorScheme.surface, width: 1.5),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "${dateEntry.value.length}",
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 4),
                
                // Month label
                Text(
                  DateFormat.MMM().format(date),
                  style: TextStyle(
                    fontSize: 10,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
