import 'package:flutter/material.dart';
import '../../../../models/meetings/meeting.dart';
import '../../../../services/meeting_service.dart';
import 'package:intl/intl.dart';

/// Screen to display detailed information about a meeting [meeting details view]
class MeetingDetailsScreen extends StatefulWidget {
  final int meetingId;
  
  const MeetingDetailsScreen({
    Key? key,
    required this.meetingId,
  }) : super(key: key);
  
  @override
  State<MeetingDetailsScreen> createState() => _MeetingDetailsScreenState();
}

class _MeetingDetailsScreenState extends State<MeetingDetailsScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _meetingDetails;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMeetingDetails();
  }
  
  /// Load meeting details
  Future<void> _loadMeetingDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final details = await MeetingService.getMeetingDetails(widget.meetingId.toString());
      setState(() {
        _meetingDetails = details;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load meeting details: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting Details'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView(theme)
              : _buildMeetingDetails(theme),
    );
  }
  
  Widget _buildErrorView(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: TextStyle(color: theme.colorScheme.error),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadMeetingDetails,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMeetingDetails(ThemeData theme) {
    if (_meetingDetails == null) {
      return const Center(child: Text('Meeting details not available'));
    }
    
    // Parse date
    final DateTime date = DateTime.parse(_meetingDetails!['date']);
    final String formattedDate = DateFormat.yMMMMd().format(date);
    final String formattedTime = DateFormat.jm().format(date);
    
    // Get attendance info
    final int attendedCount = _meetingDetails!['attended_count'] ?? 0;
    final int totalMembers = _meetingDetails!['total_members'] ?? 0;
    final double attendanceRate = totalMembers > 0 
        ? (attendedCount / totalMembers) * 100 
        : 0.0;
    
    // Get notes
    final String? notes = _meetingDetails!['notes'];
    
    // Get project info
    final String projectName = _meetingDetails!['project_name'] ?? 'Unknown Project';
    
    // Get attendees
    final List<dynamic> attendees = _meetingDetails!['attendees'] ?? [];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meeting header card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    _meetingDetails!['title'] ?? 'Meeting on $formattedDate',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  
                  // Project name
                  Row(
                    children: [
                      Icon(Icons.folder, size: 16, color: theme.colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Project: $projectName',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  // Date and time
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: theme.colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        '$formattedDate at $formattedTime',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Attendance summary
                  Row(
                    children: [
                      Icon(
                        Icons.people, 
                        size: 20, 
                        color: theme.colorScheme.secondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Attendance: $attendedCount of $totalMembers members',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Attendance progress bar
                  LinearProgressIndicator(
                    value: totalMembers > 0 ? attendedCount / totalMembers : 0,
                    backgroundColor: theme.colorScheme.surfaceVariant,
                    color: _getAttendanceColor(attendanceRate),
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  const SizedBox(height: 4),
                  
                  // Attendance percentage
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${attendanceRate.toStringAsFixed(1)}%',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getAttendanceColor(attendanceRate),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Meeting notes section
          Text(
            'Meeting Notes',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: notes != null && notes.isNotEmpty
                  ? Text(notes)
                  : const Text(
                      'No notes were recorded for this meeting.',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Attendees section
          Text(
            'Attendees',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: attendees.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final attendee = attendees[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: attendee['profile_picture'] != null 
                        ? NetworkImage(attendee['profile_picture']) 
                        : null,
                    child: attendee['profile_picture'] == null 
                        ? Text(attendee['username'][0].toUpperCase())
                        : null,
                  ),
                  title: Text(attendee['username']),
                );
              },
            ),
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }
  
  // Get color based on attendance rate
  Color _getAttendanceColor(double percentage) {
    if (percentage >= 80) {
      return Colors.green;
    } else if (percentage >= 50) {
      return Colors.amber;
    } else {
      return Colors.red;
    }
  }
}