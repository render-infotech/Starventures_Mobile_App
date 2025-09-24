// lib/Screens/profile/models/profile_models.dart

class ProfileResponse {
  final bool status;
  final ProfileData data;

  ProfileResponse({required this.status, required this.data});

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      status: json['status'] as bool? ?? false,
      data: ProfileData.fromJson(json['data'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class ProfileData {
  final User user;
  final Employee employee;

  ProfileData({required this.user, required this.employee});

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      user: User.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
      employee: Employee.fromJson(json['employee'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class User {
  final int id;
  final int? branchId;
  final String name;
  final String email;
  final String? type;
  final String? avatar;

  User({
    required this.id,
    this.branchId,
    required this.name,
    required this.email,
    this.type,
    this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int? ?? 0,
      branchId: json['branch_id'] as int?,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      type: json['type'] as String?,
      avatar: json['avatar'] as String?,
    );
  }
}

class Employee {
  final int id;
  final int userId;
  final String name;
  final String? phone;
  final String? employeeId;
  final String? email;

  Employee({
    required this.id,
    required this.userId,
    required this.name,
    this.phone,
    this.employeeId,
    this.email,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String?,
      employeeId: json['employee_id'] as String?,
      email: json['email'] as String?,
    );
  }
}
