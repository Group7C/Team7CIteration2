import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'pdf_service.dart';

/// Modal dialog for displaying the contribution report with options to export as PDF
class ContributionReportModal {
  /// Shows the contribution report modal
  static void show(BuildContext context, Map<String, dynamic> reportData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1D21),
          title: Text(
            'Project Contribution Report',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Container(
            width: double.maxFinite,
            height: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary info
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Project: ${reportData["project_name"]}',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Progress: ${reportData["project_progress"].toStringAsFixed(1)}%',
                        style: TextStyle(color: Colors.white70),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Generated: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Member Contributions',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: (reportData['report'] as List).length,
                    itemBuilder: (context, index) {
                      final member = reportData['report'][index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 8),
                        color: Colors.grey.shade900,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    member['username'],
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                  Spacer(),
                                  Text(
                                    '${member["total_contribution"].toStringAsFixed(1)}%',
                                    style: TextStyle(color: _getContributionColor(member['total_contribution']), fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              SizedBox(height: 2),
                              if (member.containsKey('raw_contribution'))
                                Text(
                                  'Raw: ${member["raw_contribution"].toStringAsFixed(1)}%',
                                  style: TextStyle(color: Colors.white70, fontSize: 10),
                                ),
                              SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: member['total_contribution'] / 100,
                                backgroundColor: Colors.grey.shade800,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getContributionColor(member['total_contribution']),
                                ),
                                minHeight: 6,
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Meetings: ${member["meeting_contribution"].toStringAsFixed(1)}%',
                                      style: TextStyle(color: Colors.white70, fontSize: 12),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Tasks: ${member["task_contribution"].toStringAsFixed(1)}%',
                                      style: TextStyle(color: Colors.white70, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Attended ${member["attended_meetings"]}/${member["total_meetings"]} meetings',
                                style: TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close', style: TextStyle(color: Colors.white70)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Export PDF', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                // Close current dialog first
                Navigator.of(context).pop();
                
                // Try to generate the PDF
                try {
                  // Show loading indicator
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Generating PDF...'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  
                  // Call the PDF service to generate the PDF
                  PdfService.generateContributionReportPdf(reportData)
                    .then((filePath) {
                      // Show success message with file path
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('PDF generated successfully at: $filePath'),
                          duration: Duration(seconds: 4),
                        ),
                      );
                    })
                    .catchError((error) {
                      // Show PDF export error dialog
                      PdfService.showPdfExportError(context);
                    });
                } catch (e) {
                  // Show PDF export error dialog
                  PdfService.showPdfExportError(context);
                }
              },
            ),
          ],
        );
      },
    );
  }
  
  /// Color helper for contribution percentages
  static Color _getContributionColor(double contribution) {
    if (contribution >= 25) {
      return Colors.green;
    } else if (contribution >= 10) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
