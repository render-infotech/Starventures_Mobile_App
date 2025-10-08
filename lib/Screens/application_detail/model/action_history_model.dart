// lib/models/action_history_model.dart
import 'package:intl/intl.dart';

class ActionHistoryItem {
  final int id;
  final String action;
  final String remarks;
  final String createdAt;

  ActionHistoryItem({
    required this.id,
    required this.action,
    required this.remarks,
    required this.createdAt,
  });

  factory ActionHistoryItem.fromJson(Map<String, dynamic> json) {
    return ActionHistoryItem(
      id: json['id'] ?? 0,
      action: json['action'] ?? '',
      remarks: json['remarks'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

  // Helper method to format date
  String get formattedDate {
    try {
      final dateTime = DateTime.parse(createdAt);
      return DateFormat('MMM dd, yyyy • hh:mm a').format(dateTime);
    } catch (e) {
      return createdAt;
    }
  }

  // Helper method to get relative time
  String get timeAgo {
    try {
      final dateTime = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return '';
    }
  }
}

class ActionHistoryResponse {
  final bool success;
  final String message;
  final List<ActionHistoryItem> data;

  ActionHistoryResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ActionHistoryResponse.fromJson(Map<String, dynamic> json) {
    var dataList = json['data'] as List? ?? [];
    List<ActionHistoryItem> historyItems = dataList
        .map((item) => ActionHistoryItem.fromJson(item))
        .toList();

    return ActionHistoryResponse(
      success: json['success'] ?? true, // Assuming success if data is present
      message: json['message'] ?? '',
      data: historyItems,
    );
  }
}
