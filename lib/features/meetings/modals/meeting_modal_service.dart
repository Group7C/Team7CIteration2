import 'package:flutter/material.dart';
import '../widgets/meeting_tabs_widget.dart';
import '../../../features/common/modals/large_modal.dart';
import '../../../features/common/models/project_model.dart';

class MeetingModalService {
  /// Shows the meeting modal with tabs for scheduling and recording meetings
  static Future<void> showMeetingModal({
    required BuildContext context,
    required Project project,
    VoidCallback? onMeetingCreated,
  }) {
    return LargeModal.show(
      context: context,
      title: 'Project Meetings',
      subtitle: 'Schedule a new meeting or record attendance for a past meeting',
      height: 600, // Fixed height to avoid layout issues
      width: 700, // Wider to accommodate form fields
      content: [
        // Wrap the meeting tabs widget in a SizedBox with fixed height
        SizedBox(
          height: 450, // Fixed height to avoid rendering issues
          child: MeetingTabsWidget(
            project: project,
            onMeetingCreated: onMeetingCreated,
          ),
        ),
      ],
      // No actions needed as the tabs widget has its own buttons
    );
  }
}
