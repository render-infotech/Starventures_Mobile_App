// lib/models/create_application_model.dart
import 'dart:io';

class CreateApplicationModel {
  final String customerName;
  String? coApplicantName;
  final String phoneNumber;
  final String email;
  final String loanAmount;
  final int loanTypeId;
  final int statusId;
  final String monthlyIncome;
  final String notes;
  final File? aadhaarFile;
  final File? panCardFile;
  final int? agentId;
  final int? bankId;
  final int? employeeId; // ✅ Added

  CreateApplicationModel({
    required this.customerName,
    this.coApplicantName,
    required this.phoneNumber,
    required this.email,
    required this.loanAmount,
    required this.loanTypeId,
    required this.statusId,
    required this.monthlyIncome,
    required this.notes,
    this.aadhaarFile,
    this.panCardFile,
    this.agentId,
    this.bankId,
    this.employeeId, // ✅ Added
  });

  Map<String, String> toFormFields() {
    final map = <String, String>{
      'customer_name': customerName,
      if (coApplicantName != null && coApplicantName!.isNotEmpty)  // ✅ NEW: Only add if not empty
        'co_applicant_name': coApplicantName!,
      'email': email,
      'phone': '+91$phoneNumber',
      'loan_amount': loanAmount,
      'loan_type_id': loanTypeId.toString(),
      'status_id': statusId.toString(),
      'monthly_income': monthlyIncome,
      'notes': notes,
    };

    if (agentId != null) {
      map['agent_id'] = agentId.toString();
    }

    if (bankId != null) {
      map['bank_id'] = bankId.toString();
    }

    // ✅ Add employee_id to payload
    if (employeeId != null) {
      map['assigned_to'] = employeeId.toString();
    }

    return map;
  }
}

// API Response Model
class CreateApplicationResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  CreateApplicationResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory CreateApplicationResponse.fromJson(Map<String, dynamic> json) {
    return CreateApplicationResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
    );
  }
}
