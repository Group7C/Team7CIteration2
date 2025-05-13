import 'package:flutter/material.dart';
import '../Objects/task.dart';
import '../projects/project_model.dart';
import '../services/meeting_services.dart';
import '../providers/tasks_provider.dart';

// calculates contribution percentages for project members
// based on task completion and meeting attendance
class ContributionReport {
  // stores final contribution percentages for each member
  final Map<String, double> memberContributions = {};
  
  // constructor initialises empty report
  ContributionReport();
  
  // calculates contribution for all members in a project
  // returns map of username -> contribution percentage
  Future<Map<String, double>> calculateProjectContribution(
    Project project,
    List<Task> tasks,
  ) async {
    // clear any previous calculations
    memberContributions.clear();
    
    // initialise all project members with 0% contribution
    for (var member in project.membersList) {
      memberContributions[member.username] = 0.0;
    }
    
    // get all meetings for this project - handle missing projectUid
    List<Map<String, dynamic>> meetings = [];
    if (project.projectUid != null) {
      try {
        meetings = await MeetingServices.getProjectMeetings(project.projectUid!);
      } catch (e) {
        print('Error fetching meetings: $e');
        // continue with empty meetings list
      }
    }
    
    // determine weighting based on meeting existence
    final double taskWeightPercentage = meetings.isEmpty ? 100.0 : 90.0;
    final double meetingWeightPercentage = meetings.isEmpty ? 0.0 : 10.0;
    
    // calculate contribution from tasks (90% or 100% if no meetings)
    _calculateTaskContribution(project, tasks, taskWeightPercentage);
    
    // calculate contribution from meetings (10% or 0% if no meetings)
    if (meetings.isNotEmpty) {
      _calculateMeetingContribution(project, meetings, meetingWeightPercentage);
    }
    
    return memberContributions;
  }
  
  // calculates task-based contribution percentages
  // only counts completed tasks with their percentage weightings
  void _calculateTaskContribution(
    Project project, 
    List<Task> allTasks,
    double taskWeightPercentage,
  ) {
    // filter for completed tasks belonging to this project
    final completedTasks = allTasks.where((task) => 
      task.parentProject == project.uuid && 
      task.status == Status.completed
    ).toList();
    
    // if no completed tasks, everyone gets 0% for task contribution
    if (completedTasks.isEmpty) {
      return;
    }
    
    // calculate sum of all task weights to normalise
    double totalTaskWeight = 0.0;
    for (var task in completedTasks) {
      totalTaskWeight += task.percentageWeighting;
    }
    
    // avoid division by zero
    if (totalTaskWeight <= 0) {
      return;
    }
    
    // calculate each member's contribution from tasks
    for (var task in completedTasks) {
      final memberCount = task.members.length;
      
      if (memberCount > 0) {
        // calculate contribution per member for this task
        // formula: (task weight / total weight) * task percentage / member count
        final contributionPerMember = 
            (task.percentageWeighting / totalTaskWeight) * 
            taskWeightPercentage / 
            memberCount;
        
        // distribute contribution to each assigned member
        for (var username in task.members.keys) {
          if (memberContributions.containsKey(username)) {
            memberContributions[username] = 
                memberContributions[username]! + contributionPerMember;
          }
        }
      }
    }
  }
  
  // calculates meeting attendance contribution percentages
  // each meeting attended earns equal portion of meeting percentage
  void _calculateMeetingContribution(
    Project project,
    List<Map<String, dynamic>> meetings,
    double meetingWeightPercentage,
  ) {
    // if no meetings, return without changes
    if (meetings.isEmpty) {
      return;
    }
    
    // calculate contribution value per meeting
    final contributionPerMeeting = meetingWeightPercentage / meetings.length;
    
    // add contribution for each attended meeting
    for (var meeting in meetings) {
      // check if meeting has attendees list and safely convert to list
      if (meeting['attendees'] != null) {
        List<String> attendees = [];
        
        // handle different possible formats of attendees
        var attendeesData = meeting['attendees'];
        if (attendeesData is List) {
          // if it's already a list, convert elements to strings
          attendees = attendeesData.map((e) => e.toString()).toList();
        } else if (attendeesData is String) {
          // if it's a comma-separated string, split it
          if (attendeesData.isNotEmpty) {
            attendees = attendeesData.split(',');
          }
        }
        
        // add contribution for each attendee
        for (var attendee in attendees) {
          String username = attendee.trim();
          if (memberContributions.containsKey(username)) {
            memberContributions[username] = 
                memberContributions[username]! + contributionPerMeeting;
          }
        }
      }
    }
  }
  
  // rounds contribution percentages to 1 decimal place for display
  // returns new map with rounded values
  Map<String, double> getRoundedContributions() {
    final roundedContributions = <String, double>{};
    
    memberContributions.forEach((username, contribution) {
      // round to 1 decimal place
      roundedContributions[username] = double.parse(contribution.toStringAsFixed(1));
    });
    
    return roundedContributions;
  }
}