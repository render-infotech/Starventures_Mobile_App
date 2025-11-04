import 'package:flutter/material.dart';

import 'dart:convert';
import '../../applications/model/application_model.dart';
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
  final String? coApplicantName; // ✅ ADD THIS

  final String email;
  final String phone;
  final double loanAmount;
  final String loanType;
  final String status;
  final double monthlyIncome;
  final BankInfo? bank;  // Added bank field
  final AssignedTo? assignedTo;
  final AgentAssigned? agentAssigned;  // ✅ Add Agent
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
    this.coApplicantName, // ✅ ADD THIS

    required this.email,
    required this.phone,
    required this.loanAmount,
    required this.loanType,
    required this.status,
    required this.monthlyIncome,
    this.bank,  // Added bank field
    this.assignedTo,
    this.agentAssigned,  // ✅ Add Agent
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
      coApplicantName: json['co_applicant_name'], // ✅ ADD THIS

      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      loanAmount: double.tryParse(json['loan_amount']?.toString() ?? '0') ?? 0.0,
      loanType: json['loan_type'] ?? '',
      status: json['status'] ?? '',
      monthlyIncome: double.tryParse(json['monthly_income']?.toString() ?? '0') ?? 0.0,
      bank: json['bank'] != null ? BankInfo.fromJson(json['bank']) : null,  // Parse bank data
      assignedTo: json['assigned_to'] != null ? AssignedTo.fromJson(json['assigned_to']) : null,
      agentAssigned: json['agentAssigned'] != null ? AgentAssigned.fromJson(json['agentAssigned']) : null,  // ✅ Parse agent

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


  // Helper method to get formatted amount - FIXED
  String get formattedAmount {
    return '₹${_formatINR(loanAmount)}';
  }

  // Helper method to get formatted monthly income - FIXED
  String get formattedMonthlyIncome {
    return '₹${_formatINR(monthlyIncome)}';
  }

  // Format as Indian currency - FIXED VERSION
  String _formatINR(double amount) {
    // Round to avoid floating point precision issues
    final intAmount = amount.round();
    final s = intAmount.toString();

    if (s.length <= 3) return s;

    final last3 = s.substring(s.length - 3);
    String remaining = s.substring(0, s.length - 3);

    // Build the comma-separated format from right to left
    final List<String> parts = [];
    while (remaining.length > 2) {
      parts.add(remaining.substring(remaining.length - 2));
      remaining = remaining.substring(0, remaining.length - 2);
    }

    if (remaining.isNotEmpty) {
      parts.add(remaining);
    }

    // Reverse and join with commas
    return '${parts.reversed.join(',')},${last3}';
  }
}
// ✅ Add AgentAssigned model
class AgentAssigned {
  final int id;
  final String name;

  AgentAssigned({
    required this.id,
    required this.name,
  });

  factory AgentAssigned.fromJson(Map<String, dynamic> json) {
    return AgentAssigned(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

// Bank Info Model
class BankInfo {
  final int id;
  final String name;
  final String? bankLogo;

  BankInfo({
    required this.id,
    required this.name,
    this.bankLogo,
  });

  factory BankInfo.fromJson(Map<String, dynamic> json) {
    return BankInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      bankLogo: json['bank_logo'],
    );
  }
}

class AssignedTo {
  final int id;
  final String name;

  AssignedTo({
    required this.id,
    required this.name,
  });

  factory AssignedTo.fromJson(Map<String, dynamic> json) {
    return AssignedTo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class CreatedBy {
  final int id;
  final String name;

  CreatedBy({
    required this.id,
    required this.name,
  });

  factory CreatedBy.fromJson(Map<String, dynamic> json) {
    return CreatedBy(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}
