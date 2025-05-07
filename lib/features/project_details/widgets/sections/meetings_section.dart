import 'package:flutter/material.dart';
import '../../../../features/common/widgets/section_card.dart';
import '../../../../features/common/widgets/action_button.dart';
import '../../../../features/common/models/project_model.dart';
import '../../../../models/meetings/meeting.dart'; // Updated import
import '../../../../services/meeting_service.dart'; // Updated import

class MeetingsSection extends StatefulWidget {
  final Project? project;
  final VoidCallback onSchedule;
  
  const MeetingsSection({
    Key? key,
    this.project,
    required this.onSchedule,
  }) : super(key: key);

  @override
  State<MeetingsSection> createState() => _MeetingsSectionState();
}

class _MeetingsSectionState extends State<MeetingsSection> {
  bool isLoading = true;
  List<Meeting> meetings = [];
  String? errorMessage;
  
  @override
  void initState() {
    super.initState();
    if (widget.project != null) {
      _loadMeetings();
    }
  }
  
  @override
  void didUpdateWidget(MeetingsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Always reload meetings when the widget updates
    if (widget.project != null) {
      print('MeetingsSection widget updated - reloading meetings');
      _loadMeetings();
    }
  }
  
  Future<void> _loadMeetings() async {
    if (widget.project == null) return;
    
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    
    try {
      final projectMeetings = await MeetingService.getProjectMeetings(widget.project!.projectUid.toString());
      
      setState(() {
        meetings = projectMeetings;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading meetings: $e');
      setState(() {
        errorMessage = 'Failed to load meetings';
        isLoading = false;
      });
    }
  }
  
  // Get the most recent completed meeting
  Meeting? get lastMeeting {
    final completedMeetings = meetings.where((m) => m.isCompleted).toList();
    if (completedMeetings.isEmpty) return null;
    
    completedMeetings.sort((a, b) => b.date.compareTo(a.date));
    return completedMeetings.first;
  }
  
  // Get the next scheduled meeting
  Meeting? get nextMeeting {
    final today = DateTime.now();
    print('DEBUG: Looking for next meeting from ${meetings.length} meetings');
    
    // Debug all meetings data
    for (var meeting in meetings) {
      print('DEBUG: Meeting ID: ${meeting.id}, Title: ${meeting.title}, Date: ${meeting.date}, isCompleted: ${meeting.isCompleted}');
      print('DEBUG: Is after today: ${meeting.date.isAfter(today)}');
    }
    
    final scheduledMeetings = meetings
        .where((m) => !m.isCompleted && m.date.isAfter(today))
        .toList();
    
    print('DEBUG: Found ${scheduledMeetings.length} upcoming meetings');
    
    if (scheduledMeetings.isEmpty) return null;
    
    scheduledMeetings.sort((a, b) => a.date.compareTo(b.date));
    return scheduledMeetings.first;
  }
  
  // Format a date as a string
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Meetings',
      height: 220,
      content: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Last Meeting
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            color: Colors.white70,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Last Meeting:',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            lastMeeting != null
                                ? '${lastMeeting!.title} (${_formatDate(lastMeeting!.date)})'
                                : 'Not recorded',
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Next Meeting
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Colors.blue,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Next Meeting:',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            nextMeeting != null
                                ? '${nextMeeting!.title} (${_formatDate(nextMeeting!.date)})'
                                : 'Not scheduled',
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      
                      const Spacer(),
                      
                      // Center the Schedule button
                      Center(
                        child: ActionButton(
                          label: 'Schedule',
                          icon: Icons.calendar_month,
                          onPressed: () {
                            widget.onSchedule();
                            // Refresh meetings after scheduling
                            Future.delayed(const Duration(milliseconds: 500), () {
                              _loadMeetings();
                            });
                          },
                          backgroundColor: const Color(0xFF2196F3), // Blue
                          scale: 0.9,
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
