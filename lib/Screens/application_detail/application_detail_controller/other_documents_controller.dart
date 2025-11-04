// lib/Screens/other_documents/controller/other_documents_controller.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import '../../../core/data/api_client/api_client.dart';
import '../../../core/utils/loading_service.dart';
import '../../../widgets/image_viewer_screen.dart';
import '../../../widgets/pdf_viewer_screen.dart';
import '../model/other_document_model.dart';

// lib/Screens/add_other_documents/controller/add_other_documents_controller.dart

// lib/Screens/other_documents/controller/other_documents_controller.dart


class OtherDocumentsController extends GetxController {
  final ApiClient _apiClient = ApiClient();

  final loading = false.obs;
  final documents = <OtherDocumentItem>[].obs;
  final selectedFiles = <File>[].obs;
  final selectedFileNames = <String>[].obs; // For custom document names

  // You'll need to pass the application ID when initializing this controller
  late String applicationId;

  void setApplicationId(String appId) {
    applicationId = appId;
    fetchOtherDocuments();
  }

  @override
  void onInit() {
    super.onInit();
    // fetchOtherDocuments will be called after setApplicationId is called
  }

  Future<void> fetchOtherDocuments() async {
    if (applicationId.isEmpty) { // Fixed: removed :: syntax error
      print('[OtherDocuments] No application ID set');
      return;
    }

    loading.value = true;
    print('[OtherDocuments] Fetching other documents for application: $applicationId');

    try {
      final response = await _apiClient.fetchOtherDocuments(applicationId);
      documents.value = response.data;
      print('[OtherDocuments] ✅ Loaded ${documents.length} documents');

      for (final doc in documents) {
        print('[OtherDocuments] - ${doc.documentName} (${doc.extension}) - ${doc.uploadedAt}');
      }
    } catch (e, stackTrace) {
      print('[OtherDocuments] ❌ Fetch error: $e');
      print('[OtherDocuments] Stack trace: $stackTrace');
      Get.snackbar(
        'Error',
        'Failed to load other documents',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } finally {
      loading.value = false;
    }
  }

  Future<void> pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final validFiles = <File>[];
        final validNames = <String>[];

        for (final platformFile in result.files) {
          if (platformFile.path != null) {
            final file = File(platformFile.path!);
            final fileSize = file.lengthSync();

            if (fileSize > 5 * 1024 * 1024) {
              Get.snackbar(
                'File Too Large',
                '${platformFile.name} exceeds 5MB limit',
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 3),
              );
              continue;
            }

            validFiles.add(file);
            // Use filename without extension as default document name
            validNames.add(path.basenameWithoutExtension(platformFile.name));
          }
        }

        selectedFiles.addAll(validFiles);
        selectedFileNames.addAll(validNames);
        print('[OtherDocuments] ✅ Selected ${validFiles.length} files');
      }
    } catch (e) {
      print('[OtherDocuments] ❌ Pick error: $e');
      Get.snackbar(
        'Error',
        'Failed to pick files',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  void removeSelectedFile(int index) {
    if (index >= 0 && index < selectedFiles.length) {
      selectedFiles.removeAt(index);
      selectedFileNames.removeAt(index);
    }
  }

  void updateFileName(int index, String newName) {
    if (index >= 0 && index < selectedFileNames.length) {
      selectedFileNames[index] = newName;
    }
  }

  Future<void> uploadDocuments() async {
    if (selectedFiles.isEmpty) {
      Get.snackbar(
        'No Files',
        'Please select files to upload',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    if (applicationId.isEmpty) { // Fixed: removed :: syntax error
      Get.snackbar(
        'Error',
        'Application ID not set',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    try {
      print('[OtherDocuments] 📤 Starting upload of ${selectedFiles.length} files...');

      final uploadCount = selectedFiles.length;

      await LoadingService.to.during(
        _uploadFilesSequentially(),
        message: 'Uploading $uploadCount document(s)...',
      );

      selectedFiles.clear();
      selectedFileNames.clear();

      print('[OtherDocuments] 🔄 Refreshing document list...');
      await fetchOtherDocuments();

      Get.snackbar(
        'Success',
        '$uploadCount document(s) uploaded successfully',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } catch (e, stackTrace) {
      print('[OtherDocuments] ❌ Upload error: $e');
      print('[OtherDocuments] Stack trace: $stackTrace');
      Get.snackbar(
        'Upload Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> _uploadFilesSequentially() async {
    int successCount = 0;

    for (int i = 0; i < selectedFiles.length; i++) {
      final file = selectedFiles[i];
      final documentName = selectedFileNames[i];

      print('[OtherDocuments] 📤 Uploading ${i + 1}/${selectedFiles.length}: $documentName');

      try {
        final response = await _apiClient.uploadOtherDocument(
          applicationId: applicationId,
          file: file,
          documentName: documentName,
        );

        if (response.status) {
          successCount++;
          print('[OtherDocuments] ✅ Upload successful: $documentName');
        } else {
          print('[OtherDocuments] ⚠️ Upload failed: $documentName - ${response.message}');
        }
      } catch (e) {
        print('[OtherDocuments] ❌ Upload error for $documentName: $e');
        throw Exception('Failed to upload $documentName: $e');
      }
    }

    print('[OtherDocuments] 📊 Upload complete: $successCount/${selectedFiles.length} successful');
  }

  Future<void> deleteDocument(OtherDocumentItem doc) async {
    try {
      // Show confirmation dialog
      final bool? confirm = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Delete Document'),
          content: Text('Are you sure you want to delete "${doc.documentName}"?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Delete'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      print('[OtherDocuments] 🗑️ Deleting document: ${doc.documentName}');

      await LoadingService.to.during(
        _deleteDocumentApi(doc),
        message: 'Deleting document...',
      );

      await fetchOtherDocuments();

      Get.snackbar(
        'Success',
        'Document deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('[OtherDocuments] ❌ Delete error: $e');
      Get.snackbar(
        'Delete Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> _deleteDocumentApi(OtherDocumentItem doc) async {
    final response = await _apiClient.deleteOtherDocument(doc.id.toString());

    if (!response.status) {
      throw Exception(response.message ?? 'Failed to delete document');
    }
  }

  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void viewDocument(OtherDocumentItem doc) {
    print('[OtherDocuments] 👁️ View requested: ${doc.documentName}');
    print('[OtherDocuments] URL: ${doc.fileUrl}');
    print('[OtherDocuments] Extension: ${doc.extension}');

    try {
      final extension = doc.extension.toUpperCase();

      if (extension == 'PDF') {
        // Open PDF viewer
        Get.to(() => PDFViewerScreen(
          documentUrl: doc.fileUrl,
          documentTitle: doc.documentName,
        ));
      } else if (['JPG', 'JPEG', 'PNG'].contains(extension)) {
        // Open image viewer
        Get.to(() => ImageViewerScreen(
          imageUrl: doc.fileUrl,
          imageTitle: doc.documentName,
        ));
      } else {
        Get.snackbar(
          'Unsupported File Type',
          'Cannot view ${doc.extension} files in-app',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      print('[OtherDocuments] ❌ View error: $e');
      Get.snackbar(
        'Error',
        'Failed to open document',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }
}
