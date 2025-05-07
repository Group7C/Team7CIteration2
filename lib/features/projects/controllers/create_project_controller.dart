import 'package:flutter/material.dart';
import '../../../features/common/services/project_service.dart';
import '../../../usser/usserObject.dart';

enum NotificationFrequency { daily, weekly, monthly }

class CreateProjectController {
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

  // Initialize controller with default values
  void initDefaults() {
    // Set default deadline to 30 days from now
    final defaultDeadline = DateTime.now().add(const Duration(days: 30));
    deadlineDateController.text = defaultDeadline.toIso8601String().split('T')[0];
    
    // Default notification preference
    notificationFrequency = NotificationFrequency.weekly;
  }
  
  // Clear form data
  void clearForm() {
    nameController.clear();
    deadlineDateController.clear();
    googleDriveLinkController.clear();
    discordLinkController.clear();
    
    // Reset to defaults
    initDefaults();
  }
  
  // Submit new project
  Future<int?> submitProject(Usser currentUser) async {
    if (!formKey.currentState!.validate()) {
      return null;
    }
    
    try {
      // Make sure we have a valid user ID
      if (currentUser.usserID.isEmpty) {
        await currentUser.getID();
        if (currentUser.usserID.isEmpty) {
          throw Exception('User ID not available. Please log in again.');
        }
      }
      
      // Create project using project service
      final projectId = await ProjectService.createProject(
        projName: nameController.text,
        deadline: DateTime.parse(deadlineDateController.text),
        userId: int.parse(currentUser.usserID),
      );
      
      // Clear form after successful submission
      clearForm();
      
      return projectId;
    } catch (e) {
      print('Error creating project: $e');
      return null;
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
