// lib/Screens/Leads/model/lead_model.dart

import '../../app_export/app_export.dart' show Color;
// lib/Screens/Leads/model/lead_model.dart

import 'package:flutter/material.dart';

class LeadStatus {
  final int id;
  final String name;
  final int status;
  final int order;
  final int createdBy;
  final String createdAt;
  final String updatedAt;

  LeadStatus({
    required this.id,
    required this.name,
    required this.status,
    required this.order,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LeadStatus.fromJson(Map<String, dynamic> json) {
    return LeadStatus(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      status: json['status'] ?? 0,
      order: json['order'] ?? 0,
      createdBy: json['created_by'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class LeadModel {
  final int id;
  final String name;
  final String phone;
  final String email;
  final String leadSource;
  final String? notes;
  final int statusId;
  final int assignedTo;
  final int createdBy;
  final int converted;
  final String createdAt;
  final String updatedAt;
  final LeadStatus status;

  LeadModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.leadSource,
    this.notes,
    required this.statusId,
    required this.assignedTo,
    required this.createdBy,
    required this.converted,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
  });

  factory LeadModel.fromJson(Map<String, dynamic> json) {
    return LeadModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      leadSource: json['lead_source'] ?? '',
      notes: json['notes'],
      statusId: json['status_id'] ?? 0,
      assignedTo: json['assigned_to'] ?? 0,
      createdBy: json['created_by'] ?? 0,
      converted: json['converted'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      status: LeadStatus.fromJson(json['status'] ?? {}),
    );
  }

  // Helper method to get formatted date
  String get formattedDate {
    try {
      final dateTime = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays == 0) {
        return 'Added today';
      } else if (difference.inDays == 1) {
        return 'Added 1 day ago';
      } else if (difference.inDays < 7) {
        return 'Added ${difference.inDays} days ago';
      } else if (difference.inDays < 30) {
        return 'Added ${(difference.inDays / 7).floor()} weeks ago';
      } else {
        return 'Added ${(difference.inDays / 30).floor()} months ago';
      }
    } catch (e) {
      return 'Recently added';
    }
  }

  // Helper to get source color
  Color get sourceColor {
    switch (leadSource.toLowerCase()) {
      case 'website':
      case 'seo':
        return const Color(0xFF3FC2A2);
      case 'referral':
        return const Color(0xFFFFA000);
      case 'linkedin':
        return const Color(0xFF0077B5);
      case 'facebook':
        return const Color(0xFF1877F2);
      case 'instagram':
        return const Color(0xFFE4405F);
      case 'google':
        return const Color(0xFF4285F4);
      default:
        return const Color(0xFF6C63FF);
    }
  }

  // Helper to get status color
  Color get statusColor {
    switch (status.name.toLowerCase()) {
      case 'new':
        return const Color(0xFF3FC2A2);
      case 'contacted':
        return const Color(0xFF1E88E5);
      case 'qualified':
        return const Color(0xFFFFA000);
      case 'lost':
        return const Color(0xFFE53935);
      case 'converted':
        return const Color(0xFF4CAF50);
      default:
        return const Color(0xFF6C63FF);
    }
  }
}

class LeadMeta {
  final int total;
  final int converted;
  final int inProgress;
  final int lost;

  LeadMeta({
    required this.total,
    required this.converted,
    required this.inProgress,
    required this.lost,
  });

  factory LeadMeta.fromJson(Map<String, dynamic> json) {
    return LeadMeta(
      total: json['total'] ?? 0,
      converted: json['converted'] ?? 0,
      inProgress: json['in_progress'] ?? 0,
      lost: json['lost'] ?? 0,
    );
  }
}

class LeadsResponse {
  final List<LeadModel> data;
  final LeadMeta meta;

  LeadsResponse({
    required this.data,
    required this.meta,
  });

  factory LeadsResponse.fromJson(Map<String, dynamic> json) {
    return LeadsResponse(
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => LeadModel.fromJson(item as Map<String, dynamic>))
          .toList() ??
          [],
      meta: LeadMeta.fromJson(json['meta'] ?? {}),
    );
  }
}
