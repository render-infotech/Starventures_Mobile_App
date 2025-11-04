import 'dart:io';
import 'package:flutter/material.dart';
import 'package:htmltopdfwidgets/htmltopdfwidgets.dart' as pw;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:starcapitalventures/app_export/app_export.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../core/utils/custom_snackbar.dart';

class HtmlViewerScreen extends StatefulWidget {
  final String htmlContent;
  final String documentTitle;

  const HtmlViewerScreen({
    super.key,
    required this.htmlContent,
    required this.documentTitle,
  });

  @override
  State<HtmlViewerScreen> createState() => _HtmlViewerScreenState();
}

class _HtmlViewerScreenState extends State<HtmlViewerScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (progress == 100) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            print('[WebView] Error: ${error.description}');
          },
        ),
      )
      ..loadHtmlString(widget.htmlContent);
  }

  // Request storage permissions
  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final androidVersion = androidInfo.version.sdkInt;

      if (androidVersion >= 33) {
        return true;
      } else if (androidVersion >= 30) {
        var status = await Permission.manageExternalStorage.status;
        if (!status.isGranted) {
          status = await Permission.manageExternalStorage.request();
        }
        return status.isGranted;
      } else {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }
        return status.isGranted;
      }
    }
    return true;
  }

  // Download PDF
  Future<void> _downloadPdf() async {
    setState(() {
      _isDownloading = true;
    });

    try {
      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        if (mounted) {
          CustomSnackbar.show(
            context,
            title: 'Permission Denied',
            message: 'Storage permission is required to download files',
            duration: const Duration(seconds: 3),
          );
        }
        setState(() {
          _isDownloading = false;
        });
        return;
      }

      // Generate PDF
      final pdf = await _generatePdfFromHtml();

      // Get Downloads directory
      String? downloadsPath;
      if (Platform.isAndroid) {
        downloadsPath = '/storage/emulated/0/Download';
      } else if (Platform.isIOS) {
        final directory = await getApplicationDocumentsDirectory();
        downloadsPath = directory.path;
      }

      if (downloadsPath == null) {
        throw Exception('Could not get downloads directory');
      }

      // Clean filename
      final cleanTitle = widget.documentTitle.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_');
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${cleanTitle}_$timestamp.pdf';
      final filePath = '$downloadsPath/$fileName';

      // Save PDF
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      print('[PDF] ✅ Downloaded to: $filePath');

      setState(() {
        _isDownloading = false;
      });

      if (mounted) {
        CustomSnackbar.show(
          context,
          title: 'Download Complete',
          message: 'PDF saved to Downloads/$fileName',
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      print('[PDF] ❌ Download error: $e');
      setState(() {
        _isDownloading = false;
      });

      if (mounted) {
        CustomSnackbar.show(
          context,
          title: 'Download Failed',
          message: 'Failed to download PDF: ${e.toString()}',
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  // Generate PDF with cleaned HTML content
  Future<pw.Document> _generatePdfFromHtml() async {
    final pdf = pw.Document();

    // Clean and extract text from HTML
    final cleanedText = _cleanHtmlContent(widget.htmlContent);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        maxPages: 100,
        build: (pw.Context context) {
          return [
            // Title
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    widget.documentTitle,
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey800,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Divider(thickness: 2, color: PdfColors.grey600),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Content
            pw.Paragraph(
              text: cleanedText,
              style: const pw.TextStyle(
                fontSize: 11,
                lineSpacing: 1.5,
                color: PdfColors.black,
              ),
            ),
          ];
        },
      ),
    );

    return pdf;
  }

  // Clean HTML content - remove scripts, styles, and debug info
  String _cleanHtmlContent(String htmlString) {
    var text = htmlString;

    // Remove script tags and their content
    text = text.replaceAll(RegExp(r'<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>', caseSensitive: false), '');

    // Remove style tags and their content
    text = text.replaceAll(RegExp(r'<style\b[^<]*(?:(?!<\/style>)<[^<]*)*<\/style>', caseSensitive: false), '');

    // Remove PHP debug bar content
    text = text.replaceAll(RegExp(r'var\s+phpdebugbar.*?(?=<|$)', dotAll: true), '');
    text = text.replaceAll(RegExp(r'jQuery\.noConflict.*?(?=<|$)', dotAll: true), '');
    text = text.replaceAll(RegExp(r'Sfdump\s*=.*?(?=<|$)', dotAll: true), '');

    // Replace common HTML entities
    text = text.replaceAll('&nbsp;', ' ');
    text = text.replaceAll('&amp;', '&');
    text = text.replaceAll('&lt;', '<');
    text = text.replaceAll('&gt;', '>');
    text = text.replaceAll('&quot;', '"');
    text = text.replaceAll('&#39;', "'");

    // Add line breaks for block elements
    text = text.replaceAll(RegExp(r'<br\s*/?>'), '\n');
    text = text.replaceAll(RegExp(r'</p>'), '\n\n');
    text = text.replaceAll(RegExp(r'</div>'), '\n');
    text = text.replaceAll(RegExp(r'</h[1-6]>'), '\n\n');
    text = text.replaceAll(RegExp(r'</li>'), '\n');
    text = text.replaceAll(RegExp(r'</tr>'), '\n');
    text = text.replaceAll(RegExp(r'<hr.*?>'), '\n' + ('-' * 60) + '\n');

    // Remove all remaining HTML tags
    text = text.replaceAll(RegExp(r'<[^>]*>'), '');

    // Clean up excessive whitespace
    text = text.replaceAll(RegExp(r'\n\s*\n\s*\n+'), '\n\n');
    text = text.replaceAll(RegExp(r'[ \t]+'), ' ');
    text = text.replaceAll(RegExp(r'^\s+', multiLine: true), '');

    return text.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: appTheme.mintygreen ?? const Color(0xFF10B981),
        title: Text(
          widget.documentTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // if (_isDownloading)
          //   const Padding(
          //     padding: EdgeInsets.all(16.0),
          //     child: SizedBox(
          //       width: 24,
          //       height: 24,
          //       child: CircularProgressIndicator(
          //         color: Colors.white,
          //         strokeWidth: 2,
          //       ),
          //     ),
          //   )
          // else
          //   IconButton(
          //     icon: const Icon(Icons.download, color: Colors.white),
          //     onPressed: _downloadPdf,
          //     tooltip: 'Download PDF',
          //   ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              _controller.reload();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(
                color: appTheme.theme2 ?? const Color(0xFF16A34A),
              ),
            ),
        ],
      ),
    );
  }
}
