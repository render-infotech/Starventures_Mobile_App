// lib/Screens/Leads/models/lead_detail_model.dart

class LeadDetailResponse {
  final LeadDetail lead;

  LeadDetailResponse({
    required this.lead,
  });

  factory LeadDetailResponse.fromJson(Map<String, dynamic> json) {
    return LeadDetailResponse(
      lead: LeadDetail.fromJson(json['lead']),
    );
  }
}

class LeadDetail {
  final int id;
  final String name;
  final String phone;
  final String email;
  final String leadSource;
  final String? notes;
  final int statusId;
  final AssignedUser? assignedTo;
  final int createdBy;
  final int converted;
  final String createdAt;
  final String updatedAt;
  final LeadStatus status;

  LeadDetail({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.leadSource,
    this.notes,
    required this.statusId,
    this.assignedTo,
    required this.createdBy,
    required this.converted,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
  });

  factory LeadDetail.fromJson(Map<String, dynamic> json) {
    return LeadDetail(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      leadSource: json['lead_source'] ?? '',
      notes: json['notes'],
      statusId: json['status_id'] ?? 0,
      assignedTo: json['assigned_to'] != null
          ? AssignedUser.fromJson(json['assigned_to'])
          : null,
      createdBy: json['created_by'] ?? 0,
      converted: json['converted'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      status: LeadStatus.fromJson(json['status'] ?? {}),
    );
  }
}

class LeadStatus {
  final int id;
  final String name;
  final int status;
  final int order;

  LeadStatus({
    required this.id,
    required this.name,
    required this.status,
    required this.order,
  });

  factory LeadStatus.fromJson(Map<String, dynamic> json) {
    return LeadStatus(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      status: json['status'] ?? 0,
      order: json['order'] ?? 0,
    );
  }
}

class AssignedUser {
  final int id;
  final int userId;
  final String name;
  final String? dob;
  final String? gender;
  final String phone;
  final String? address;
  final String email;
  final String? employeeId;
  final int? branchId;
  final int? departmentId;
  final int? designationId;
  final String? companyDoj;
  final int isActive;

  AssignedUser({
    required this.id,
    required this.userId,
    required this.name,
    this.dob,
    this.gender,
    required this.phone,
    this.address,
    required this.email,
    this.employeeId,
    this.branchId,
    this.departmentId,
    this.designationId,
    this.companyDoj,
    required this.isActive,
  });

  factory AssignedUser.fromJson(Map<String, dynamic> json) {
    return AssignedUser(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      name: json['name'] ?? '',
      dob: json['dob'],
      gender: json['gender'],
      phone: json['phone'] ?? '',
      address: json['address'],
      email: json['email'] ?? '',
      employeeId: json['employee_id'],
      branchId: json['branch_id'],
      departmentId: json['department_id'],
      designationId: json['designation_id'],
      companyDoj: json['company_doj'],
      isActive: json['is_active'] ?? 0,
    );
  }
}
