import 'package:flutter/material.dart';
import '../../../../../../features/projects/models/project.dart';
import '../models/member_contribution.dart';
import '../utils/pdf_generator.dart';

class ReportExportButton extends StatelessWidget {
  // Project and report data needed for PDF generation
  final Project project;
  final ContributionReport report;
  final VoidCallback? onExport;
  
  const ReportExportButton({
    Key? key,
    required this.project,
    required this.report,
    this.onExport,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: ElevatedButton.icon(
          onPressed: () => _handleExport(context),
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text('Download PDF Report'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),
    );
  }
  
  // Handle PDF generation and download
  Future<void> _handleExport(BuildContext context) async {
    // Notify parent if needed
    if (onExport != null) {
      onExport!();
    }
    
    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Generating PDF report...'),
        duration: Duration(seconds: 1),
      ),
    );
    
    try {
      // Generate PDF bytes
      final pdfBytes = await PdfGenerator.generateContributionReport(project, report);
      
      // Generate a filename with project name and date
      final dateStr = DateTime.now().toString().split(' ')[0];
      final fileName = '${project.name.replaceAll(' ', '_')}_contribution_report_$dateStr.pdf';
      
      // Download the PDF file
      PdfGenerator.downloadPdf(pdfBytes, fileName);
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report downloaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating report: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}