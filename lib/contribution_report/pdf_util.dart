import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:universal_html/html.dart' as html;
import '../projects/project_model.dart';

// simple pdf generator for project reports
// creates pdf files and handles download for web and mobile
class PDFUtil {
  // generates a basic contribution report as pdf
  // downloads in browser or saves to device based on platform
  static Future<void> generateContributionReport(
    Project project, 
    Map<String, double> contributions
  ) async {
    try {
      // create PDF document
      final pdf = pw.Document();
      
      // sort contributions by percentage (highest first)
      final sortedContributions = contributions.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
        
      // add page to document
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // report title
                pw.Center(
                  child: pw.Text(
                    'Contribution Report',
                    style: pw.TextStyle(
                      fontSize: 24, 
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),
                
                // project details
                pw.Text(
                  'Project: ${project.projectName}',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Deadline: ${project.deadline.toString().split(' ')[0]}',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.Text(
                  'Project ID: ${project.projectUid ?? "N/A"}',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.Text(
                  'Report generated: ${DateTime.now().toString().split('.')[0]}',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.SizedBox(height: 20),
                
                // explanation of calculation
                pw.Text(
                  'Calculation Method:',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  '• 90% based on completed tasks (weighted by task importance)\n'
                  '• 10% based on meeting attendance\n'
                  '• Task contribution is divided equally among assigned members',
                  style: const pw.TextStyle(fontSize: 12),
                ),
                pw.SizedBox(height: 20),
                
                // contribution table
                pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(3),
                    1: const pw.FlexColumnWidth(2),
                  },
                  children: [
                    // table header
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Member',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Contribution %',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                      ]
                    ),
                    // table rows for each member
                    ...sortedContributions.map((entry) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(entry.key),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('${entry.value}%'),
                        ),
                      ]
                    )).toList(),
                  ],
                ),
                pw.SizedBox(height: 20),
                
                // footer with disclaimer
                pw.Text(
                  'Note: This report is generated automatically based on task completion status and meeting attendance.',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
              ],
            );
          }
        )
      );
      
      // Web-specific approach: download in browser
      final bytes = await pdf.save();
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      
      // Create download element
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'contribution_report_${project.projectName}.pdf')
        ..click();
      
      // Clean up
      html.Url.revokeObjectUrl(url);
      
    } catch (e) {
      print('Error generating PDF: $e');
      rethrow; // rethrow to allow handling in UI
    }
  }
}