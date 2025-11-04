// lib/models/application_history_model.dart
import 'dart:convert';

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
    // ✅ If the JSON has a 'data' key, it's a successful response
    final hasData = json.containsKey('data') && json['data'] != null;

    return ApplicationHistoryResponse(
      success: hasData, // ✅ Set success to true if data exists
      message: json['message'] ?? '',
      data: hasData ? ApplicationHistoryData.fromJson(json['data']) : null,
    );
  }
}

class ApplicationHistoryData {
  final int id;
  final String action;
  final String remarks;
  final String createdBy;
  final String createdAt;

  ApplicationHistoryData({
    required this.id,
    required this.action,
    required this.remarks,
    required this.createdBy,
    required this.createdAt,
  });

  factory ApplicationHistoryData.fromJson(Map<String, dynamic> json) {
    return ApplicationHistoryData(
      id: json['id'] ?? 0,
      action: json['action'] ?? '',
      remarks: json['remarks'] ?? '',
      createdBy: json['created_by'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action': action,
      'remarks': remarks,
      'created_by': createdBy,
      'created_at': createdAt,
    };
  }
}

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
