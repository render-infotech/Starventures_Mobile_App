// lib/Screens/other_documents/model/other_document_model.dart

class OtherDocumentResponse {
  final List<OtherDocumentItem> data;

  OtherDocumentResponse({
    required this.data,
  });

  factory OtherDocumentResponse.fromJson(Map<String, dynamic> json) {
    return OtherDocumentResponse(
      data: (json['data'] as List?)
          ?.map((item) => OtherDocumentItem.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class OtherDocumentItem {
  final int id;
  final String documentName;
  final String fileUrl;
  final String filePath; // Add this field from API response
  final dynamic uploadedBy; // Change to dynamic to handle both int and string
  final String uploadedAt;

  OtherDocumentItem({
    required this.id,
    required this.documentName,
    required this.fileUrl,
    required this.filePath,
    required this.uploadedBy,
    required this.uploadedAt,
  });

  factory OtherDocumentItem.fromJson(Map<String, dynamic> json) {
    return OtherDocumentItem(
      id: json['id'] ?? 0,
      documentName: json['document_name'] ?? '',
      // Handle both file_url and file_path from different responses
      fileUrl: json['file_url'] ?? json['file_path'] ?? '',
      filePath: json['file_path'] ?? json['file_url'] ?? '',
      // Handle both int and string for uploaded_by
      uploadedBy: json['uploaded_by'] ?? '',
      uploadedAt: json['uploaded_at'] ?? json['created_at'] ?? '',
    );
  }

  String get extension {
    final url = fileUrl.isNotEmpty ? fileUrl : filePath;
    if (url.contains('.')) {
      return url.split('.').last.toUpperCase();
    }
    return 'FILE';
  }

  String get formattedDate {
    try {
      final DateTime dt = DateTime.parse(uploadedAt);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (e) {
      return uploadedAt;
    }
  }

  String get fileSize {
    return formattedDate;
  }

  // Helper getter to get uploadedBy as string
  String get uploadedByString {
    return uploadedBy?.toString() ?? '';
  }
}

class UploadOtherDocumentResponse {
  final bool status;
  final bool success; // Add this field to match API response
  final String? message;
  final OtherDocumentItem? data;

  UploadOtherDocumentResponse({
    required this.status,
    required this.success,
    this.message,
    this.data,
  });

  factory UploadOtherDocumentResponse.fromJson(Map<String, dynamic> json) {
    // Handle both 'status' and 'success' fields
    final isSuccess = json['success'] ?? json['status'] ?? false;

    return UploadOtherDocumentResponse(
      status: isSuccess,
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null
          ? OtherDocumentItem.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class DeleteOtherDocumentResponse {
  final bool status;
  final bool success; // Add this field to match API response
  final String? message;

  DeleteOtherDocumentResponse({
    required this.status,
    required this.success,
    this.message,
  });

  factory DeleteOtherDocumentResponse.fromJson(Map<String, dynamic> json) {
    // Handle both 'status' and 'success' fields
    final isSuccess = json['success'] ?? json['status'] ?? false;

    return DeleteOtherDocumentResponse(
      status: isSuccess,
      success: json['success'] ?? false,
      message: json['message'],
    );
  }
}
