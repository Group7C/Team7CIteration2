import 'package:flutter/material.dart';
import '../../../../../../features/projects/models/project.dart';
import '../models/member_contribution.dart';

class MemberContributionCard extends StatefulWidget {
  final ProjectMember member;
  final int totalTasks;
  final int completedTasks;
  final Color projectColor;
  final double? taskWeight;
  final double? attendanceWeight;
  
  const MemberContributionCard({
    Key? key,
    required this.member,
    required this.totalTasks,
    required this.completedTasks,
    required this.projectColor,
    this.taskWeight,
    this.attendanceWeight,
  }) : super(key: key);
  
  @override
  State<MemberContributionCard> createState() => _MemberContributionCardState();
}

class _MemberContributionCardState extends State<MemberContributionCard> {
  bool _isExpanded = false;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Work out percentage done [for colours and display]
    final completionPercentage = widget.totalTasks > 0 
        ? (widget.completedTasks / widget.totalTasks) * 100 
        : 0.0;
    
    // Pick colour based on how much they've done
    final progressColour = MemberContribution.getProgressColour(completionPercentage);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section that's always visible
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // User icon with first letter [coloured by role]
                  CircleAvatar(
                    backgroundColor: widget.member.isOwner ? widget.projectColor : Colors.grey[300],
                    child: Text(
                      widget.member.username.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: widget.member.isOwner ? Colors.white : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Name and role
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.member.username,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            // Star icon for owners
                            if (widget.member.isOwner) ... [
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                            ],
                          ],
                        ),
                        Text(
                          widget.member.isOwner ? 'Owner' : widget.member.role,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Percentage bubble [visual progress indicator]
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: progressColour.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${completionPercentage.round()}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: progressColour,
                      ),
                    ),
                  ),
                  
                  // Expand/collapse icon
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ],
              ),
            ),
          ),
          
          // Collapsible content
          AnimatedCrossFade(
            firstChild: const SizedBox(height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress bar [shows task completion]
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: widget.totalTasks > 0 ? widget.completedTasks / widget.totalTasks : 0,
                      minHeight: 8,
                      backgroundColor: theme.colorScheme.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(progressColour),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Task count text [x of y done]
                  Text(
                    '${widget.completedTasks} of ${widget.totalTasks} tasks completed',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                  
                  // Show contribution breakdown if we have the data
                  if (widget.taskWeight != null && widget.attendanceWeight != null) ... [
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Contribution Breakdown',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Tasks (90%):'),
                              Text(
                                '${widget.taskWeight!.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Attendance (10%):'),
                              Text(
                                '${widget.attendanceWeight!.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Contribution:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${(widget.taskWeight! + widget.attendanceWeight!).toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}