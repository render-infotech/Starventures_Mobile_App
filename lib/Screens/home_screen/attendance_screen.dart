// lib/Screens/attendance/attendance_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:starcapitalventures/app_export/app_export.dart';
import '../home_screen/model/dashboard_model.dart';
import 'controller/AttendanceController.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final AttendanceController _controller = Get.put(AttendanceController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forceRefresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.whiteA700,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A2B1A),
        title: const Text(
          'Attendance',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => _controller.refreshAttendance(),
          ),
        ],
      ),
      body: Obx(() {
        if (_controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Calendar Section
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TableCalendar<AttendanceData>(
                  firstDay: DateTime.utc(2024, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _controller.focusedDay.value,
                  calendarFormat: _controller.calendarFormat.value,

                  // Events
                  eventLoader: _controller.getEventsForDay,

                  // Styling
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    weekendTextStyle: TextStyle(color: Colors.red.shade700),
                    holidayTextStyle: TextStyle(color: Colors.blue.shade700),

                    // Today styling
                    todayDecoration: BoxDecoration(
                      color: const Color(0xFF4A2B1A),
                      shape: BoxShape.circle,
                    ),

                    // Selected day styling
                    selectedDecoration: BoxDecoration(
                      color: Colors.orange.shade600,
                      shape: BoxShape.circle,
                    ),

                    // Marker styling
                    markerDecoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),

                  // Header styling
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: true,
                    titleCentered: true,
                    formatButtonShowsNext: false,
                    formatButtonDecoration: BoxDecoration(
                      color: Color(0xFF4A2B1A),
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    ),
                    formatButtonTextStyle: TextStyle(color: Colors.white),
                  ),

                  // Day selection
                  selectedDayPredicate: (day) {
                    return isSameDay(_controller.selectedDay.value, day);
                  },

                  onDaySelected: _controller.onDaySelected,

                  onFormatChanged: (format) {
                    _controller.calendarFormat.value = format;
                  },

                  onPageChanged: (focusedDay) {
                    _controller.focusedDay.value = focusedDay;
                  },

                  // Custom builders
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, day, events) {
                      if (events.isNotEmpty) {
                        final attendance = events.first;
                        return Positioned(
                          right: 1,
                          bottom: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              color: _controller.getStatusColor(attendance),
                              shape: BoxShape.circle,
                            ),
                            width: 16.0,
                            height: 16.0,
                            child: Center(
                              child: Icon(
                                _getStatusIcon(attendance.status),
                                color: Colors.white,
                                size: 10.0,
                              ),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),

              // Legend
              _buildLegend(),

              const SizedBox(height: 16),

              // Selected Day Details - Use Container instead of Expanded
              Container(
                height: 300, // Fixed height instead of Expanded
                child: _buildAttendanceDetails(),
              ),

              // Add some bottom padding
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildLegend() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildLegendItem(Colors.green, "Present"),
          _buildLegendItem(Colors.orange, "Late"),
          _buildLegendItem(Colors.red, "Absent"),
          _buildLegendItem(Colors.blue, "Holiday"),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildAttendanceDetails() {
    return Obx(() {
      final selectedDate = _controller.selectedDay.value;
      final attendance = _controller.selectedDayAttendance.value;

      if (selectedDate == null) {
        return const Center(
          child: Text('Select a date to view attendance details'),
        );
      }

      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: attendance == null
            ? _buildNoAttendanceData(selectedDate)
            : _buildAttendanceCard(attendance),
      );
    });
  }

  // Rest of your methods remain the same...
  Widget _buildNoAttendanceData(DateTime date) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.calendar_today_outlined,
          size: 48,
          color: Colors.grey.shade400,
        ),
        const SizedBox(height: 16),
        Text(
          'No attendance data',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'for ${_formatSelectedDate(date)}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceCard(AttendanceData attendance) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with status
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatSelectedDate(_controller.selectedDay.value!),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _controller.getStatusColor(attendance).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _controller.getStatusColor(attendance),
                  width: 1,
                ),
              ),
              child: Text(
                attendance.status,
                style: TextStyle(
                  color: _controller.getStatusColor(attendance),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Time details
        _buildTimeRow("Clock In", _controller.formatTime(attendance.clockIn)),
        _buildTimeRow("Clock Out", _controller.formatTime(attendance.clockOut)),
        _buildTimeRow("Working Hours", _controller.calculateWorkingHours(attendance)),

        if (attendance.late != "00:00:00")
          _buildTimeRow("Late By", _controller.formatTime(attendance.late), isWarning: true),

        if (attendance.overtime != "00:00:00")
          _buildTimeRow("Overtime", _controller.formatTime(attendance.overtime), isPositive: true),
      ],
    );
  }

  Widget _buildTimeRow(String label, String value, {bool isWarning = false, bool isPositive = false}) {
    Color valueColor = Colors.black87;
    if (isWarning) valueColor = Colors.orange.shade700;
    if (isPositive) valueColor = Colors.green.shade700;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return Icons.check;
      case 'absent':
        return Icons.close;
      case 'late':
        return Icons.access_time;
      case 'holiday':
        return Icons.celebration;
      default:
        return Icons.help;
    }
  }

  String _formatSelectedDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return "${date.day} ${months[date.month - 1]}, ${date.year}";
  }
}
