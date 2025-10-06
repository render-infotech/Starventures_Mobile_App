// lib/models/application_type_model.dart
class ApplicationTypeModel {
  final int id;
  final String name;

  ApplicationTypeModel({
    required this.id,
    required this.name,
  });

  factory ApplicationTypeModel.fromJson(Map<String, dynamic> json) {
    return ApplicationTypeModel(
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
    return 'ApplicationTypeModel{id: $id, name: $name}';
  }
}

// Response wrapper for Application Types
class ApplicationTypeResponse {
  final bool success;
  final String message;
  final List<ApplicationTypeModel> data;

  ApplicationTypeResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ApplicationTypeResponse.fromJson(Map<String, dynamic> json) {
    var dataList = json['data'] as List? ?? [];
    List<ApplicationTypeModel> applicationTypes = dataList
        .map((item) => ApplicationTypeModel.fromJson(item))
        .toList();

    return ApplicationTypeResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: applicationTypes,
    );
  }
}
