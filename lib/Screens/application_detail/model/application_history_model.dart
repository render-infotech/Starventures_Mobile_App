// lib/models/application_history_model.dart
class ApplicationHistoryRequest {
  final String action;
  final String remarks;

  ApplicationHistoryRequest({
    required this.action,
    required this.remarks,
  });

  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'remarks': remarks,
    };
  }
}

class ApplicationHistoryResponse {
  final bool success;
  final String message;
  final ApplicationHistoryData? data;

  ApplicationHistoryResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ApplicationHistoryResponse.fromJson(Map<String, dynamic> json) {
    return ApplicationHistoryResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? ApplicationHistoryData.fromJson(json['data'])
          : null,
    );
  }
}

class ApplicationHistoryData {
  final int id;
  final String action;
  final String remarks;
  final String createdAt;

  ApplicationHistoryData({
    required this.id,
    required this.action,
    required this.remarks,
    required this.createdAt,
  });

  factory ApplicationHistoryData.fromJson(Map<String, dynamic> json) {
    return ApplicationHistoryData(
      id: json['id'] ?? 0,
      action: json['action'] ?? '',
      remarks: json['remarks'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}
