import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../../features/projects/models/project.dart';
import '../../../../models/meetings/meeting_attendance.dart';

class AttendanceForm extends StatefulWidget {
  final Project project;
  final DateTime initialDate;
  final Map<int, bool> initialAttendance;
  final TextEditingController notesController;
  final Function(MeetingAttendance) onSave;
  
  const AttendanceForm({
    Key? key,
    required this.project,
    required this.initialDate,
    required this.initialAttendance,
    required this.notesController,
    required this.onSave,
  }) : super(key: key);

  @override
  State<AttendanceForm> createState() => _AttendanceFormState();
}

class _AttendanceFormState extends State<AttendanceForm> {
  late DateTime _selectedDate;
  late Map<int, bool> _attendance;
  
  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _attendance = Map.from(widget.initialAttendance);
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  
  void _toggleAttendance(int memberId) {
    setState(() {
      _attendance[memberId] = !(_attendance[memberId] ?? false);
    });
  }
  
  void _saveMeeting() {
    // Make a new attendance record with all our data
    final newMeeting = MeetingAttendance(
      date: _selectedDate,
      attendanceByMemberId: Map.from(_attendance),
      notes: widget.notesController.text.isNotEmpty ? widget.notesController.text : null,
    );
    
    // Send it back to parent [triggers the save]
    widget.onSave(newMeeting);
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Record New Meeting',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Date selector for the meeting
            Row(
              children: [
                Icon(Icons.calendar_today, 
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Meeting Date:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => _selectDate(context),
                  child: Text(
                    DateFormat.yMMMd().format(_selectedDate),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            Text(
              'Attendance:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 8),
            
            // List of members with checkboxes [checkbox = bool for attendance]
            ...widget.project.members.map((member) => 
              CheckboxListTile(
                title: Text(member.username),
                secondary: CircleAvatar(
                  radius: 14,
                  backgroundColor: member.isOwner ? widget.project.colour : Colors.grey[300],
                  child: Text(
                    member.username.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      color: member.isOwner ? Colors.white : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                value: _attendance[member.id] ?? false,
                onChanged: (value) => _toggleAttendance(member.id),
                dense: true,
                activeColor: theme.colorScheme.primary,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Notes box for meeting minutes/etc
            TextField(
              controller: widget.notesController,
              decoration: const InputDecoration(
                labelText: 'Meeting Notes',
                hintText: 'Enter any notes about this meeting...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: _saveMeeting,
                icon: const Icon(Icons.save),
                label: const Text('Save Meeting'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}