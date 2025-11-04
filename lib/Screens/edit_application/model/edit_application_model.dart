// lib/Screens/edit_application/model/edit_application_model.dart
import 'dart:io';

class EditApplicationModel {
  String? customerName;
  String? coApplicantName; // ✅ ADD THIS

  String? phone;
  String? email;
  double? loanAmount;
  int? loanTypeId;
  int? statusId;
  int? bankId;
  int? agentId;      // ✅ ADD THIS
  int? employeeId;   // ✅ ADD THIS (assigned_to)
  double? monthlyIncome;
  String? notes;
  File? aadhaarFile;
  File? panCardFile;
  File? payslipFile;
  File? bankStatementFile;

  EditApplicationModel({
    this.customerName,
    this.coApplicantName, // ✅ ADD THIS

    this.phone,
    this.email,
    this.loanAmount,
    this.loanTypeId,
    this.statusId,
    this.bankId,
    this.agentId,      // ✅ ADD THIS
    this.employeeId,   // ✅ ADD THIS
    this.monthlyIncome,
    this.notes,
    this.aadhaarFile,
    this.panCardFile,
    this.payslipFile,
    this.bankStatementFile,
  });

  // Update toFormFields() method
  Map<String, String> toFormFields() {
    final fields = <String, String>{};

    if (customerName != null) fields['customer_name'] = customerName!;
    if (coApplicantName != null && coApplicantName!.isNotEmpty)
      fields['co_applicant_name'] = coApplicantName!; // ✅ ADD THIS
    if (phone != null) fields['phone'] = phone!;
    if (email != null) fields['email'] = email!;
    if (loanAmount != null) fields['loan_amount'] = loanAmount!.toString();
    if (loanTypeId != null) fields['loan_type_id'] = loanTypeId!.toString();
    if (statusId != null) fields['status_id'] = statusId!.toString();
    if (bankId != null) fields['bank_id'] = bankId!.toString();
    if (agentId != null) fields['agent_id'] = agentId!.toString();           // ✅ ADD THIS
    if (employeeId != null) fields['assigned_to'] = employeeId!.toString();  // ✅ ADD THIS
    if (monthlyIncome != null) fields['monthly_income'] = monthlyIncome!.toString();
    if (notes != null) fields['notes'] = notes!;

    return fields;
  }
}

class EditApplicationResponse {
  final bool success;
  final String message;
  final dynamic data;

  EditApplicationResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory EditApplicationResponse.fromJson(Map<String, dynamic> json) {
    return EditApplicationResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? 'Unknown error',
      data: json['data'],
    );
  }
}
