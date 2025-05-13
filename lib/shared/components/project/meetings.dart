import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../container_template.dart';
import '../action_button.dart';
import '../../../projects/project_model.dart';
import '../small_modal.dart';
import '../date_picker_field.dart';
import '../../../services/meeting_services.dart';
import '../../../providers/projects_provider.dart';
import '../../../usser/usserObject.dart';

// manages project meetings display and operations
// [schedule, record, and view project meetings]
class MeetingsComponent extends StatefulWidget {
  final Project? project;
  
  const MeetingsComponent({super.key, this.project});

  @override
  State<MeetingsComponent> createState() => _MeetingsComponentState();
}

class _MeetingsComponentState extends State<MeetingsComponent> {
  // controllers for date picker
  final TextEditingController _scheduleDateController = TextEditingController();
  final FocusNode _scheduleDateFocusNode = FocusNode();
  DateTime? _selectedRecordDate;
  Map<String, bool> _selectedMembers = {};
  Map<int, String> _memberIdMap = {}; // maps member IDs to usernames
  TimeOfDay? _selectedTime = TimeOfDay.now();
  List<Map<String, dynamic>> _projectMeetings = []; // meetings list for dropdown
  int? _selectedMeetingId; // selected meeting for attendance
  
  @override
  void initState() {
    super.initState();
    _loadProjectMeetings();
  }
  
  @override
  void didUpdateWidget(MeetingsComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    // reload meetings when project changes
    if (widget.project?.projectUid != oldWidget.project?.projectUid) {
      _loadProjectMeetings();
    }
  }
  
  // finds next upcoming meeting from meetings list
  DateTime? _getNextMeetingFromList() {
    if (_projectMeetings.isEmpty) return null;
    
    final now = DateTime.now();
    final futureMeetings = _projectMeetings.where((meeting) {
      final date = _parseMeetingDate(meeting['start_date'].toString());
      return date != null && date.isAfter(now);
    }).toList();
    
    if (futureMeetings.isEmpty) return null;
    
    // sort by date to find earliest
    futureMeetings.sort((a, b) {
      final dateA = _parseMeetingDate(a['start_date'].toString());
      final dateB = _parseMeetingDate(b['start_date'].toString());
      if (dateA == null || dateB == null) return 0;
      return dateA.compareTo(dateB);
    });
    
    return _parseMeetingDate(futureMeetings.first['start_date'].toString());
  }
  
  // gets complete meeting data for next meeting
  Map<String, dynamic>? _findNextMeetingData() {
    if (_projectMeetings.isEmpty) return null;
    
    final now = DateTime.now();
    final futureMeetings = _projectMeetings.where((meeting) {
      final date = _parseMeetingDate(meeting['start_date'].toString());
      return date != null && date.isAfter(now);
    }).toList();
    
    if (futureMeetings.isEmpty) return null;
    
    // sort by date to find earliest
    futureMeetings.sort((a, b) {
      final dateA = _parseMeetingDate(a['start_date'].toString());
      final dateB = _parseMeetingDate(b['start_date'].toString());
      if (dateA == null || dateB == null) return 0;
      return dateA.compareTo(dateB);
    });
    
    return futureMeetings.first;
  }
  
  // safely parses meeting date from api format
  DateTime? _parseMeetingDate(String dateString) {
    try {
      if (dateString.contains(',')) {
        String datePart = dateString.split(',')[1].trim().split(' 00:00:00')[0];
        return DateFormat('dd MMM yyyy').parse(datePart);
      }
    } catch (e) {
      // handle parse errors silently
    }
    return null;
  }
  
  @override
  void dispose() {
    _scheduleDateController.dispose();
    _scheduleDateFocusNode.dispose();
    super.dispose();
  }
  
