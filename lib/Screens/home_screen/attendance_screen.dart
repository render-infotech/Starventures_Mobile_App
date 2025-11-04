// lib/Screens/attendance/attendance_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:starcapitalventures/Screens/home_screen/controller/AttendanceController.dart';
import 'package:starcapitalventures/app_routes.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:starcapitalventures/app_export/app_export.dart';

import '../../widgets/custom_app_bar.dart';
import 'model/attendance_model.dart';

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
      appBar: CustomAppBar(
        useGreeting: false,
        pageTitle: 'Attendance',
        showBack: true,
        onBack: () => Get.back(),
        backgroundColor: appTheme.theme,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: appTheme.whiteA700),
            onPressed: () => _controller.refreshAttendance(),
          ),
        ],
      ),      body: Obx(() {
        if (_controller.loading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: appTheme.theme,
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Calendar Section
              Container(
                margin: EdgeInsets.all(getSize(16)),
                decoration: BoxDecoration(
                  color: appTheme.whiteA700,
                  borderRadius: BorderRadius.circular(getSize(16)),
                  boxShadow: [
                    BoxShadow(
                      color: appTheme.shadowColor,
                      blurRadius: getSize(10),
                      offset: Offset(0, getVerticalSize(4)),
                    ),
                  ],
                ),
                child: TableCalendar<AttendanceData>(
                  firstDay: DateTime.utc(2024, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _controller.focusedDay.value,
                  calendarFormat: _controller.calendarFormat.value,

                  // Events for markers
                  eventLoader: _controller.getEventsForDay,

                  // Styling
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    weekendTextStyle: AppTextStyles.medium.copyWith(
                      color: appTheme.red500,
                      fontSize: getFontSize(14),
                    ),
                    holidayTextStyle: AppTextStyles.medium.copyWith(
                      color: appTheme.blue900,
                      fontSize: getFontSize(14),
                    ),
                    todayDecoration: BoxDecoration(
                      color: appTheme.theme,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: appTheme.orange600,
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: BoxDecoration(
                      color: appTheme.green400,
                      shape: BoxShape.circle,
                    ),
                  ),

                  headerStyle: HeaderStyle(
                    formatButtonVisible: true,
                    titleCentered: true,
                    formatButtonShowsNext: false,
                    formatButtonDecoration: BoxDecoration(
                      color: appTheme.theme,
                      borderRadius: BorderRadius.all(
                        Radius.circular(getSize(12)),
                      ),
                    ),
                    formatButtonTextStyle: AppTextStyles.medium.copyWith(
                      color: appTheme.whiteA700,
                      fontSize: getFontSize(14),
                    ),
                    titleTextStyle: AppTextStyles.semiBold.copyWith(
                      fontSize: getFontSize(16),
                    ),
                  ),

                  // Selection + navigation
                  selectedDayPredicate: (day) =>
                      isSameDay(_controller.selectedDay.value, day),

                  onDaySelected: _controller.onDaySelected,

                  onFormatChanged: (format) {
                    _controller.calendarFormat.value = format;
                  },

                  onPageChanged: (focusedDay) {
                    _controller.focusedDay.value = focusedDay;
                    _controller.fetchMonth(focusedDay.year, focusedDay.month);
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
                            width: getSize(16),
                            height: getSize(16),
                            child: Center(
                              child: Icon(
                                _getStatusIcon(attendance.status),
                                color: appTheme.whiteA700,
                                size: getSize(10),
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

              SizedBox(height: getVerticalSize(16)),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: getHorizontalSize(16)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CustomElevatedButton(
                      text: 'Request Leave',
                      height: getVerticalSize(44),
                      width: getHorizontalSize(140),
                      buttonStyle: ElevatedButton.styleFrom(
                        minimumSize: Size(getHorizontalSize(140), getVerticalSize(44)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(getSize(12)),
                        ),
                        backgroundColor: appTheme.theme,
                        foregroundColor: appTheme.whiteA700,
                      ),
                      buttonTextStyle: AppTextStyles.semiBold.copyWith(
                        color: appTheme.whiteA700,
                        fontSize: getFontSize(16),
                      ),
                      onPressed: () => Get.toNamed(AppRoutes.leaverequestScreen),
                    ),
                    const Spacer(),
                    CustomElevatedButton(
                      text: 'View Leaves',
                      height: getVerticalSize(44),
                      width: getHorizontalSize(140),
                      buttonStyle: ElevatedButton.styleFrom(
                        minimumSize: Size(getHorizontalSize(140), getVerticalSize(44)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(getSize(12)),
                        ),
                        backgroundColor: appTheme.whiteA700,
                        foregroundColor: appTheme.theme,
                        side: BorderSide(color: appTheme.theme, width: 1),
                      ),
                      buttonTextStyle: AppTextStyles.semiBold.copyWith(
                        color: appTheme.theme,
                        fontSize: getFontSize(16),
                      ),
                      onPressed: () => Get.toNamed(AppRoutes.viewLeaves),
                    ),
                  ],
                ),
              ),

              // Selected Day Details
              SizedBox(
                height: getVerticalSize(300),
                child: _buildAttendanceDetails(),
              ),

              SizedBox(height: getVerticalSize(20)),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildLegend() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: getHorizontalSize(16)),
      padding: EdgeInsets.all(getSize(16)),
      decoration: BoxDecoration(
        color: appTheme.gray100,
        borderRadius: BorderRadius.circular(getSize(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildLegendItem(appTheme.green400, "Present"),
          _buildLegendItem(appTheme.orange600, "Late"),
          _buildLegendItem(appTheme.red500, "Absent"),
          _buildLegendItem(appTheme.blue900, "Holiday"),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: getSize(12),
          height: getSize(12),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: getHorizontalSize(4)),
        Text(
          label,
          style: AppTextStyles.medium.copyWith(
            fontSize: getFontSize(12),
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceDetails() {
    return Obx(() {
      final selectedDate = _controller.selectedDay.value;
      final attendance = _controller.selectedDayAttendance.value;

      if (selectedDate == null) {
        return Center(
          child: Text(
            'Select a date to view attendance details',
            style: AppTextStyles.regular.copyWith(
              fontSize: getFontSize(14),
              color: appTheme.gray700,
            ),
          ),
        );
      }

      return Container(
        margin: EdgeInsets.all(getSize(16)),
        padding: EdgeInsets.all(getSize(20)),
        decoration: BoxDecoration(
          color: appTheme.whiteA700,
          borderRadius: BorderRadius.circular(getSize(16)),
          boxShadow: [
            BoxShadow(
              color: appTheme.shadowColor,
              blurRadius: getSize(10),
              offset: Offset(0, getVerticalSize(4)),
            ),
          ],
        ),
        child: attendance == null
            ? _buildNoAttendanceData(selectedDate)
            : _buildAttendanceCard(attendance),
      );
    });
  }

  Widget _buildNoAttendanceData(DateTime date) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.calendar_today_outlined,
          size: getSize(48),
          color: appTheme.blueGray400,
        ),
        SizedBox(height: getVerticalSize(16)),
        Text(
          'No attendance data',
          style: AppTextStyles.semiBold.copyWith(
            fontSize: getFontSize(16),
            color: appTheme.gray700,
          ),
        ),
        SizedBox(height: getVerticalSize(8)),
        Text(
          'for ${_formatSelectedDate(date)}',
          style: AppTextStyles.regular.copyWith(
            fontSize: getFontSize(14),
            color: appTheme.gray500,
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
              style: AppTextStyles.semiBold.copyWith(
                fontSize: getFontSize(18),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: getHorizontalSize(12),
                vertical: getVerticalSize(6),
              ),
              decoration: BoxDecoration(
                color: _controller.getStatusColor(attendance).withOpacity(0.1),
                borderRadius: BorderRadius.circular(getSize(20)),
                border: Border.all(
                  color: _controller.getStatusColor(attendance),
                  width: 1,
                ),
              ),
              child: Text(
                attendance.status,
                style: AppTextStyles.semiBold.copyWith(
                  color: _controller.getStatusColor(attendance),
                  fontSize: getFontSize(12),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: getVerticalSize(20)),

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

  Widget _buildTimeRow(String label, String value,
      {bool isWarning = false, bool isPositive = false}) {
    Color valueColor = appTheme.black900;
    if (isWarning) valueColor = appTheme.orange600;
    if (isPositive) valueColor = appTheme.green400;

    return Padding(
      padding: EdgeInsets.only(bottom: getVerticalSize(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.medium.copyWith(
              fontSize: getFontSize(14),
              color: appTheme.gray700,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.semiBold.copyWith(
              fontSize: getFontSize(14),
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
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return "${date.day} ${months[date.month - 1]}, ${date.year}";
  }
}
