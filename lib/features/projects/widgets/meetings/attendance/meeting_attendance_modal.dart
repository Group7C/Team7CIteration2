import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../../features/projects/models/project.dart';
import 'components/attendance_form.dart';
import 'components/upcoming_meeting_scheduler.dart';
import 'components/attendance_export.dart';
import '../../../models/meetings/meeting_attendance.dart';
import 'package:intl/intl.dart';
import '../../../../../services/meeting_service.dart';

class MeetingAttendanceModal extends StatefulWidget {
  final Project project;
  
  const MeetingAttendanceModal({
    Key? key,
    required this.project,
  }) : super(key: key);

  @override
  State<MeetingAttendanceModal> createState() => _MeetingAttendanceModalState();
}

class _MeetingAttendanceModalState extends State<MeetingAttendanceModal> {
  late DateTime _selectedDate;
  late DateTime? _upcomingMeetingDate;
  final Map<int, bool> _attendance = {};
  final TextEditingController _notesController = TextEditingController();
  
  // Track if the new meeting form is expanded
  bool _isNewMeetingExpanded = false;
  
  // For loading actual project members
  List<Map<String, dynamic>> _projectMembers = [];
  bool _isLoadingMembers = true;
  
  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _upcomingMeetingDate = null; // No upcoming meeting by default
    
    // Auto-expand new meeting form on open
    _isNewMeetingExpanded = true;
    
    // Test API connection
    _testApiConnection();
    
    // Load meeting dates
    _loadMeetingDates();
    
