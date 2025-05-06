import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UpcomingMeetingScheduler extends StatefulWidget {
  final DateTime? initialMeetingDate;
  final Function(DateTime?) onScheduleChanged;
  
  const UpcomingMeetingScheduler({
    Key? key,
    this.initialMeetingDate,
    required this.onScheduleChanged,
  }) : super(key: key);

  @override
  State<UpcomingMeetingScheduler> createState() => _UpcomingMeetingSchedulerState();
}

class _UpcomingMeetingSchedulerState extends State<UpcomingMeetingScheduler> {
  DateTime? _upcomingMeetingDate;
  
  @override
  void initState() {
    super.initState();
    _upcomingMeetingDate = widget.initialMeetingDate;
  }
  
  @override
  void didUpdateWidget(UpcomingMeetingScheduler oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update if the initial date changes from outside
    if (widget.initialMeetingDate != oldWidget.initialMeetingDate) {
      setState(() {
        _upcomingMeetingDate = widget.initialMeetingDate;
      });
    }
  }
  
  Future<void> _selectUpcomingMeetingDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _upcomingMeetingDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        _upcomingMeetingDate = picked;
      });
      
      // Tell parent component we picked a date [updates parent state]
      widget.onScheduleChanged(picked);
      
      // Let user know scheduling worked with green snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Upcoming meeting scheduled'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.event_available, 
              color: theme.colorScheme.secondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Next Meeting:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => _selectUpcomingMeetingDate(context),
              child: Text(
                _upcomingMeetingDate == null
                  ? 'Not scheduled'
                  : DateFormat.yMMMd().format(_upcomingMeetingDate!),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _upcomingMeetingDate == null
                    ? theme.colorScheme.error.withOpacity(0.8)
                    : theme.colorScheme.secondary,
                ),
              ),
            ),
          ],
        ),
        if (_upcomingMeetingDate != null) 
          Center(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.cancel),
              label: const Text('Cancel Upcoming Meeting'),
              onPressed: () {
                setState(() {
                  _upcomingMeetingDate = null;
                });
                // Tell parent we've cancelled the meeting [clears date in parent]
                widget.onScheduleChanged(null);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Upcoming meeting cancelled'),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}