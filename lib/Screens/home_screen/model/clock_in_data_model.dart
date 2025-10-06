// lib/models/clock_in_data_model.dart
class ClockInDataModel {
  final int employeeId;
  final String date;
  final String status;
  final String clockIn;
  final String clockOut;
  final String late;
  final String earlyLeaving;
  final String overtime;
  final String totalRest;
  final String createdBy;
  final String updatedAt;
  final String createdAt;
  final int id;

  ClockInDataModel({
    required this.employeeId,
    required this.date,
    required this.status,
    required this.clockIn,
    required this.clockOut,
    required this.late,
    required this.earlyLeaving,
    required this.overtime,
    required this.totalRest,
    required this.createdBy,
    required this.updatedAt,
    required this.createdAt,
    required this.id,
  });

  factory ClockInDataModel.fromJson(Map<String, dynamic> json) {
    return ClockInDataModel(
      employeeId: json['employee_id'] ?? 0,
      date: json['date'] ?? '',
      status: json['status'] ?? '',
      clockIn: json['clock_in'] ?? '',
      clockOut: json['clock_out'] ?? '',
      late: json['late'] ?? '',
      earlyLeaving: json['early_leaving'] ?? '',
      overtime: json['overtime'] ?? '',
      totalRest: json['total_rest'] ?? '',
      createdBy: json['created_by'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      createdAt: json['created_at'] ?? '',
      id: json['id'] ?? 0,
    );
  }
}