  // fetches meeting data from api
  void _loadProjectMeetings() async {
    if (widget.project?.projectUid != null) {
      final meetings = await MeetingServices.getProjectMeetings(widget.project!.projectUid!);
      setState(() {
        _projectMeetings = meetings;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // initialise attendance tracking map
    if (widget.project != null && _selectedMembers.isEmpty) {
      widget.project!.members.forEach((username, role) {
        _selectedMembers[username] = false;
      });
    }
    
    // determine next meeting details from either source
    DateTime? nextMeeting;
    String? nextMeetingSubject;
    String? nextMeetingType;
    
    if (widget.project?.nextMeeting != null) {
      try {
        nextMeeting = DateTime.parse(widget.project!.nextMeeting!['start_date']);
        nextMeetingSubject = widget.project!.nextMeeting!['subject'];
        nextMeetingType = widget.project!.nextMeeting!['meeting_type'];
      } catch (e) {
        // handle parse errors silently
      }
    } else {
      // fallback: find next meeting from loaded meetings list
      nextMeeting = _getNextMeetingFromList();
      if (nextMeeting != null && _projectMeetings.isNotEmpty) {
        final nextMeetingData = _findNextMeetingData();
        if (nextMeetingData != null) {
          nextMeetingSubject = nextMeetingData['subject'];
          nextMeetingType = nextMeetingData['meeting_type'];
        }
      }
    }
    
    // for last meeting, need to add this to backend later
    DateTime? lastMeeting = null;  // project?.lastMeeting
    
    // placeholder when no project selected
    if (widget.project == null) {
      return ContainerTemplate(
        title: 'Meetings',
        height: 250,
        child: Center(
          child: Text(
            'Select a project to view meetings',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }
    
    return ContainerTemplate(
      title: 'Meetings',
      height: 250,
      description: 'Meeting schedule for ${widget.project?.projectName ?? 'project'}',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // last meeting info row [shows past meeting]
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                Icons.access_time,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Last Meeting: ',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                lastMeeting != null
                    ? DateFormat('dd/MM/yyyy HH:mm').format(lastMeeting)
                    : 'No meetings yet',
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // next meeting info row [shows upcoming meeting]
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                Icons.calendar_today,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Next Meeting: ',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: Text(
                  nextMeeting != null
                      ? '${DateFormat('dd/MM/yyyy').format(nextMeeting)}${nextMeetingSubject != null ? ' - $nextMeetingSubject' : ''}${nextMeetingType != null ? ' ($nextMeetingType)' : ''}'
                      : 'No scheduled meetings',
                  style: theme.textTheme.bodyLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // action buttons for meeting management
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // schedule meeting button [opens calendar picker]
                Flexible(
                  child: ActionButton(
                    label: 'Schedule',
                    icon: Icons.calendar_month,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return StatefulBuilder(
                            builder: (context, setState) {
                              return SmallModal(
                                title: 'Schedule Meeting',
                                showCloseButton: false,
                                showActionButtons: false,
                                content: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Select a date for the meeting:',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    const SizedBox(height: 16),
                                    DatePickerField(
                                      controller: _scheduleDateController,
                                      focusNode: _scheduleDateFocusNode,
                                      onDateSelected: (selectedDate) {
                                        setState(() {});
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Select time:',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    // time picker field
                                    InkWell(
                                      onTap: () async {
                                        final TimeOfDay? picked = await showTimePicker(
                                          context: context,
                                          initialTime: _selectedTime ?? TimeOfDay.now(),
                                        );
                                        if (picked != null) {
                                          setState(() {
                                            _selectedTime = picked;
                                          });
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: theme.colorScheme.outline),
                                          borderRadius: BorderRadius.circular(8),
                                          color: theme.colorScheme.surface,
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              _selectedTime != null 
                                                ? _selectedTime!.format(context)
                                                : 'Select time',
                                              style: theme.textTheme.bodyLarge,
                                            ),
                                            const Icon(Icons.access_time),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    // action buttons
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(),
                                          child: const Text('Cancel'),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          onPressed: () async {
                                            if (_scheduleDateController.text.isNotEmpty && _selectedTime != null) {
                                              final currentProject = widget.project;
                                              if (currentProject == null || currentProject.projectUid == null) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('Invalid project'),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                                return;
                                              }
                                              
                                              // combine date and time
                                              DateTime meetingDate = DateTime.parse(_scheduleDateController.text);
                                              DateTime meetingDateTime = DateTime(
                                                meetingDate.year,
                                                meetingDate.month,
                                                meetingDate.day,
                                                _selectedTime!.hour,
                                                _selectedTime!.minute,
                                              );
                                              
                                              // call api to create meeting
                                              final result = await MeetingServices.scheduleMeeting(
                                                currentProject.projectUid!,
                                                meetingDateTime,
                                              );
                                              
                                              if (result['success'] == true) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Meeting scheduled for ${_scheduleDateController.text} at ${_selectedTime!.format(context)}'),
                                                  ),
                                                );
                                                Navigator.of(context).pop();
                                                _scheduleDateController.clear();
                                                _selectedTime = TimeOfDay.now();
                                                
                                                // refresh meetings data
                                                _loadProjectMeetings();
                                                
                                                // trigger project refresh
                                                await context.read<ProjectsProvider>().fetchProjects(context.read<Usser>().usserID);
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Failed to schedule meeting: ${result['error'] ?? 'Unknown error'}'),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Please select both date and time'),
                                                  backgroundColor: Colors.orange,
                                                ),
                                              );
                                            }
                                          },
                                          child: const Text('Confirm Meeting'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // record attendance button [tracks who attended meeting]
                Flexible(
                  child: ActionButton(
                    label: 'Record',
                    icon: Icons.videocam,
                    isPrimary: false,
                    onPressed: () {
                      final currentProject = widget.project;
                      if (currentProject == null) return;
                      
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return StatefulBuilder(
                            builder: (context, setState) {
                              return SmallModal(
                                title: 'Record Meeting',
                                showCloseButton: false,
                                showActionButtons: false,
                                content: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Select meeting date:',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    // meeting selection dropdown
                                    DropdownButtonFormField<int>(
                                      value: _selectedMeetingId,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: theme.colorScheme.surface,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      hint: const Text('Select a meeting'),
                                      items: _projectMeetings.map((meeting) {
                                        // safely parse date for display
                                        String dateStr = 'No date';
                                        try {
                                          if (meeting['start_date'] != null) {
                                            String dateString = meeting['start_date'].toString();
                                            
                                            DateTime? date = _parseMeetingDate(dateString);
                                            if (date != null) {
                                              dateStr = DateFormat('dd/MM/yyyy').format(date);
                                            } else {
                                              // fallback: extract readable date if parsing fails
                                              if (dateString.contains(',') && dateString.contains(' ')) {
                                                List<String> parts = dateString.split(',');
                                                if (parts.length > 1) {
                                                  dateStr = parts[1].trim().split(' 00:00:00')[0];
                                                }
                                              }
                                            }
                                          }
                                        } catch (e) {
                                          print('Error parsing date: ${meeting['start_date']}, error: $e');
                                        }
                                        
                                        return DropdownMenuItem<int>(
                                          value: meeting['meeting_id'],
                                          child: Text(
                                            '${meeting['subject'] ?? 'Meeting'} - $dateStr',
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedMeetingId = value;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Select attendees:',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    // scrollable member list with checkboxes
                                    Container(
                                      constraints: const BoxConstraints(maxHeight: 200),
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children: currentProject.members.entries.map((entry) {
                                            return CheckboxListTile(
                                              title: Text(entry.key),
                                              subtitle: Text(entry.value),
                                              value: _selectedMembers[entry.key] ?? false,
                                              onChanged: (bool? value) {
                                                setState(() {
                                                  _selectedMembers[entry.key] = value ?? false;
                                                });
                                              },
                                              controlAffinity: ListTileControlAffinity.leading,
                                              dense: true,
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    // action buttons
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(),
                                          child: const Text('Cancel'),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          onPressed: () async {
                                            if (_selectedMeetingId != null) {
                                              // collect selected attendees
                                              final selectedMemberIds = <int>[];
                                              
                                              _selectedMembers.forEach((username, isSelected) {
                                                if (isSelected) {
                                                  // find member id from username
                                                  final member = currentProject.getMemberByUsername(username);
                                                  if (member != null) {
                                                    selectedMemberIds.add(member.membersId);
                                                  }
                                                }
                                              });
                                              
                                              if (selectedMemberIds.isEmpty) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('Please select at least one attendee'),
                                                    backgroundColor: Colors.orange,
                                                  ),
                                                );
                                                return;
                                              }
                                              
                                              // record attendance via api
                                              final result = await MeetingServices.recordAttendance(
                                                _selectedMeetingId!,
                                                selectedMemberIds,
                                              );
                                              
                                              if (result['success'] == true) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Meeting attendance recorded for ${selectedMemberIds.length} members'),
                                                  ),
                                                );
                                                Navigator.of(context).pop();
                                                
                                                // reset selections
                                                _selectedMeetingId = null;
                                                _selectedMembers.forEach((key, value) {
                                                  _selectedMembers[key] = false;
                                                });
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Failed to record attendance: ${result['error'] ?? 'Unknown error'}'),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Please select a meeting'),
                                                  backgroundColor: Colors.orange,
                                                ),
                                              );
                                            }
                                          },
                                          child: const Text('Submit'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}