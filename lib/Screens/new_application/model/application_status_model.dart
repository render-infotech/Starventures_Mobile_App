// lib/models/application_status_model.dart
class ApplicationStatusModel {
  final int id;
  final String name;

  ApplicationStatusModel({
    required this.id,
    required this.name,
  });

  factory ApplicationStatusModel.fromJson(Map<String, dynamic> json) {
    return ApplicationStatusModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  String toString() {
    return 'ApplicationStatusModel{id: $id, name: $name}';
  }
}

// Response wrapper for Application Statuses
class ApplicationStatusResponse {
  final bool success;
  final String message;
  final List<ApplicationStatusModel> data;

  ApplicationStatusResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ApplicationStatusResponse.fromJson(Map<String, dynamic> json) {
    var dataList = json['data'] as List? ?? [];
    List<ApplicationStatusModel> applicationStatuses = dataList
        .map((item) => ApplicationStatusModel.fromJson(item))
        .toList();

    return ApplicationStatusResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: applicationStatuses,
    );
  }
}
