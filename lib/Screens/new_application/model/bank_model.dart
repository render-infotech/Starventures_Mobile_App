// lib/Screens/new_application/model/bank_model.dart

class BankModel {
  final int id;
  final String name;
  final String bankLogo;

  BankModel({
    required this.id,
    required this.name,
    required this.bankLogo,
  });

  factory BankModel.fromJson(Map<String, dynamic> json) {
    return BankModel(
      id: json['id'] as int,
      name: json['name'] as String,
      bankLogo: json['bank_logo'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bank_logo': bankLogo,
    };
  }
}

// API Response Model
class BankResponse {
  final bool success;
  final String message;
  final List<BankModel> data;

  BankResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory BankResponse.fromJson(Map<String, dynamic> json) {
    return BankResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => BankModel.fromJson(item as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }
}
