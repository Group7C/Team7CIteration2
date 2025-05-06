import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/project.dart';
import '../../../../services/meeting_service.dart';
import '../../../common/widgets/loading_indicator.dart';

/// A mini widget showing meeting info for the project dashboard
class MeetingsMiniWidget extends StatefulWidget {
  final Project project;
  final VoidCallback onScheduleMeeting;
  
  const MeetingsMiniWidget({
    Key? key,
    required this.project,
    required this.onScheduleMeeting,
  }) : super(key: key);

  @override
  State<MeetingsMiniWidget> createState() => _MeetingsMiniWidgetState();
}

class _MeetingsMiniWidgetState extends State<MeetingsMiniWidget> {
  bool _isLoading = true;
  DateTime? _lastMeetingDate;
  DateTime? _nextMeetingDate;
  
  @override
  void initState() {
    super.initState();
    _loadMeetingDates();
  }
  
  Future<void> _loadMeetingDates() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Use stored dates from project model if available
      if (widget.project.lastMeetingDate != null || widget.project.nextMeetingDate != null) {
        setState(() {
          _lastMeetingDate = widget.project.lastMeetingDate;
          _nextMeetingDate = widget.project.nextMeetingDate;
          _isLoading = false;
        });
        return;
      }
      
      // Otherwise fetch from API
      final data = await MeetingService.getProjectMeetingDates(
        widget.project.id.toString(),
      );
      
      setState(() {
        _lastMeetingDate = data['last_meeting_date'] != null
            ? DateTime.parse(data['last_meeting_date'])
            : null;
        _nextMeetingDate = data['next_meeting_date'] != null
            ? DateTime.parse(data['next_meeting_date'])
            : null;
        _isLoading = false;
        
        // Update the project model
        if (widget.project is ChangeNotifier) {
          if (_lastMeetingDate != null) {
            (widget.project as dynamic).updateLastMeetingDate(_lastMeetingDate);
          }
          if (_nextMeetingDate != null) {
            (widget.project as dynamic).updateNextMeetingDate(_nextMeetingDate);
          }
        }
      });
    } catch (e) {
      print('Error loading meeting dates: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Header with button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.groups,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Meetings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: widget.onScheduleMeeting,
                icon: const Icon(Icons.event, size: 16),
                label: const Text('Schedule Meeting'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Last meeting info
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: LoadingIndicator(size: 20),
            )
          else
            Column(children: [
              Row(
                children: [
                  const Icon(
                    Icons.history,
                    size: 16,
                    color: Colors.blueAccent,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Last meeting: ',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    _lastMeetingDate == null
                        ? 'Not recorded'
                        : DateFormat.yMMMd().format(_lastMeetingDate!),
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.event_available,
                    size: 16,
                    color: Colors.lightBlueAccent,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _nextMeetingDate == null
                        ? 'No upcoming meetings'
                        : '${DateFormat.yMMMd().format(_nextMeetingDate!)}',
                    style: TextStyle(
                      color: _nextMeetingDate == null
                          ? Colors.white.withOpacity(0.7)
                          : Colors.white,
                      fontStyle: _nextMeetingDate == null
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),
                ],
              ),
            ]),
        ],
      ),
    );
  }
}
