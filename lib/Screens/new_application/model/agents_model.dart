class AgentModel {
  final int id;
  final String name;
  final int branchId;

  AgentModel({
    required this.id,
    required this.name,
    required this.branchId,
  });

  factory AgentModel.fromJson(Map<String, dynamic> json) {
    return AgentModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      branchId: json['branch_id'] ?? 0,
    );
  }

  @override
  String toString() {
    return 'AgentModel{id: $id, name: $name, branchId: $branchId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AgentModel &&
        other.id == id &&
        other.name == name &&
        other.branchId == branchId;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ branchId.hashCode;
}

class AgentsResponse {
  final bool success;
  final String message;
  final List<AgentModel> data;

  AgentsResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AgentsResponse.fromJson(Map<String, dynamic> json) {
    return AgentsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => AgentModel.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}
