// lib/Screens/new_application/model/employee_model.dart

class EmployeeModel {
  final int id;
  final String name;
  final int branchId;

  EmployeeModel({
    required this.id,
    required this.name,
    required this.branchId,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      branchId: json['branch_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'branch_id': branchId,
    };
  }
}

class EmployeeResponse {
  final bool success;
  final String message;
  final List<EmployeeModel> data;

  EmployeeResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory EmployeeResponse.fromJson(Map<String, dynamic> json) {
    return EmployeeResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => EmployeeModel.fromJson(item as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }
}
