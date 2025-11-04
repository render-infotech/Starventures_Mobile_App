// lib/Screens/attendance/model/monthly_leave.dart
class MonthlyLeave {
  final int id;
  final int leaveTypeId;
  final String leaveTypeTitle;
  final DateTime startDate;
  final DateTime endDate;
  final String totalLeaveDays;
  final String reason;
  final String remark;
  final String status;
  final DateTime appliedOn;

  MonthlyLeave({
    required this.id,
    required this.leaveTypeId,
    required this.leaveTypeTitle,
    required this.startDate,
    required this.endDate,
    required this.totalLeaveDays,
    required this.reason,
    required this.remark,
    required this.status,
    required this.appliedOn,
  });

  factory MonthlyLeave.fromJson(Map<String, dynamic> j) => MonthlyLeave(
    id: j['id'] ?? 0,
    leaveTypeId: j['leave_type_id'] ?? 0,
    leaveTypeTitle: (j['leave_type']?['title'] ?? '').toString(),
    startDate: DateTime.parse(j['start_date']),
    endDate: DateTime.parse(j['end_date']),
    totalLeaveDays: j['total_leave_days']?.toString() ?? '0',
    reason: (j['leave_reason'] ?? '').toString(),
    remark: (j['remark'] ?? '').toString(),
    status: (j['status'] ?? '').toString(),
    appliedOn: DateTime.parse(j['applied_on']),
  );
}
