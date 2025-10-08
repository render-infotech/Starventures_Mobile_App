// lib/Screens/attendance/controller/attendance_controller.dart

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/data/api_client/api_client.dart';
import '../../home_screen/model/dashboard_model.dart';
import '../../home_screen/controller/home_controller.dart';

class AttendanceController extends GetxController {
  final ApiClient apiClient = ApiClient();

  // Calendar state
  var calendarFormat = CalendarFormat.month.obs;
  var focusedDay = DateTime.now().obs;
  var selectedDay = Rx<DateTime?>(null);

  // Attendance data
  var attendanceHistory = <DateTime, List<AttendanceData>>{}.obs;
  var selectedDayAttendance = Rx<AttendanceData?>(null);
  var loading = false.obs;

  @override
  void onInit() {
    super.onInit();
    selectedDay.value = DateTime.now();

    // Wait for HomeController to be ready
    Future.delayed(const Duration(milliseconds: 500), () {
      _initializeWithRealData();
    });
  }

  @override
  void onReady() {
    super.onReady();

    // Listen to HomeController changes
    try {
      final homeCtrl = Get.find<HomeController>();

      // Listen for attendance data changes
      ever(homeCtrl.attendanceData, (_) {
        print('🔄 Attendance data changed, refreshing...');
        Future.delayed(const Duration(milliseconds: 100), () {
          _initializeWithRealData();
        });
      });

      // Listen for holidays changes
      ever(homeCtrl.holidays, (_) {
        print('🔄 Holidays data changed, refreshing...');
        Future.delayed(const Duration(milliseconds: 100), () {
          _initializeWithRealData();
        });
      });

    } catch (e) {
      print('❌ Error setting up listeners: $e');
    }
  }

  void _initializeWithRealData() {
    print('🚀 Initializing attendance data...');

    try {
      final homeCtrl = Get.find<HomeController>();

      print('📊 HomeController found');
      print('📊 Dashboard data available: ${homeCtrl.dashboardData.value != null}');
      print('📊 Attendance data available: ${homeCtrl.attendanceData.value != null}');
      print('📊 Holidays count: ${homeCtrl.holidays.length}');

      attendanceHistory.clear();

      // Add current attendance data if available
      if (homeCtrl.attendanceData.value != null) {
        final currentAttendance = homeCtrl.attendanceData.value!;

        print('✅ Processing attendance:');
        print('   Date: ${currentAttendance.date}');
        print('   Status: ${currentAttendance.status}');
        print('   Clock In: ${currentAttendance.clockIn}');
        print('   Late: ${currentAttendance.late}');

        final attendanceDate = DateTime.parse(currentAttendance.date);
        final key = DateTime(attendanceDate.year, attendanceDate.month, attendanceDate.day);

        attendanceHistory[key] = [currentAttendance];

        print('✅ Added attendance for: ${key.toIso8601String().split('T')[0]}');

        // Set as selected if it's today
        final today = DateTime.now();
        if (isSameDay(key, today)) {
          selectedDayAttendance.value = currentAttendance;
          print('✅ Set as selected (today)');
        }
      } else {
        print('❌ No attendance data available');
      }

      // Add holidays
      if (homeCtrl.holidays.isNotEmpty) {
        print('✅ Processing ${homeCtrl.holidays.length} holidays');

        for (var holiday in homeCtrl.holidays) {
          final holidayDate = DateTime.parse(holiday.startDate);
          final key = DateTime(holidayDate.year, holidayDate.month, holidayDate.day);

          final holidayAttendance = AttendanceData(
            id: holiday.id,
            employeeId: 6,
            date: holiday.startDate,
            status: 'Holiday',
            clockIn: '00:00:00',
            clockOut: '00:00:00',
            late: '00:00:00',
            earlyLeaving: '00:00:00',
            overtime: '00:00:00',
            totalRest: '00:00:00',
            createdBy: holiday.createdBy,
            createdAt: holiday.createdAt,
            updatedAt: holiday.updatedAt,
          );

          attendanceHistory[key] = [holidayAttendance];
          print('✅ Added holiday: ${holiday.occasion} on ${key.toIso8601String().split('T')[0]}');
        }
      }

      print('📊 Total records: ${attendanceHistory.length}');

      // Force UI update
      attendanceHistory.refresh();

    } catch (e) {
      print('❌ Error initializing data: $e');
    }
  }

  // Get attendance events for a specific day
  List<AttendanceData> getEventsForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return attendanceHistory[key] ?? [];
  }

  // Get status color based on attendance
  Color getStatusColor(AttendanceData attendance) {
    switch (attendance.status.toLowerCase()) {
      case 'present':
        if (attendance.late != "00:00:00" && attendance.late.isNotEmpty) {
          return Colors.orange; // Late but present
        }
        return Colors.green; // On time
      case 'absent':
        return Colors.red;
      case 'holiday':
        return Colors.blue;
      case 'leave':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  // Handle day selection
  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    print('📅 Day selected: ${selectedDay.toIso8601String().split('T')[0]}');

    this.selectedDay.value = selectedDay;
    this.focusedDay.value = focusedDay;

    final events = getEventsForDay(selectedDay);
    selectedDayAttendance.value = events.isNotEmpty ? events.first : null;

    print('📊 Attendance found: ${selectedDayAttendance.value?.status ?? 'None'}');
  }

  // Format time for display
  String formatTime(String time) {
    if (time == "00:00:00" || time.isEmpty) return "Not recorded";

    try {
      final parts = time.split(':');
      if (parts.length >= 2) {
        return "${parts[0]}:${parts[1]}";
      }
    } catch (e) {
      print('❌ Error formatting time: $e');
    }

    return time;
  }

  // Calculate working hours
  String calculateWorkingHours(AttendanceData attendance) {
    if (attendance.clockIn == "00:00:00" || attendance.clockOut == "00:00:00") {
      if (attendance.clockIn != "00:00:00" && attendance.clockOut == "00:00:00") {
        return "Still working...";
      }
      return "Incomplete";
    }

    try {
      final clockInParts = attendance.clockIn.split(':');
      final clockOutParts = attendance.clockOut.split(':');

      final clockInHour = int.parse(clockInParts[0]);
      final clockInMinute = int.parse(clockInParts[1]);
      final clockOutHour = int.parse(clockOutParts[0]);
      final clockOutMinute = int.parse(clockOutParts[1]);

      final clockInTime = DateTime(2024, 1, 1, clockInHour, clockInMinute);
      final clockOutTime = DateTime(2024, 1, 1, clockOutHour, clockOutMinute);

      final duration = clockOutTime.difference(clockInTime);
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;

      return "${hours}h ${minutes}m";
    } catch (e) {
      return "Error calculating";
    }
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> refreshAttendance() async {
    loading.value = true;

    try {
      final homeCtrl = Get.find<HomeController>();
      await homeCtrl.fetchDashboardData();

      await Future.delayed(const Duration(milliseconds: 500));
      _initializeWithRealData();
    } catch (e) {
      print('❌ Error refreshing: $e');
    } finally {
      loading.value = false;
    }
  }

  void forceRefresh() {
    print('🔄 Force refreshing...');
    _initializeWithRealData();
  }

  // Get current attendance status for today
  String get todayStatus {
    final today = DateTime.now();
    final key = DateTime(today.year, today.month, today.day);
    final todayAttendance = attendanceHistory[key];

    if (todayAttendance?.isNotEmpty == true) {
      return todayAttendance!.first.status;
    }

    return 'No data';
  }
}
