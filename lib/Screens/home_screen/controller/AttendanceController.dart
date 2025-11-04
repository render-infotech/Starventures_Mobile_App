import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/data/api_client/api_client.dart';
import '../model/attendance_model.dart'; // adjust path
// import model file

class AttendanceController extends GetxController {
  final loading = false.obs;
  final calendarFormat = CalendarFormat.month.obs;

  final selectedDay = Rxn<DateTime>();
  final focusedDay = DateTime.now().obs;

  final selectedDayAttendance = Rxn<AttendanceData>();
  final Map<DateTime, List<AttendanceData>> _events = {};

  final _api = ApiClient();

  DateTime _key(DateTime d) => DateTime(d.year, d.month, d.day);


  @override
  void onInit() {
    super.onInit();
    forceRefresh();
  }

  Future<void> forceRefresh() async {
    // Load the focused month for markers, then today’s detail
    await fetchMonth(focusedDay.value.year, focusedDay.value.month);
    await fetchForDate(_key(DateTime.now()));
  }

  Future<void> refreshAttendance() async {
    // Refresh current month and selected day
    await fetchMonth(focusedDay.value.year, focusedDay.value.month);
    if (selectedDay.value != null) {
      await fetchForDate(selectedDay.value!);
    }
  }

  // TableCalendar data source
  List<AttendanceData> getEventsForDay(DateTime day) => _events[_key(day)] ?? [];

  void onDaySelected(DateTime selected, DateTime focused) async {
    focusedDay.value = focused;
    await fetchForDate(_key(selected));
  }

  // Fetch per-day details (fills detail card and event for that date)
  Future<void> fetchForDate(DateTime date) async {
    try {
      loading.value = true;
      selectedDay.value = _key(date);
      selectedDayAttendance.value = null;

      final resp = await _api.getAttendanceDetailsByDate(_fmt(date));
      final List raw = (resp['data'] ?? []) as List;

      if (raw.isNotEmpty) {
        final logs = raw.map((e) => AttendanceData.fromJson(e as Map<String, dynamic>)).toList();
        // Choose the last or the best record for the card; here, take last
        final picked = logs.last;
        _events[_key(date)] = [picked];
        selectedDayAttendance.value = picked;
      } else {
        _events[_key(date)] = [];
        selectedDayAttendance.value = null;
      }
    } finally {
      loading.value = false;
    }
  }

  // Fetch full month for markers and quick taps
  Future<void> fetchMonth(int year, int month) async {
    try {
      loading.value = true;
      final resp = await _api.getAttendanceMonthly(month: month, year: year);
      final List raw = (resp['data'] ?? []) as List;

      // Group logs by date key
      final Map<DateTime, List<AttendanceData>> grouped = {};
      for (final item in raw) {
        final model = AttendanceData.fromJson(item as Map<String, dynamic>);
        final k = _key(model.date);
        (grouped[k] ??= []).add(model);
      }

      // For each day, choose a representative for the marker and quick detail
      grouped.forEach((k, list) {
        // Strategy: pick the last log of day to display on marker
        final picked = list.last;
        _events[k] = [picked];
      });

      // If selected day is in this month and not set yet, hydrate detail from cache
      if (selectedDay.value != null) {
        final list = _events[_key(selectedDay.value!)] ?? [];
        selectedDayAttendance.value = list.isNotEmpty ? list.first : null;
      }
    } finally {
      loading.value = false;
    }
  }

  String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // UI helpers
  Color getStatusColor(AttendanceData a) {
    switch (a.status.toLowerCase()) {
      case 'present': return Colors.green;
      case 'late': return Colors.orange;
      case 'absent': return Colors.red;
      case 'holiday': return Colors.blue;
      default: return Colors.grey;
    }
  }

  String formatTime(String? hhmmss) => (hhmmss == null || hhmmss.isEmpty || hhmmss == '00:00:00') ? '--' : hhmmss;

  String calculateWorkingHours(AttendanceData a) => a.workingHours;
}
