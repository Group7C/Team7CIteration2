import 'package:flutter/material.dart';
import '../../project_details/screens/project_details_screen.dart';

/// Service to handle navigation to project-related screens
class ProjectNavigationService {
  /// Navigate to the project details screen for a specific project
  static Future<void> navigateToProjectDetails(BuildContext context, int projectId) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectDetailsScreen(projectId: projectId),
      ),
    );
    return;
  }
}
