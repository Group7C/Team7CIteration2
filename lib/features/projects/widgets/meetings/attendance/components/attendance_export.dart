import 'package:flutter/material.dart';

/// Button component for exporting attendance records
/// 
/// Takes an onExport callback that would handle the actual export logic
class AttendanceExport extends StatelessWidget {
  // Function to call when user wants to export data [will generate CSV/Excel in app w/e we decide]
  final VoidCallback onExport;
  
  const AttendanceExport({
    Key? key,
    required this.onExport,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onExport,
      icon: const Icon(Icons.download),
      label: const Text('Export Attendance Records'),
    );
  }
}