// lib/models/create_application_model.dart
import 'dart:io';

class CreateApplicationModel {
  final String customerName;
  final String phoneNumber;
  final String email;
  final String loanAmount;
  final int loanTypeId; // Changed to match API payload
  final int statusId;   // Changed to match API payload
  final String monthlyIncome;
  final String notes;   // Changed to match API payload
  final File? aadhaarFile;
  final File? panCardFile; // Changed to match API payload
  final int agentId;

  CreateApplicationModel({
    required this.customerName,
    required this.phoneNumber,
    required this.email,
    required this.loanAmount,
    required this.loanTypeId,
    required this.statusId,
    required this.monthlyIncome,
    required this.notes,
    this.aadhaarFile,
    this.panCardFile,
    required this.agentId,
  });

  // Convert to form fields matching API payload
  Map<String, String> toFormFields() {
    return {
      'customer_name': customerName,
      'email': email,
      'phone': phoneNumber,
      'loan_amount': loanAmount,
      'agent_id': agentId.toString(),
      'loan_type_id': loanTypeId.toString(),
      'status_id': statusId.toString(),
      'monthly_income': monthlyIncome,
      'notes': notes,
    };
  }

  @override
  String toString() {
    return 'CreateApplicationModel{customerName: $customerName, phoneNumber: $phoneNumber, email: $email, loanAmount: $loanAmount, loanTypeId: $loanTypeId, statusId: $statusId, monthlyIncome: $monthlyIncome, notes: $notes}';
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
