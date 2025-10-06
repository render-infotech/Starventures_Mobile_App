// lib/models/geosentry_model.dart
class GeosentryModel {
  final String userId;
  final String apiKey;
  final String cipherKey;

  GeosentryModel({
    required this.userId,
    required this.apiKey,
    required this.cipherKey,
  });

  factory GeosentryModel.fromJson(Map<String, dynamic> json) {
    return GeosentryModel(
      userId: json['user_id'] ?? '',
      apiKey: json['api_key'] ?? '',
      cipherKey: json['ciper_key'] ?? '', // Note: API has typo "ciper_key"
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'api_key': apiKey,
      'ciper_key': cipherKey,
    };
  }
}
