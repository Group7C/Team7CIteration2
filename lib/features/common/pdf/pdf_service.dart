import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Service class for handling PDF generation functionality
class PdfService {
  /// Generates a contribution report PDF
  static Future<String> generateContributionReportPdf(Map<String, dynamic> reportData) async {
    try {
      final pdf = pw.Document();
      
      // Add pages to the PDF
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return _buildContributionReportContent(reportData);
          },
        ),
      );
      
      // Generate filename based on project and date
      final fileName = 'contribution_report_${reportData["project_name"].toString().replaceAll(' ', '_').toLowerCase()}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
      
      // Save the PDF based on platform
      String filePath = '';
      if (kIsWeb) {
        // Web platform - download the file
        await _savePdfForWeb(pdf, fileName);
        filePath = 'Downloaded to your browser';
      } else {
        // Mobile, desktop platforms - save to documents or downloads folder
        filePath = await _savePdfToFileSystem(pdf, fileName);
        
        // Try to open the file if on a platform that supports it
        try {
          await OpenFile.open(filePath);
        } catch (e) {
          print('Could not open the file automatically: $e');
        }
      }
      
      print('PDF generated successfully at: $filePath');
      return filePath;
    } catch (e) {
      print('Error generating PDF: $e');
      rethrow;
    }
  }
  
  /// Saves PDF for web platform by triggering download
  static Future<void> _savePdfForWeb(pw.Document pdf, String fileName) async {
    final bytes = await pdf.save();
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    
    // Create a link element and trigger download
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..style.display = 'none';
      
    html.document.body?.children.add(anchor);
    anchor.click();
    
    // Clean up
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }
  
  /// Saves PDF to the device filesystem
  static Future<String> _savePdfToFileSystem(pw.Document pdf, String fileName) async {
    Directory? directory;
    
    try {
      // Determine the appropriate directory based on platform
      if (Platform.isAndroid || Platform.isIOS) {
        // Mobile devices - use documents directory
        directory = await getApplicationDocumentsDirectory();
      } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        // Desktop platforms - use downloads directory
        directory = await getDownloadsDirectory();
      } else {
        // Fallback to application documents
        directory = await getApplicationDocumentsDirectory();
      }
      
      // Check if directory is not null
      if (directory != null) {
        // Create the file path
        final filePath = '${directory.path}${Platform.pathSeparator}$fileName';
        
        // Save the PDF
        final file = File(filePath);
        await file.writeAsBytes(await pdf.save());
        
        return filePath;
      } else {
        // Fall back to temporary directory if directory is null
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}${Platform.pathSeparator}$fileName';
        
        final file = File(filePath);
        await file.writeAsBytes(await pdf.save());
        
        return filePath;
      }
    } catch (e) {
      // If getting standard directory fails, create a temporary file
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}${Platform.pathSeparator}$fileName';
      
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());
      
      return filePath;
    }
  }
  
  /// Builds the content for the contribution report
  static pw.Widget _buildContributionReportContent(Map<String, dynamic> reportData) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Header
        pw.Header(
          level: 0,
          child: pw.Text('Project Contribution Report', 
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
            )
          ),
        ),
        pw.SizedBox(height: 10),
        
        // Project info
        pw.Container(
          padding: pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(width: 1, color: PdfColors.grey300),
            borderRadius: pw.BorderRadius.circular(5),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Project: ${reportData["project_name"]}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Progress: ${reportData["project_progress"].toStringAsFixed(1)}%',
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Generated: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
                style: pw.TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 20),
        
        // Member contributions header
        pw.Text(
          'Member Contributions',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        
        // Member contributions list
        pw.ListView.builder(
          itemCount: (reportData['report'] as List).length,
          itemBuilder: (context, index) {
            final member = reportData['report'][index];
            return pw.Container(
              margin: pw.EdgeInsets.only(bottom: 10),
              padding: pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(width: 1, color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(5),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        member['username'],
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        '${member["total_contribution"].toStringAsFixed(1)}%',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 2),
                  if (member.containsKey('raw_contribution'))
                    pw.Text(
                      'Raw: ${member["raw_contribution"].toStringAsFixed(1)}%',
                      style: pw.TextStyle(fontSize: 8),
                    ),
                  pw.SizedBox(height: 8),
                  
                  // Progress bar
                  pw.Container(
                    height: 6,
                    child: pw.ClipRRect(
                      verticalRadius: 3,
                      horizontalRadius: 3,
                      child: pw.LinearProgressIndicator(
                        value: member['total_contribution'] / 100,
                        backgroundColor: PdfColors.grey300,
                        valueColor: _getContributionColor(member['total_contribution']),
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  
                  // Detailed stats
                  pw.Row(
                    children: [
                      pw.Expanded(
                        child: pw.Text(
                          'Meetings: ${member["meeting_contribution"].toStringAsFixed(1)}%',
                          style: pw.TextStyle(fontSize: 10),
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          'Tasks: ${member["task_contribution"].toStringAsFixed(1)}%',
                          style: pw.TextStyle(fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                  pw.Text(
                    'Attended ${member["attended_meetings"]}/${member["total_meetings"]} meetings',
                    style: pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
  
  /// Helper method to determine color based on contribution percentage
  static PdfColor _getContributionColor(double contribution) {
    if (contribution >= 25) {
      return PdfColors.green;
    } else if (contribution >= 10) {
      return PdfColors.orange;
    } else {
      return PdfColors.red;
    }
  }
  
  /// Handles showing error messages for PDF export
  static void showPdfExportError(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1D21),
          title: Text(
            'PDF Export Error',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'There was an issue with the PDF export.',
                style: TextStyle(color: Colors.white70),
              ),
              SizedBox(height: 16),
              Text(
                'The export feature requires additional setup. The contribution report is available in the app view. PDF export will be available in a future update.',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('OK', style: TextStyle(color: Colors.white70)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
