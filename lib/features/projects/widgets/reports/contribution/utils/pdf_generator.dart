// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

import '../../../../../../features/projects/models/project.dart';
import '../models/member_contribution.dart';

class PdfGenerator {
  // Generate a PDF report from contribution data
  static Future<Uint8List> generateContributionReport(
    Project project,
    ContributionReport report,
  ) async {
    // Create a PDF document
    final pdf = pw.Document();
    
    // Define some styles
    final headerStyle = pw.TextStyle(
      fontSize: 24, 
      fontWeight: pw.FontWeight.bold
    );
    
    final sectionStyle = pw.TextStyle(
      fontSize: 18, 
      fontWeight: pw.FontWeight.bold
    );
    
    final normalStyle = pw.TextStyle(
      fontSize: 12,
    );
    
    final smallStyle = pw.TextStyle(
      fontSize: 10,
      color: PdfColors.grey700,
    );
    
    final highlightStyle = pw.TextStyle(
      fontSize: 12,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.blue700,
    );
    
    // Get total project contribution percentage
    final overallCompletion = report.getOverallCompletion();
    
    // Format current date
    final dateFormatter = DateFormat('yyyy-MM-dd');
    final currentDate = dateFormatter.format(DateTime.now());
    
    // Add pages to the PDF document
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (pw.Context context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Logo/title area
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Contribution Report', style: headerStyle),
                    pw.Text('Generated: $currentDate', style: smallStyle),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Divider(thickness: 2),
              ],
            ),
          );
        },
        footer: (pw.Context context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(top: 20),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Project Management Report', style: smallStyle),
                pw.Text('Page ${context.pageNumber} of ${context.pagesCount}', style: smallStyle),
              ],
            ),
          );
        },
        build: (pw.Context context) => [
          // Project summary
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(5),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Project: ${project.name}', style: sectionStyle),
                pw.SizedBox(height: 10),
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Team size: ${project.members.length}', style: normalStyle),
                          pw.SizedBox(height: 5),
                          pw.Text('Total tasks: ${project.totalTasks}', style: normalStyle),
                          pw.SizedBox(height: 5),
                          pw.Text('Completed tasks: ${project.completedTasks}', style: normalStyle),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Overall completion:', style: normalStyle),
                          pw.SizedBox(height: 5),
                          pw.Row(
                            children: [
                              pw.Container(
                                width: 150,
                                height: 15,
                                decoration: pw.BoxDecoration(
                                  borderRadius: pw.BorderRadius.circular(10),
                                  border: pw.Border.all(),
                                ),
                                child: pw.Stack(
                                  children: [
                                    pw.Container(
                                      width: 150 * (project.progress / 100),
                                      height: 15,
                                      decoration: pw.BoxDecoration(
                                        borderRadius: pw.BorderRadius.circular(10),
                                        color: PdfColors.blue400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              pw.SizedBox(width: 10),
                              pw.Text('${project.progress.toStringAsFixed(1)}%', style: highlightStyle),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          pw.SizedBox(height: 20),
          
          // Member Contribution Section
          pw.Text('Member Contributions', style: sectionStyle),
          pw.SizedBox(height: 10),
          pw.Text(
            'The following breakdown shows contribution metrics based on task completion (90%) and meeting attendance (10%).',
            style: normalStyle,
          ),
          pw.SizedBox(height: 15),
          
          // Table of member contributions
          pw.Table(
            border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey400),
            children: [
              // Table header
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _tableCellHeader('Member'),
                  _tableCellHeader('Tasks'),
                  _tableCellHeader('Task Contribution'),
                  _tableCellHeader('Attendance'),
                  _tableCellHeader('Total'),
                ],
              ),
              
              // Table data rows
              ...report.memberContributions.values.map((contribution) {
                final taskPercentage = contribution.taskWeight;
                final attendancePercentage = contribution.attendanceWeight;
                final totalPercentage = contribution.getTotalContribution();
                
                return pw.TableRow(
                  children: [
                    _tableCell('${contribution.username}${contribution.isOwner ? ' (Owner)' : ''}'),
                    _tableCell('${contribution.completedTasks}/${contribution.totalTasks}'),
                    _tableCell('${taskPercentage.toStringAsFixed(1)}%'),
                    _tableCell('${attendancePercentage.toStringAsFixed(1)}%'),
                    _tableCellBold('${totalPercentage.toStringAsFixed(1)}%'),
                  ],
                );
              }).toList(),
            ],
          ),
          
          pw.SizedBox(height: 20),
          
          // Explanation section
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(5),
              border: pw.Border.all(width: 0.5, color: PdfColors.grey400),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Understanding Contribution Metrics', style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                )),
                pw.SizedBox(height: 10),
                pw.Text(
                  'The contribution metrics are calculated using the following formula:',
                  style: normalStyle,
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  '• Task Contribution (90%): Based on the weighted value of all tasks assigned to the member, divided by the number of members assigned to each task.',
                  style: normalStyle,
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  '• Attendance Contribution (10%): Percentage of total meetings attended, with each meeting worth 1% of the total contribution (up to 10%).',
                  style: normalStyle,
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  '• Total Contribution: Sum of task contribution and attendance contribution.',
                  style: normalStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
    
    // Return the PDF document as bytes
    return pdf.save();
  }
  
  // Download the generated PDF
  static void downloadPdf(Uint8List pdfBytes, String fileName) {
    // Create a blob from the PDF bytes
    final blob = html.Blob([pdfBytes], 'application/pdf');
    
    // Create a URL for the blob
    final url = html.Url.createObjectUrlFromBlob(blob);
    
    // Create an anchor element
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..style.display = 'none';
    
    // Add the anchor to the document body
    html.document.body?.children.add(anchor);
    
    // Trigger a click on the anchor to start the download
    anchor.click();
    
    // Clean up
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }
  
  // Helper methods for table cells
  static pw.Widget _tableCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(text),
    );
  }
  
  static pw.Widget _tableCellHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),
    );
  }
  
  static pw.Widget _tableCellBold(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),
    );
  }
}