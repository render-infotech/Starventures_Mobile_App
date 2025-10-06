// lib/models/clock_in_response_model.dart
import 'geosentry_model.dart';
import 'clock_in_data_model.dart';

class ClockInResponseModel {
  final bool status;
  final String message;
  final ClockInDataModel data;
  final GeosentryModel geosentry;

  ClockInResponseModel({
    required this.status,
    required this.message,
    required this.data,
    required this.geosentry,
  });

  factory ClockInResponseModel.fromJson(Map<String, dynamic> json) {
    return ClockInResponseModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: ClockInDataModel.fromJson(json['data'] ?? {}),
      geosentry: GeosentryModel.fromJson(json['geosentry'] ?? {}),
    );
  }
}
