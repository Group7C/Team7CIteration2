import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/meeting_form_controller.dart';
import '../../../features/common/models/project_model.dart';
import '../../../features/tasks/widgets/date_picker_field.dart';
import '../../../models/meetings/meeting.dart';

class MeetingTabsWidget extends StatefulWidget {
  final Project project;
  final VoidCallback? onMeetingCreated;
  
  const MeetingTabsWidget({
    Key? key,
    required this.project,
    this.onMeetingCreated,
  }) : super(key: key);

  @override
  State<MeetingTabsWidget> createState() => _MeetingTabsWidgetState();
}

class _MeetingTabsWidgetState extends State<MeetingTabsWidget> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late MeetingFormController _controller;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _controller = MeetingFormController();
    
    // Initialize the controller with default values
    _controller.initDefaults();
    _controller.initAttendanceFromMembers(widget.project.members);
    
    // Load scheduled meetings when tab switches to Record
    _tabController.addListener(_onTabChanged);
    
    // Load scheduled meetings initially if on Record tab
    if (_tabController.index == 1) {
      _loadScheduledMeetings();
    }
  }
  
  void _onTabChanged() {
    if (_tabController.index == 1) { // Record tab
      _loadScheduledMeetings();
    }
  }
  
  Future<void> _loadScheduledMeetings() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    
    try {
      await _controller.loadScheduledMeetings(widget.project.projectUid);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 450, // Fixed height to ensure proper rendering
      child: Column(
        children: [
          // Tab bar
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.blue,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(
                icon: Icon(Icons.calendar_month),
                text: 'Schedule Meeting',
              ),
              Tab(
                icon: Icon(Icons.history),
                text: 'Record Attendance',
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Schedule Meeting Form
                _buildScheduleMeetingForm(),
                
                // Record Meeting Form
                _buildRecordMeetingForm(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Schedule Meeting Form
  Widget _buildScheduleMeetingForm() {
    final theme = Theme.of(context);
    
    return Form(
      key: _controller.scheduleFormKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meeting Title
            Text('Meeting Title', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _controller.titleController,
              focusNode: _controller.titleFocusNode,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter meeting title',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                filled: true,
                fillColor: const Color(0xFF3A3D42),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Meeting title cannot be empty';
                }
                return null;
              },
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(_controller.dateFocusNode);
              },
            ),
            
            const SizedBox(height: 24),
            
            // Meeting Date
            Text('Meeting Date', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white)),
            const SizedBox(height: 8),
            DatePickerField(
              controller: _controller.dateController,
              focusNode: _controller.dateFocusNode,
              onDateSelected: (selectedDate) {},
            ),
            
            const SizedBox(height: 32),
            
            // Submit Button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _controller.initDefaults();
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white54),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Reset'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () async {
                    // Show loading indicator
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Scheduling meeting...'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                    
                    final success = await _controller.scheduleMeeting(widget.project.projectUid);
                    if (success && mounted) {
                      if (widget.onMeetingCreated != null) {
                        widget.onMeetingCreated!();
                      }
                      // Show a success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Meeting scheduled successfully'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      Navigator.of(context).pop();
                    } else if (mounted) {
                      // Show an error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to schedule meeting'),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Schedule Meeting'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // Record Meeting Form - updated to use dropdown instead of text fields
  Widget _buildRecordMeetingForm() {
    final theme = Theme.of(context);
    
    // Show loading indicator while fetching meetings
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    // Show message if no scheduled meetings
    if (_controller.scheduledMeetings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              color: Colors.white70,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'No scheduled meetings found',
              style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Please schedule a meeting first',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                _tabController.animateTo(0); // Switch to Schedule tab
              },
              icon: const Icon(Icons.add),
              label: const Text('Schedule a Meeting'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
            ),
          ],
        ),
      );
    }
    
    return Form(
      key: _controller.recordFormKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meeting Dropdown
            Text('Select Meeting to Record Attendance', 
              style: theme.textTheme.titleMedium?.copyWith(color: Colors.white)),
            const SizedBox(height: 12),
            
            // Dropdown for selecting a meeting
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF3A3D42),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Meeting>(
                  isExpanded: true,
                  value: _controller.selectedMeeting,
                  hint: Text(
                    'Select a scheduled meeting',
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                  dropdownColor: const Color(0xFF2D3035),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (Meeting? newValue) {
                    setState(() {
                      _controller.selectMeeting(newValue);
                    });
                  },
                  items: _controller.scheduledMeetings
                      .map<DropdownMenuItem<Meeting>>((Meeting meeting) {
                    return DropdownMenuItem<Meeting>(
                      value: meeting,
                      child: Text(
                        '${meeting.title} (${DateFormat('MMM d, yyyy').format(meeting.date)})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Attendance Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Attendance',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.project.members.isNotEmpty)
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            for (var member in widget.project.members) {
                              _controller.attendanceMap[member.membersId.toString()] = true;
                            }
                          });
                        },
                        child: const Text('Select All'),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            for (var member in widget.project.members) {
                              _controller.attendanceMap[member.membersId.toString()] = false;
                            }
                          });
                        },
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Attendance checkboxes with improved visual feedback
            ...widget.project.members.map((member) => _buildAttendanceCheckbox(member)),
            
            const SizedBox(height: 32),
            
            // Submit Button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _controller.initAttendanceFromMembers(widget.project.members);
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white54),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Reset'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _controller.selectedMeeting == null
                      ? null // Disable button if no meeting selected
                      : () async {
                          // Show loading indicator
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Recording attendance...'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                          
                          // Record attendance
                          final success = await _controller.recordMeeting(widget.project.projectUid);
                          if (success && mounted) {
                            if (widget.onMeetingCreated != null) {
                              widget.onMeetingCreated!();
                            }
                            // Show a success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Meeting attendance recorded successfully'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            Navigator.of(context).pop();
                          } else if (mounted) {
                            // Show an error message
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to record meeting attendance'),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey,
                  ),
                  child: const Text('Record Attendance'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // Attendance checkbox widget with visual feedback
  Widget _buildAttendanceCheckbox(ProjectMember member) {
    final isChecked = _controller.attendanceMap[member.membersId.toString()] ?? false;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isChecked ? Colors.blue.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isChecked ? Colors.blue : Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: CheckboxListTile(
        title: Text(
          member.username ?? 'Unknown User',
          style: TextStyle(
            color: Colors.white,
            fontWeight: isChecked ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          member.isOwner ? 'Owner' : member.memberRole,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7), 
            fontSize: 12,
          ),
        ),
        value: isChecked,
        onChanged: (value) {
          setState(() {
            _controller.toggleAttendance(member.membersId);
          });
        },
        activeColor: Colors.blue,
        checkColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        dense: true,
        controlAffinity: ListTileControlAffinity.leading,
        secondary: isChecked 
          ? const Icon(Icons.check_circle, color: Colors.blue, size: 20)
          : null,
      ),
    );
  }
}