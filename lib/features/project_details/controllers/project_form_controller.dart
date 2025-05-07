import 'package:flutter/material.dart';
import '../../../features/common/services/project_service.dart';
import '../../../features/common/models/project_model.dart';

enum NotificationFrequency { daily, weekly, monthly }

class ProjectFormController {
  // Form controllers
  final nameController = TextEditingController();
  final deadlineDateController = TextEditingController();
  final googleDriveLinkController = TextEditingController();
  final discordLinkController = TextEditingController();
  
  // Form key for validation
  final formKey = GlobalKey<FormState>();
  
  // Form state
  NotificationFrequency notificationFrequency = NotificationFrequency.weekly;
  
  // Focus nodes
  final nameFocusNode = FocusNode();
  final deadlineDateFocusNode = FocusNode();
  final googleDriveLinkFocusNode = FocusNode();
  final discordLinkFocusNode = FocusNode();

  // Initialize controller with existing project data
  void initWithProject(Project project) {
    nameController.text = project.projName;
    deadlineDateController.text = project.deadline.toIso8601String().split('T')[0];
    googleDriveLinkController.text = project.googleDriveLink ?? '';
    discordLinkController.text = project.discordLink ?? '';
    
    // Set notification frequency based on project preference
    if (project.notificationPreference.toLowerCase() == 'daily') {
      notificationFrequency = NotificationFrequency.daily;
    } else if (project.notificationPreference.toLowerCase() == 'monthly') {
      notificationFrequency = NotificationFrequency.monthly;
    } else {
      notificationFrequency = NotificationFrequency.weekly;
    }
  }
  
  // Clear form data
  void clearForm() {
    nameController.clear();
    deadlineDateController.clear();
    googleDriveLinkController.clear();
    discordLinkController.clear();
    notificationFrequency = NotificationFrequency.weekly;
  }
  
  // Submit updates to project
  Future<bool> submitProjectUpdates(int projectId) async {
    if (!formKey.currentState!.validate()) {
      return false;
    }
    
    try {
      // Convert notification frequency enum to string
      String notificationPreference;
      switch (notificationFrequency) {
        case NotificationFrequency.daily:
          notificationPreference = 'Daily';
          break;
        case NotificationFrequency.monthly:
          notificationPreference = 'Monthly';
          break;
        case NotificationFrequency.weekly:
        default:
          notificationPreference = 'Weekly';
          break;
      }
      
      // Update project using project service
      final success = await ProjectService.updateProject(
        projectId: projectId,
        projName: nameController.text,
        deadline: DateTime.parse(deadlineDateController.text),
        notificationPreference: notificationPreference,
        googleDriveLink: googleDriveLinkController.text.isEmpty ? null : googleDriveLinkController.text,
        discordLink: discordLinkController.text.isEmpty ? null : discordLinkController.text,
      );
      
      return success;
    } catch (e) {
      print('Error updating project: $e');
      return false;
    }
  }
  
  // Dispose resources
  void dispose() {
    nameController.dispose();
    deadlineDateController.dispose();
    googleDriveLinkController.dispose();
    discordLinkController.dispose();
    
    nameFocusNode.dispose();
    deadlineDateFocusNode.dispose();
    googleDriveLinkFocusNode.dispose();
    discordLinkFocusNode.dispose();
  }
}
