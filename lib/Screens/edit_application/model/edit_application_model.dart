// lib/Screens/edit_application/model/edit_application_model.dart
import 'dart:io';

class EditApplicationModel {
  String? customerName;
  String? phone;
  String? email;
  double? loanAmount;
  int? loanTypeId;  // Changed to match API payload
  int? statusId;    // Added status_id
  //int? agentId;     // Added agent_id
  double? monthlyIncome;
  String? notes;
  File? aadhaarFile;
  File? panCardFile;
  File? payslipFile;
  File? bankStatementFile;

  EditApplicationModel({
    this.customerName,
    this.phone,
    this.email,
    this.loanAmount,
    this.loanTypeId,
    this.statusId,
   // this.agentId,
    this.monthlyIncome,
    this.notes,
    this.aadhaarFile,
    this.panCardFile,
    this.payslipFile,
    this.bankStatementFile,
  });

  // Convert to form fields for API submission - matching exact payload structure
  Map<String, String> toFormFields() {
    final fields = <String, String>{};

    if (customerName != null) fields['customer_name'] = customerName!;
    if (phone != null) fields['phone'] = phone!;
    if (email != null) fields['email'] = email!;
    if (loanAmount != null) fields['loan_amount'] = loanAmount!.toString();
    if (loanTypeId != null) fields['loan_type_id'] = loanTypeId!.toString();
    if (statusId != null) fields['status_id'] = statusId!.toString();
    //if (agentId != null) fields['agent_id'] = agentId!.toString();
    if (monthlyIncome != null) fields['monthly_income'] = monthlyIncome!.toString();
    if (notes != null) fields['notes'] = notes!;

    return fields;
  }

  // Create from application detail data (for autofill)
  factory EditApplicationModel.fromApplicationDetail(dynamic detailData) {
    return EditApplicationModel(
      customerName: detailData.customerName,
      phone: detailData.phone,
      email: detailData.email,
      loanAmount: detailData.loanAmount,
      monthlyIncome: detailData.monthlyIncome,
      notes: detailData.notes,
      // Note: You'll need to get the IDs from the detail data
      // These might need to be mapped from names to IDs
    );
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
