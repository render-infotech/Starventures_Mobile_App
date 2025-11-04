// lib/Screens/documents/viewers/pdf_viewer_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class PDFViewerScreen extends StatefulWidget {
  final String documentUrl;
  final String documentTitle;

  const PDFViewerScreen({
    Key? key,
    required this.documentUrl,
    required this.documentTitle,
  }) : super(key: key);

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  String? localPath;
  bool isLoading = true;
  String? errorMessage;
  int currentPage = 0;
  int totalPages = 0;

  @override
  void initState() {
    super.initState();
    _downloadAndOpenPDF();
  }

  Future<void> _downloadAndOpenPDF() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      print('[PDF] Downloading from: ${widget.documentUrl}');

      final response = await http.get(Uri.parse(widget.documentUrl));

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/${widget.documentTitle}.pdf');

        await file.writeAsBytes(bytes, flush: true);

        print('[PDF] Downloaded to: ${file.path}');

        setState(() {
          localPath = file.path;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to download PDF: ${response.statusCode}');
      }
    } catch (e) {
      print('[PDF] Error: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load PDF: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.documentTitle),
        actions: [
          if (totalPages > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  '${currentPage + 1} / $totalPages',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
        ],
      ),
      body: isLoading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading PDF...'),
          ],
        ),
      )
          : errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _downloadAndOpenPDF,
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : PDFView(
        filePath: localPath!,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageFling: true,
        onRender: (pages) {
          setState(() {
            totalPages = pages ?? 0;
          });
        },
        onPageChanged: (page, total) {
          setState(() {
            currentPage = page ?? 0;
          });
        },
        onError: (error) {
          print('[PDF] Error rendering: $error');
          setState(() {
            errorMessage = 'Error displaying PDF';
          });
        },
      ),
    );
  }
}
