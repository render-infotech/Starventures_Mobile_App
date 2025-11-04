class DeleteLeadResponse {
  final bool success;
  final String message;

  DeleteLeadResponse({
    required this.success,
    required this.message,
  });

  factory DeleteLeadResponse.fromJson(Map<String, dynamic> json) {
    return DeleteLeadResponse(
      success: json['success'] ?? json['status'] ?? false,
      message: json['message'] ?? '',
    );
  }
}