    // Load actual project members
    _loadProjectMembers();
  }
  
  // Load meeting dates from the server
  Future<void> _loadMeetingDates() async {
    try {
      final data = await MeetingService.getProjectMeetingDates(
        widget.project.id.toString(),
      );
      
      // Update the local state and project model
      setState(() {
        if (data['next_meeting_date'] != null) {
          _upcomingMeetingDate = DateTime.parse(data['next_meeting_date']);
        }
        
        // Update project model if it's a ChangeNotifier
        if (widget.project is ChangeNotifier) {
          if (data['next_meeting_date'] != null) {
            (widget.project as dynamic).updateNextMeetingDate(
              DateTime.parse(data['next_meeting_date']),
            );
          }
          
          if (data['last_meeting_date'] != null) {
            (widget.project as dynamic).updateLastMeetingDate(
              DateTime.parse(data['last_meeting_date']),
            );
          }
        }
      });
      
      print('Meeting dates loaded successfully');
    } catch (e) {
      print('Error loading meeting dates: $e');
    }
  }
  
  // Test connection to the meeting API
  Future<void> _testApiConnection() async {
    try {
      final isConnected = await MeetingService.testConnection();
      if (isConnected) {
        print('✅ Successfully connected to the meeting API');
      } else {
        print('⚠️ Failed to connect to the meeting API');
        // Show warning as snackbar
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Warning: Could not connect to the meeting API. Meeting data may not be saved.'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 5),
              ),
            );
          }
        });
      }
    } catch (e) {
      print('Error testing API connection: $e');
    }
  }
  
  // Load actual project members from the API
  Future<void> _loadProjectMembers() async {
    setState(() {
      _isLoadingMembers = true;
    });

    try {
      // First try to use the direct API endpoint
      print('Attempting to load members for project ${widget.project.id}');
      final response = await http.get(
        Uri.parse('http://127.0.0.1:5000/project/${widget.project.id}/members'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> memberData = json.decode(response.body);
        print('Loaded ${memberData.length} project members via API');
        
        if (memberData.isEmpty) {
          // If API returned no members, fall back to dummy data if we have it
          print('API returned empty members list, falling back to project members from widget');
          _fallbackToWidgetMembers();
          return;
        }
        
        setState(() {
          _projectMembers = memberData.map((member) => {
            'id': member['id'],
            'username': member['username'],
            'email': member['email'],
            'profile_picture': member['profile_picture'],
          }).toList();
          
          // Sort members alphabetically by username
          _projectMembers.sort((a, b) => 
            a['username'].toString().compareTo(b['username'].toString())
          );
          
          // Initialize attendance map with real members
          for (var member in _projectMembers) {
            _attendance[member['id']] = false;
          }
          
          _isLoadingMembers = false;
        });
      } else {
        print('Failed to load project members: ${response.statusCode}');
        _fallbackToWidgetMembers();
      }
    } catch (e) {
      print('Error loading members: $e');
      _fallbackToWidgetMembers();
    }
  }
  
  // Fallback to use project members from the widget
  void _fallbackToWidgetMembers() {
    setState(() {
      _isLoadingMembers = false;
      
      // Check if we have members in the project object
      if (widget.project.members != null && widget.project.members.isNotEmpty) {
        print('Using ${widget.project.members.length} members from widget');
        // Convert ProjectMember objects to the same format as API response
        _projectMembers = widget.project.members.map((member) => {
            'id': member.id,
            'username': member.username,
            'email': '', // Not available in ProjectMember
            'profile_picture': null, // Not available in ProjectMember
        }).toList();
        
        // Initialize attendance map
        for (var member in _projectMembers) {
          _attendance[member['id']] = false;
        }
      } else {
        // No members available at all, create at least a dummy entry for current user
        print('No members available, creating dummy member');
        _projectMembers = [
          {
            'id': 1,
            'username': 'Current User',
            'email': '',
            'profile_picture': null,
          }
        ];
        _attendance[1] = false;
      }
    });
  }
  
  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
  
  // Handle saving a meeting
  void _handleSaveMeeting(MeetingAttendance newMeeting) async {
    try {
      // Show loading indicator
      setState(() {
        _isLoadingMembers = true; // Reuse loading state for save operation
      });
      
      print('Attempting to save meeting for project ${widget.project.id}...');
      print('Attendance data: ${newMeeting.serializedAttendance}');
      
      // Call the API to save the meeting
      final meetingId = await MeetingService.createMeeting(
        projectId: widget.project.id.toString(),
        date: newMeeting.date,
        attendance: newMeeting.attendanceByMemberId, // Will be serialized in the service
        title: newMeeting.notes != null && newMeeting.notes!.isNotEmpty
            ? 'Meeting on ${DateFormat.yMMMd().format(newMeeting.date)}'
            : null,
        notes: newMeeting.notes,
        meetingType: 'Online', // Using valid enum value 'Online'
      );
      
      print('Meeting saved successfully with ID: $meetingId');
      
      // Also update the last meeting date in the project
      try {
        final success = await MeetingService.setLastMeetingDate(
          widget.project.id.toString(),
          newMeeting.date,
        );
        
        if (success) {
          print('Last meeting date updated successfully');
          // Update the project model if using state management
          if (widget.project is ChangeNotifier) {
            (widget.project as dynamic).updateLastMeetingDate(newMeeting.date);
          }
        } else {
          print('Failed to update last meeting date');
        }
      } catch (e) {
        print('Error updating last meeting date: $e');
      }
      
      // Reset the form for next time
      setState(() {
        _selectedDate = DateTime.now();
        
        // Reset attendance for all members
        for (var entry in _attendance.entries) {
          _attendance[entry.key] = false;
        }
        
        _notesController.clear();
        
        // Collapse the form after saving
        _isNewMeetingExpanded = false;
        _isLoadingMembers = false;
      });
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Meeting attendance saved with ID: $meetingId'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error details: $e');
      setState(() {
        _isLoadingMembers = false;
      });
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving meeting: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 10),
          action: SnackBarAction(
            label: 'Try Direct', 
            onPressed: () {
              _handleDirectSave(newMeeting);
            },
          ),
        ),
      );
    }
  }
  
  // Try a direct API call without the service layer as a fallback
  Future<void> _handleDirectSave(MeetingAttendance newMeeting) async {
    try {
      setState(() {
        _isLoadingMembers = true;
      });
      
      // Convert the attendance map to string keys for JSON serialization
      final Map<String, bool> serializedAttendance = {};
      newMeeting.attendanceByMemberId.forEach((key, value) {
        serializedAttendance[key.toString()] = value;
      });
      
      final requestData = {
        'project_id': widget.project.id.toString(),
        'date': newMeeting.date.toIso8601String(),
        'end_date': newMeeting.date.toIso8601String(), // Include end_date
        'notes': newMeeting.notes ?? '',
        'attendance': serializedAttendance,
        'meeting_type': 'Online', // Using valid enum value 'Online'
        'title': 'Meeting on ${DateFormat.yMMMd().format(newMeeting.date)}',
      };
      
      print('Trying direct API call to save meeting...');
      print('Data: ${json.encode(requestData)}');
      
      // Try different port as fallback
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/meetings'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestData),
      );
      
      print('Direct API call response status: ${response.statusCode}');
      print('Direct API call response body: ${response.body}');
      
      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final meetingId = responseData['meeting_id'];
        
        // Reset the form
        setState(() {
          _selectedDate = DateTime.now();
          for (var entry in _attendance.entries) {
            _attendance[entry.key] = false;
          }
          _notesController.clear();
          _isNewMeetingExpanded = false;
          _isLoadingMembers = false;
        });
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Meeting saved successfully via direct API call! ID: $meetingId'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed direct API call: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in direct save attempt: $e');
      setState(() {
        _isLoadingMembers = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Direct save failed: $e. Please check your backend server.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _handleScheduleChange(DateTime? date) async {
    // Update the upcoming meeting date when scheduler component changes
    setState(() {
      _upcomingMeetingDate = date;
    });
    
    // Save the date to the project
    if (date != null) {
      try {
        final success = await MeetingService.setUpcomingMeetingDate(
          widget.project.id.toString(),
          date,
        );
        
        if (success) {
          print('Next meeting date saved successfully');
          // Update the project model if using state management
          if (widget.project is ChangeNotifier) {
            (widget.project as dynamic).updateNextMeetingDate(date);
          }
        } else {
          print('Failed to save next meeting date');
        }
      } catch (e) {
        print('Error saving next meeting date: $e');
      }
    }
  }
  
  void _handleExport() {
    // Would generate CSV/PDF here in real version [future feature]
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Attendance report exported!'),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title bar with close button [modal header]
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Meeting Tracker',
                style: theme.textTheme.headlineSmall,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(
                  _upcomingMeetingDate != null 
                      ? DateFormat.yMMMd().format(_upcomingMeetingDate!) 
                      : null,
                ),
              ),
            ],
          ),
          const Divider(),
          
          // FIRST REGION: Record New Meeting (Collapsible)
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with expand/collapse button
                InkWell(
                  onTap: () {
                    setState(() {
                      _isNewMeetingExpanded = !_isNewMeetingExpanded;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.note_add, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'Record New Meeting',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        _isNewMeetingExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, 
                        color: theme.colorScheme.primary
                      ),
                    ],
                  ),
                ),
                
                // Expandable content
                if (_isNewMeetingExpanded) ...[  
                  const SizedBox(height: 16),
                  // Form for adding a new meeting [attendance record form]
                  _isLoadingMembers
                    ? const Center(child: CircularProgressIndicator())
                    : _buildAttendanceForm(theme),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // SECOND REGION: Schedule Next Meeting
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.secondary.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.event, color: theme.colorScheme.secondary),
                    const SizedBox(width: 8),
                    Text(
                      'Schedule Next Meeting',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Schedule upcoming meeting section [date picker for future meetings]
                UpcomingMeetingScheduler(
                  initialMeetingDate: _upcomingMeetingDate,
                  onScheduleChanged: _handleScheduleChange,
                ),
                if (_upcomingMeetingDate != null) ...[  
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Next meeting is scheduled',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          const Spacer(),
          
          // Export button at the bottom
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: AttendanceExport(
              onExport: _handleExport,
            ),
          ),
        ],
      ),
    );
  }
  
  // Custom attendance form with real project members
  Widget _buildAttendanceForm(ThemeData theme) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Attendance:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
                // Add toggle for all members
                TextButton.icon(
                  icon: Icon(Icons.check_circle_outline, size: 18),
                  label: Text('Toggle All'),
                  onPressed: () {
                    // Check if all members are already marked as present
                    bool allPresent = _projectMembers.every(
                      (member) => _attendance[member['id']] == true
                    );
                    
                    // Toggle all members' attendance status
                    setState(() {
                      for (var member in _projectMembers) {
                        _attendance[member['id']] = !allPresent;
                      }
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // List of actual members with checkboxes
            if (_projectMembers.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'No members found for this project.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Show member count
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      '${_projectMembers.length} member${_projectMembers.length != 1 ? "s" : ""} available',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  // Member list with checkboxes
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    height: _projectMembers.length > 6 ? 250 : null, // Scrollable if many members
                    child: ListView.builder(
                      shrinkWrap: _projectMembers.length <= 6,
                      itemCount: _projectMembers.length,
                      itemBuilder: (context, index) {
                        final member = _projectMembers[index];
                        // Ensure we have a valid member ID (default to index+1 if not present)
                        final memberId = member['id'] is int ? member['id'] : (index + 1);
                        // Initialize attendance for this member if not already set
                        if (!_attendance.containsKey(memberId)) {
                          _attendance[memberId] = false;
                        }
                        
                        return CheckboxListTile(
                          title: Text(
                            member['username'] ?? 'Unknown Member',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          secondary: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: member['profile_picture'] != null 
                              ? NetworkImage(member['profile_picture']) 
                              : null,
                            child: member['profile_picture'] == null 
                              ? Text(
                                  (member['username'] ?? 'U').toString().substring(0, 1).toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                )
                              : null,
                          ),
                          value: _attendance[memberId] ?? false,
                          onChanged: (value) => _toggleAttendance(memberId),
                          dense: true,
                          activeColor: theme.colorScheme.primary,
                        );
                      },
                    ),
                  ),
                ],
              ),
            
            const SizedBox(height: 16),
            
            // Notes box for meeting minutes/etc
            TextField(
              controller: _notesController,
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
                  backgroundColor: const Color(0xFF1E88E5), // Use the same blue color as other buttons
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Date picker method
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
  
  // Toggle attendance for member
  void _toggleAttendance(int memberId) {
    setState(() {
      _attendance[memberId] = !(_attendance[memberId] ?? false);
    });
  }
  
  // Save meeting with current data
  void _saveMeeting() {
    // Make a new attendance record with all our data
    final newMeeting = MeetingAttendance(
      date: _selectedDate,
      attendanceByMemberId: Map.from(_attendance),
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );
    
    // Send it back to parent [triggers the save]
    _handleSaveMeeting(newMeeting);
  }
}