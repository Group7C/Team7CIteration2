import 'package:flutter/material.dart';
import '../../../../../models/meetings/meeting.dart';
import '../../../../../services/meeting_service.dart';
import 'meeting_list_item.dart';

/// Widget to display a list of meetings for a project
class MeetingsList extends StatefulWidget {
  final String projectId;
  final Function(Meeting)? onMeetingSelected;
  
  const MeetingsList({
    Key? key,
    required this.projectId,
    this.onMeetingSelected,
  }) : super(key: key);

  @override
  State<MeetingsList> createState() => _MeetingsListState();
}

class _MeetingsListState extends State<MeetingsList> {
  bool _isLoading = true;
  List<Meeting> _meetings = [];
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _loadMeetings();
  }
  
  /// Load meetings for this project
  Future<void> _loadMeetings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final meetings = await MeetingService.getProjectMeetings(widget.projectId);
      setState(() {
        _meetings = meetings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load meetings: $e';
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Show loading spinner while fetching data
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    // Show error message if loading failed
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _errorMessage!,
              style: TextStyle(color: theme.colorScheme.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMeetings,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    // Show empty state if no meetings
    if (_meetings.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today,
              size: 48,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No meetings recorded yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Use the Meeting Tracker to record your first meeting',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    // Show list of meetings
    return RefreshIndicator(
      onRefresh: _loadMeetings,
      child: ListView.separated(
        itemCount: _meetings.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final meeting = _meetings[index];
          return MeetingListItem(
            meeting: meeting,
            onTap: () {
              if (widget.onMeetingSelected != null) {
                widget.onMeetingSelected!(meeting);
              }
            },
          );
        },
      ),
    );
  }
}