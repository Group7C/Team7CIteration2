import 'package:flutter/material.dart';
import '../../../../../features/projects/models/project.dart';
import 'components/member_contribution_card.dart';
import 'components/project_summary.dart';
import 'components/export_button.dart';
import 'models/member_contribution.dart';
import 'utils/report_generator.dart';
import 'utils/pdf_generator.dart';

class ContributionReportModal extends StatefulWidget {
  final Project project;
  
  const ContributionReportModal({
    Key? key,
    required this.project,
  }) : super(key: key);

  @override
  State<ContributionReportModal> createState() => _ContributionReportModalState();
}

class _ContributionReportModalState extends State<ContributionReportModal> {
  bool _isLoading = true;
  late ContributionReport _report;
  
  @override
  void initState() {
    super.initState();
    // Kick off report generation when modal opens [async]
    _generateReport();
  }
  
  // Create and load contribution report [mock data for now]
  Future<void> _generateReport() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Call the report generator with the project
      _report = await ReportGenerator.generateReport(widget.project);
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      // Show error if report generation fails
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating report: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  // Handle export notification
  void _handleExportNotification() {
    // This is just a notification handler that will be called when the export button is clicked
    // The actual PDF generation and download is handled in the ReportExportButton component
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
          // Title bar with close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Contribution Report',
                style: theme.textTheme.headlineSmall,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const Divider(),
          
          // Project overview section
          ProjectSummary(project: widget.project),
          
          const SizedBox(height: 16),
          
          // Loading spinner while getting data
          if (_isLoading)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Generating contribution report...'),
                  ],
                ),
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header bar with refresh button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Member Contributions',
                      style: theme.textTheme.titleMedium,
                    ),
                    // Reload button [refreshes data]
                    TextButton.icon(
                      onPressed: _generateReport,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Refresh'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          
          // Member contribution cards list
          if (!_isLoading)
            Expanded(
              child: ListView(
                children: widget.project.members.map((member) {
                  // Get this member's stats
                  final contribution = _report.memberContributions[member.username];
                  
                  // Show a card with their stats
                  return MemberContributionCard(
                    member: member,
                    totalTasks: contribution?.totalTasks ?? 0,
                    completedTasks: contribution?.completedTasks ?? 0,
                    projectColor: widget.project.colour,
                    taskWeight: contribution?.taskWeight,
                    attendanceWeight: contribution?.attendanceWeight,
                  );
                }).toList(),
              ),
            ),
          
          // Export button at bottom
          if (!_isLoading)
            ReportExportButton(
              project: widget.project,
              report: _report,
              onExport: _handleExportNotification,
            ),
        ],
      ),
    );
  }
}