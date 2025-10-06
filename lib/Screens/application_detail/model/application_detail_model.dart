import 'package:flutter/material.dart';

import 'dart:convert';
import '../../applications/model/application_model.dart';

class ApplicationDetailResponse {
  final ApplicationDetailData data;

  ApplicationDetailResponse({
    required this.data,
  });

  factory ApplicationDetailResponse.fromJson(Map<String, dynamic> json) {
    return ApplicationDetailResponse(
      data: ApplicationDetailData.fromJson(json['data'] ?? {}),
    );
  }
}

class ApplicationDetailData {
  final String id;
  final String customerName;
  final String email;
  final String phone;
  final double loanAmount;
  final String loanType;
  final String status;
  final double monthlyIncome;
  final AssignedTo? assignedTo;
  final CreatedBy? createdBy;
  final String? notes;
  final String? aadhaarFileUrl;
  final String? panCardFileUrl;
  final String? payslipFileUrl;
  final String? bankStatementFileUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  ApplicationDetailData({
    required this.id,
    required this.customerName,
    required this.email,
    required this.phone,
    required this.loanAmount,
    required this.loanType,
    required this.status,
    required this.monthlyIncome,
    this.assignedTo,
    this.createdBy,
    this.notes,
    this.aadhaarFileUrl,
    this.panCardFileUrl,
    this.payslipFileUrl,
    this.bankStatementFileUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ApplicationDetailData.fromJson(Map<String, dynamic> json) {
    return ApplicationDetailData(
      id: json['id']?.toString() ?? '',
      customerName: json['customer_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      loanAmount: double.tryParse(json['loan_amount']?.toString() ?? '0') ?? 0.0,
      loanType: json['loan_type'] ?? '',
      status: json['status'] ?? '',
      monthlyIncome: double.tryParse(json['monthly_income']?.toString() ?? '0') ?? 0.0,
      assignedTo: json['assigned_to'] != null ? AssignedTo.fromJson(json['assigned_to']) : null,
      createdBy: json['created_by'] != null ? CreatedBy.fromJson(json['created_by']) : null,
      notes: json['notes'],
      aadhaarFileUrl: json['aadhaar_file_url'],
      panCardFileUrl: json['pan_card_file_url'],
      payslipFileUrl: json['payslip_file_url'],
      bankStatementFileUrl: json['bank_statement_file_url'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  // Helper method to get status enum
  ApplicationStatus get statusEnum {
    switch (status.toLowerCase()) {
      case 'approved':
        return ApplicationStatus.approved;
      case 'rejected':
        return ApplicationStatus.rejected;
      case 'pending':
        return ApplicationStatus.pending;
      default:
        return ApplicationStatus.processing;
    }
  }

  // Helper method to get formatted amount
  String get formattedAmount {
    return '₹${_formatINR(loanAmount.toInt())}';
  }

  // Helper method to get formatted monthly income
  String get formattedMonthlyIncome {
    return '₹${_formatINR(monthlyIncome.toInt())}';
  }

  // Format as Indian currency
  String _formatINR(int amount) {
    final s = amount.toString();
    if (s.length <= 3) return s;
    final last3 = s.substring(s.length - 3);
    String rest = s.substring(0, s.length - 3);
    final buf = StringBuffer();
    while (rest.length > 2) {
      buf.write('${rest.substring(rest.length - 2)},');
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) buf.write(rest);
    final commas = buf.toString().split('').reversed.join();
    return '$commas,$last3';
  }
}
