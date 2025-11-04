// lib/Screens/documents/model/document_model.dart

class DocumentResponse {
  final bool status;
  final List<DocumentItem> data;

  DocumentResponse({
    required this.status,
    required this.data,
  });

  factory DocumentResponse.fromJson(Map<String, dynamic> json) {
    return DocumentResponse(
      status: json['status'] ?? false,
      data: (json['data'] as List?)
          ?.map((item) => DocumentItem.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class DocumentItem {
  final int id;
  final String title;
  final String? description;
  final String fileName;
  final String fileType;
  final String fileUrl;
  final String uploadedAt;

  DocumentItem({
    required this.id,
    required this.title,
    this.description,
    required this.fileName,
    required this.fileType,
    required this.fileUrl,
    required this.uploadedAt,
  });

  factory DocumentItem.fromJson(Map<String, dynamic> json) {
    return DocumentItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      fileName: json['file_name'] ?? '',
      fileType: json['file_type'] ?? '',
      fileUrl: json['file_url'] ?? '',
      uploadedAt: json['uploaded_at'] ?? '',
    );
  }

  String get extension {
    if (fileName.contains('.')) {
      return fileName.split('.').last.toUpperCase();
    }
    // Fallback: parse from file_type
    if (fileType.contains('pdf')) return 'PDF';
    if (fileType.contains('png')) return 'PNG';
    if (fileType.contains('jpeg') || fileType.contains('jpg')) return 'JPG';
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

  // Since API doesn't provide file size, show the upload date instead
  String get fileSize {
    return formattedDate;
  }

// Alternative: If you want to show "Unknown size"
// String get fileSize => 'Unknown';
}

class UploadDocumentResponse {
  final bool status;
  final String? message;
  final DocumentItem? data;

  UploadDocumentResponse({
    required this.status,
    this.message,
    this.data,
  });

  factory UploadDocumentResponse.fromJson(Map<String, dynamic> json) {
    return UploadDocumentResponse(
      status: json['status'] ?? false,
      message: json['message'],
      data: json['data'] != null
          ? DocumentItem.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}
