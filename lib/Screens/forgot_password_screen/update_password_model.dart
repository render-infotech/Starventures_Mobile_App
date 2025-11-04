class UpdatePasswordRequest {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  UpdatePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'current_password': currentPassword,
      'new_password': newPassword,
      'confirm_password': confirmPassword,
    };
  }
}

class UpdatePasswordResponse {
  final bool success;
  final String message;

  UpdatePasswordResponse({
    required this.success,
    required this.message,
  });

  factory UpdatePasswordResponse.fromJson(Map<String, dynamic> json) {
    return UpdatePasswordResponse(
      success: json['status'] == true, // Parse 'status' field as boolean
      message: json['message'] ?? '',
    );
  }
}

