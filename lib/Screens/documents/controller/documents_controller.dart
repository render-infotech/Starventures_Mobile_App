import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:starcapitalventures/app_export/app_export.dart';
import '../../../core/data/api_client/api_client.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../../core/utils/loading_service.dart';
import '../../../widgets/html_viewer_screen.dart';
import '../../../widgets/image_viewer_screen.dart';
import '../../../widgets/pdf_viewer_screen.dart';
import '../models/document_model.dart';

class DocumentsController extends GetxController {
  final ApiClient _apiClient = ApiClient();

  final loading = false.obs;
  final documents = <DocumentItem>[].obs;
  final selectedFiles = <File>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDocuments();
  }
  Future<void> fetchSalarySlip(int year, int month) async {
    try {
      LoadingService.to.show(message: "Loading Salary Slip...");

      final yearMonth = "$year-${month.toString().padLeft(2, '0')}";

      final htmlContent = await _apiClient.fetchPayslipHtml(yearMonth);

      LoadingService.to.hide();

      if (_isErrorResponse(htmlContent)) {
        _showDocumentNotFoundDialog(
          "Salary Slip Not Available",
          "Salary slip for $yearMonth is not available.",
          Icons.receipt_long_outlined,
        );
        return;
      }

      Get.to(() => HtmlViewerScreen(
        htmlContent: htmlContent,
        documentTitle: "Salary Slip - $yearMonth",
      ));

    } catch (e) {
      LoadingService.to.hide();
      print("❌ Error salary slip: $e");
      _showDocumentNotFoundDialog(
        "Salary Slip Not Available",
        "Please try again later.",
        Icons.error_outline,
      );
    }
  }

  Future<void> viewSalarySlip() async {
    await selectYearMonthAndFetchSlip();
  }

  // Fetch and view Joining Letter
  Future<void> viewJoiningLetter() async {
    try {
      LoadingService.to.show(message: 'Loading Joining Letter...');

      final htmlContent = await _apiClient.fetchJoiningLetterHtml();

      LoadingService.to.hide();

      // Check if response contains error
      if (_isErrorResponse(htmlContent)) {
        _showDocumentNotFoundDialog(
          'Joining Letter Not Available',
          'Your joining letter is currently unavailable. Please contact the HR department for assistance in obtaining this document.',
          Icons.work_outline,
        );
        return;
      }

      Get.to(() => HtmlViewerScreen(
        htmlContent: htmlContent,
        documentTitle: 'Joining Letter',
      ));
    } catch (e) {
      LoadingService.to.hide();
      print('[Documents] ❌ Error loading joining letter: $e');
      _showDocumentNotFoundDialog(
        'Joining Letter Not Available',
        'Your joining letter is currently unavailable. Please contact the HR department for assistance in obtaining this document.',
        Icons.error_outline,
      );
    }
  }
  Future<void> selectYearMonthAndFetchSlip() async {
    final now = DateTime.now();

    int selectedYear = now.year;
    int selectedMonth = now.month;

    await Get.dialog(
      Dialog(
        backgroundColor: appTheme.whiteA700,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Select Year & Month",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // YEAR DROPDOWN
              DropdownButtonFormField<int>(
                value: selectedYear,
                decoration: const InputDecoration(labelText: "Year"),
                items: List.generate(
                  6,
                      (i) => DropdownMenuItem(
                    value: now.year - i,
                    child: Text((now.year - i).toString()),
                  ),
                ),
                onChanged: (v) => selectedYear = v!,
              ),

              const SizedBox(height: 10),

              // MONTH DROPDOWN
              DropdownButtonFormField<int>(
                value: selectedMonth,
                decoration: const InputDecoration(labelText: "Month"),
                items: List.generate(
                  12,
                      (i) => DropdownMenuItem(
                    value: i + 1,
                    child: Text("${i + 1}".padLeft(2, '0')),
                  ),
                ),
                onChanged: (v) => selectedMonth = v!,
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  Get.back(); // close dialog
                  fetchSalarySlip(selectedYear, selectedMonth);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: appTheme.theme2,
                ),
                child:  Text("View Slip",style: TextStyle(color: appTheme.whiteA700),),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  // Fetch and view NOC
  Future<void> viewNoc() async {
    try {
      LoadingService.to.show(message: 'Loading NOC...');

      final htmlContent = await _apiClient.fetchNocHtml();

      LoadingService.to.hide();

      // Check if response contains error
      if (_isErrorResponse(htmlContent)) {
        _showDocumentNotFoundDialog(
          'NOC Not Available',
          'Your No Objection Certificate is currently unavailable. Please submit a request to the HR department to generate this document.',
          Icons.verified_outlined,
        );
        return;
      }

      Get.to(() => HtmlViewerScreen(
        htmlContent: htmlContent,
        documentTitle: 'No Objection Certificate',
      ));
    } catch (e) {
      LoadingService.to.hide();
      print('[Documents] ❌ Error loading NOC: $e');
      _showDocumentNotFoundDialog(
        'NOC Not Available',
        'Your No Objection Certificate is currently unavailable. Please submit a request to the HR department to generate this document.',
        Icons.error_outline,
      );
    }
  }

  // Check if the response is an error (404 or other error JSON)
  bool _isErrorResponse(String htmlContent) {
    try {
      // Try to parse as JSON
      final jsonData = json.decode(htmlContent);
      if (jsonData is Map && jsonData.containsKey('error')) {
        print('[Documents] Error detected in response: ${jsonData['error']}');
        return true;
      }
    } catch (e) {
      // Not JSON, probably valid HTML
      return false;
    }

    // Check if HTML is empty or contains common error indicators
    if (htmlContent.isEmpty ||
        htmlContent.length < 50 ||
        htmlContent.toLowerCase().contains('not found') ||
        htmlContent.toLowerCase().contains('404')) {
      return true;
    }

    return false;
  }

  // Show professional document not found dialog
  void _showDocumentNotFoundDialog(String title, String message, IconData icon) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 48,
                  color: Colors.orange.shade700,
                ),
              ),
              const SizedBox(height: 20),
              // Title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A2036),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Message
              Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Close Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appTheme.theme2 ?? const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  Future<void> fetchDocuments() async {
    loading.value = true;
    print('[Documents] Fetching documents...');

    try {
      final response = await _apiClient.fetchDocuments();
      documents.value = response.data;
      print('[Documents] ✅ Loaded ${documents.length} documents');

      for (final doc in documents) {
        print('[Documents] - ${doc.title} (${doc.extension}) - ${doc.uploadedAt}');
      }
    } catch (e, stackTrace) {
      print('[Documents] ❌ Fetch error: $e');
      print('[Documents] Stack trace: $stackTrace');
      if (Get.context != null) {
        CustomSnackbar.show(
          Get.context!,
          title: 'Error',
          message: 'Failed to load documents',
          backgroundColor: appTheme.theme,
          duration: const Duration(seconds: 3),
        );
      }
    } finally {
      loading.value = false;
    }
  }


// Observable for selected document type
  final selectedDocumentType = Rx<String?>(null);
/*
// Fetch and view Salary Slip
  Future<void> viewSalarySlip() async {
    try {
      LoadingService.to.show(message: 'Loading Salary Slip...');

      // You need to get employee ID and date from user profile or input
      // For now using placeholder - replace with actual values
      final now = DateTime.now();
      final yearMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
      final employeeId = 'employee-id'; // Get from user profile

      final htmlContent = await _apiClient.fetchPayslipHtml(employeeId, yearMonth);

      LoadingService.to.hide();

      Get.to(() => HtmlViewerScreen(
        htmlContent: htmlContent,
        documentTitle: 'Salary Slip - $yearMonth',
      ));
    } catch (e) {
      LoadingService.to.hide();
      print('[Documents] ❌ Error loading salary slip: $e');
      Get.snackbar(
        'Error',
        'Failed to load salary slip',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }
*/
  /*
// Fetch and view Joining Letter
  Future<void> viewJoiningLetter() async {
    try {
      LoadingService.to.show(message: 'Loading Joining Letter...');

      final htmlContent = await _apiClient.fetchJoiningLetterHtml();

      LoadingService.to.hide();

      Get.to(() => HtmlViewerScreen(
        htmlContent: htmlContent,
        documentTitle: 'Joining Letter',
      ));
    } catch (e) {
      LoadingService.to.hide();
      print('[Documents] ❌ Error loading joining letter: $e');
      Get.snackbar(
        'Error',
        'Failed to load joining letter',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

// Fetch and view NOC
  Future<void> viewNoc() async {
    try {
      LoadingService.to.show(message: 'Loading NOC...');

      final htmlContent = await _apiClient.fetchNocHtml();

      LoadingService.to.hide();

      Get.to(() => HtmlViewerScreen(
        htmlContent: htmlContent,
        documentTitle: 'No Objection Certificate',
      ));
    } catch (e) {
      LoadingService.to.hide();
      print('[Documents] ❌ Error loading NOC: $e');
      Get.snackbar(
        'Error',
        'Failed to load NOC',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> fetchDocuments() async {
    loading.value = true;
    print('[Documents] Fetching documents...');

    try {
      final response = await _apiClient.fetchDocuments();
      documents.value = response.data;
      print('[Documents] ✅ Loaded ${documents.length} documents');

      for (final doc in documents) {
        print('[Documents] - ${doc.title} (${doc.extension}) - ${doc.uploadedAt}');
      }
    } catch (e, stackTrace) {
      print('[Documents] ❌ Fetch error: $e');
      print('[Documents] Stack trace: $stackTrace');
      Get.snackbar(
        'Error',
        'Failed to load documents',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } finally {
      loading.value = false;
    }
  }
*/
  Future<void> pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final validFiles = <File>[];

        for (final platformFile in result.files) {
          if (platformFile.path != null) {
            final file = File(platformFile.path!);
            final fileSize = file.lengthSync();

            if (fileSize > 5 * 1024 * 1024) {
              if (Get.context != null) {
                CustomSnackbar.show(
                  Get.context!,
                  title: 'File Too Large',
                  message: '${platformFile.name} exceeds 5MB limit',
                  backgroundColor: appTheme.theme,
                  duration: const Duration(seconds: 3),
                );
              }
              continue;
            }

            validFiles.add(file);
          }
        }

        selectedFiles.addAll(validFiles);
        print('[Documents] ✅ Selected ${validFiles.length} files');
      }
    } catch (e) {
      print('[Documents] ❌ Pick error: $e');
      if (Get.context != null) {
        CustomSnackbar.show(
          Get.context!,
          title: 'Error',
          message: 'Failed to pick files',
          backgroundColor: appTheme.theme,
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  void removeSelectedFile(int index) {
    if (index >= 0 && index < selectedFiles.length) {
      selectedFiles.removeAt(index);
    }
  }

  Future<void> uploadDocuments() async {
    if (selectedFiles.isEmpty) {
      if (Get.context != null) {
        CustomSnackbar.show(
          Get.context!,
          title: 'No Files',
          message: 'Please select files to upload',
          backgroundColor: appTheme.theme,
          duration: const Duration(seconds: 2),
        );
      }
      return;
    }

    try {
      print('[Documents] 📤 Starting upload of ${selectedFiles.length} files...');

      final uploadCount = selectedFiles.length;

      await LoadingService.to.during(
        _uploadFilesSequentially(),
        message: 'Uploading $uploadCount document(s)...',
      );

      selectedFiles.clear();

      print('[Documents] 🔄 Refreshing document list...');
      await fetchDocuments();

      if (Get.context != null) {
        CustomSnackbar.show(
          Get.context!,
          title: 'Success',
          message: '$uploadCount document(s) uploaded successfully',
          backgroundColor: appTheme.theme,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e, stackTrace) {
      print('[Documents] ❌ Upload error: $e');
      print('[Documents] Stack trace: $stackTrace');
      if (Get.context != null) {
        CustomSnackbar.show(
          Get.context!,
          title: 'Upload Failed',
          message: e.toString(),
          backgroundColor: appTheme.theme,
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  Future<void> _uploadFilesSequentially() async {
    int successCount = 0;

    for (int i = 0; i < selectedFiles.length; i++) {
      final file = selectedFiles[i];
      final fileName = path.basenameWithoutExtension(file.path);

      print('[Documents] 📤 Uploading ${i + 1}/${selectedFiles.length}: $fileName');

      try {
        final response = await _apiClient.uploadDocument(
          file: file,
          title: fileName,
        );

        if (response.status) {
          successCount++;
          print('[Documents] ✅ Upload successful: $fileName');
        } else {
          print('[Documents] ⚠️ Upload failed: $fileName - ${response.message}');
        }
      } catch (e) {
        print('[Documents] ❌ Upload error for $fileName: $e');
        throw Exception('Failed to upload $fileName: $e');
      }
    }

    print('[Documents] 📊 Upload complete: $successCount/${selectedFiles.length} successful');
  }

  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void viewDocument(DocumentItem doc) {
    print('[Documents] 👁️ View requested: ${doc.fileName}');
    print('[Documents] URL: ${doc.fileUrl}');
    print('[Documents] Extension: ${doc.extension}');

    try {
      final extension = doc.extension.toUpperCase();

      if (extension == 'PDF') {
        // Open PDF viewer
        Get.to(() => PDFViewerScreen(
          documentUrl: doc.fileUrl,
          documentTitle: doc.title,
        ));
      } else if (['JPG', 'JPEG', 'PNG'].contains(extension)) {
        // Open image viewer
        Get.to(() => ImageViewerScreen(
          imageUrl: doc.fileUrl,
          imageTitle: doc.title,
        ));
      } else {
        if (Get.context != null) {
          CustomSnackbar.show(
            Get.context!,
            title: 'Unsupported File Type',
            message: 'Cannot view ${doc.extension} files in-app',
            backgroundColor: appTheme.theme,
            duration: const Duration(seconds: 3),
          );
        }
      }
    } catch (e) {
      print('[Documents] ❌ View error: $e');
      if (Get.context != null) {
        CustomSnackbar.show(
          Get.context!,
          title: 'Error',
          message: 'Failed to open document',
          backgroundColor: appTheme.theme,
          duration: const Duration(seconds: 3),
        );
      }
    }
  }
}
