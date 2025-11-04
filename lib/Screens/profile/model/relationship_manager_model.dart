class RelationshipManagerResponse {
  final bool status;
  final RelationshipManagerData data;

  RelationshipManagerResponse({
    required this.status,
    required this.data,
  });

  factory RelationshipManagerResponse.fromJson(Map<String, dynamic> json) {
    return RelationshipManagerResponse(
      status: json['status'] ?? false,
      data: RelationshipManagerData.fromJson(json['data'] ?? {}),
    );
  }
}

class RelationshipManagerData {
  final RelationshipManager relationshipManager;

  RelationshipManagerData({
    required this.relationshipManager,
  });

  factory RelationshipManagerData.fromJson(Map<String, dynamic> json) {
    return RelationshipManagerData(
      relationshipManager: RelationshipManager.fromJson(
        json['relationship_manager'] ?? {},
      ),
    );
  }
}

class RelationshipManager {
  final String? name;
  final String? phone;

  RelationshipManager({
    this.name,
    this.phone,
  });

  factory RelationshipManager.fromJson(Map<String, dynamic> json) {
    return RelationshipManager(
      name: json['name'],
      phone: json['phone'],
    );
  }

  // Helper to check if RM is available
  bool get isAvailable => name != null && name!.isNotEmpty;

  // Helper to get initials
  String get initials {
    if (name == null || name!.isEmpty) return '';
    final parts = name!.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return (parts[0].substring(0, 1) + parts[parts.length - 1].substring(0, 1))
        .toUpperCase();
  }
}
