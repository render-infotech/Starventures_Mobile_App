
class AttendanceData {
  final int id;
  final int employeeId;
  final DateTime date;
  final String status;
  final String? clockIn;
  final String? clockOut;
  final String late;
  final String earlyLeaving;
  final String overtime;
  final String totalRest;

  AttendanceData({
    required this.id,
    required this.employeeId,
    required this.date,
    required this.status,
    this.clockIn,
    this.clockOut,
    required this.late,
    required this.earlyLeaving,
    required this.overtime,
    required this.totalRest,
  });

  factory AttendanceData.fromJson(Map<String, dynamic> j) => AttendanceData(
    id: j['id'] ?? 0,
    employeeId: j['employee_id'] ?? 0,
    date: DateTime.parse(j['date']),
    status: j['status'] ?? 'Absent',
    clockIn: j['clock_in'],
    clockOut: j['clock_out'],
    late: j['late'] ?? '00:00:00',
    earlyLeaving: j['early_leaving'] ?? '00:00:00',
    overtime: j['overtime'] ?? '00:00:00',
    totalRest: j['total_rest'] ?? '00:00:00',
  );

  // Optional: derived working hours if API does not send it directly
  String get workingHours {
    // If API includes it, replace with that field.
    if (clockIn == null || clockOut == null || clockIn!.isEmpty || clockOut!.isEmpty) {
      return '--';
    }
    return _hhmmssDiff(clockIn!, clockOut!);
  }

  String _hhmmssDiff(String start, String end) {
    Duration parse(String s) {
      final p = s.split(':').map(int.parse).toList();
      return Duration(hours: p[0], minutes: p[1], seconds: p[2]);
    }
    final d = parse(end) - parse(start);
    if (d.isNegative) return '--';
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}
