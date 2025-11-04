// lib/Screens/home_screen/model/dashboard_model.dart
// lib/Screens/home_screen/model/dashboard_model.dart

class DashboardResponse {
  final bool status;
  final DashboardData? data;

  DashboardResponse({
    required this.status,
    this.data,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      status: json['status'] ?? false,
      data: json['data'] != null ? DashboardData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data?.toJson(),
    };
  }
}

class DashboardData {
  final List<dynamic> announcements;
  final List<dynamic> meetings;
  final List<dynamic> events;
  final AttendanceData? attendance;
  final OfficeTime officeTime;
  final int assignedLeads;
  final int assignedApplications;
  final int in_progress_applications;
  final int sanctioned_applications;
  final int total_applications;
  final int convertedLeads;
  final List<Holiday> holidays;
  final GeosentryData? geosentryData; // Added geosentry data

  DashboardData({
    required this.announcements,
    required this.meetings,
    required this.events,
    this.attendance,
    required this.officeTime,
    required this.assignedLeads,
    required this.assignedApplications,
    required this.in_progress_applications,
    required this.total_applications,
    required this.sanctioned_applications,
    required this.convertedLeads,
    required this.holidays,
    this.geosentryData, // Added geosentry data
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      announcements: json['announcements'] ?? [],
      meetings: json['meetings'] ?? [],
      events: json['events'] ?? [],
      attendance: json['attendance'] != null
          ? AttendanceData.fromJson(json['attendance'])
          : null,
      officeTime: OfficeTime.fromJson(json['office_time'] ?? {}),
      assignedLeads: json['assigned_leads'] ?? 0,
      assignedApplications: json['assigned_applications'] ?? 0,
      in_progress_applications: json['in_progress_applications'] ?? 0,
      sanctioned_applications: json['sanctioned_applications'] ?? 0,
      total_applications: json['total_applications'] ?? 0,
      convertedLeads: json['converted_leads'] ?? 0,
      holidays: (json['holidays'] as List?)
          ?.map((x) => Holiday.fromJson(x))
          .toList() ?? [],
      geosentryData: json['geosentry_data'] != null
          ? GeosentryData.fromJson(json['geosentry_data'])
          : null, // Added geosentry data parsing
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'announcements': announcements,
      'meetings': meetings,
      'events': events,
      'attendance': attendance?.toJson(),
      'office_time': officeTime.toJson(),
      'assigned_leads': assignedLeads,
      'assigned_applications': assignedApplications,
      'in_progress_applications': in_progress_applications, // Added this line'
      'sanctioned_applications': sanctioned_applications, // Added this line'
      'total_applications': total_applications, // Added this line'
      'converted_leads': convertedLeads,
      'holidays': holidays.map((x) => x.toJson()).toList(),
      'geosentry_data': geosentryData?.toJson(), // Added geosentry data serialization
    };
  }
}

// New GeosentryData class
class GeosentryData {
  final String? id;
  final int status;

  GeosentryData({
    this.id,
    required this.status,
  });

  factory GeosentryData.fromJson(Map<String, dynamic> json) {
    return GeosentryData(
      id: json['id'], // Can be null
      status: json['status'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
    };
  }

  // Helper methods for UI logic
  bool get isGeosentryActive => status == 1;
  bool get hasGeosentryId => id != null && id!.isNotEmpty;
  bool get isGeosentryEnabled => isGeosentryActive && hasGeosentryId;
}

// Existing AttendanceData class remains the same
class AttendanceData {
  final int id;
  final int employeeId;
  final String date;
  final String status;
  final String clockIn;
  final String clockOut;
  final String late;
  final String earlyLeaving;
  final String overtime;
  final String totalRest;
  final int createdBy;
  final String createdAt;
  final String updatedAt;

  AttendanceData({
    required this.id,
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
    required this.createdAt,
    required this.updatedAt,
  });

  factory AttendanceData.fromJson(Map<String, dynamic> json) {
    return AttendanceData(
      id: json['id'] ?? 0,
      employeeId: json['employee_id'] ?? 0,
      date: json['date'] ?? '',
      status: json['status'] ?? '',
      clockIn: json['clock_in'] ?? '',
      clockOut: json['clock_out'] ?? '',
      late: json['late'] ?? '',
      earlyLeaving: json['early_leaving'] ?? '',
      overtime: json['overtime'] ?? '',
      totalRest: json['total_rest'] ?? '',
      createdBy: json['created_by'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'date': date,
      'status': status,
      'clock_in': clockIn,
      'clock_out': clockOut,
      'late': late,
      'early_leaving': earlyLeaving,
      'overtime': overtime,
      'total_rest': totalRest,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Helper methods for UI logic
  bool get isClockedIn => clockIn != "00:00:00" && clockIn.isNotEmpty;
  bool get isClockedOut => clockOut != "00:00:00" && clockOut.isNotEmpty;
  bool get isReadyToClockIn => !isClockedIn;
  bool get isReadyToClockOut => isClockedIn && !isClockedOut;
}

// Existing OfficeTime class remains the same
class OfficeTime {
  final String startTime;
  final String endTime;

  OfficeTime({
    required this.startTime,
    required this.endTime,
  });

  factory OfficeTime.fromJson(Map<String, dynamic> json) {
    return OfficeTime(
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime,
      'endTime': endTime,
    };
  }
}

// Existing Holiday class remains the same
class Holiday {
  final int id;
  final String startDate;
  final String endDate;
  final String occasion;
  final int createdBy;
  final String createdAt;
  final String updatedAt;

  Holiday({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.occasion,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Holiday.fromJson(Map<String, dynamic> json) {
    return Holiday(
      id: json['id'] ?? 0,
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      occasion: json['occasion'] ?? '',
      createdBy: json['created_by'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start_date': startDate,
      'end_date': endDate,
      'occasion': occasion,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Helper method to format date for display
  String get formattedDate {
    try {
      final date = DateTime.parse(startDate);
      return "${_getMonthName(date.month)} ${date.day}, ${date.year}";
    } catch (e) {
      return startDate;
    }
  }

  String _getMonthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }
}

/*
class DashboardResponse {
  final bool status;
  final DashboardData? data;

  DashboardResponse({
    required this.status,
    this.data,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      status: json['status'] ?? false,
      data: json['data'] != null ? DashboardData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'data': data?.toJson(),
    };
  }
}

class DashboardData {
  final List<dynamic> announcements;
  final List<dynamic> meetings;
  final List<dynamic> events;
  final AttendanceData? attendance;
  final OfficeTime officeTime;
  final int assignedLeads;
  final int assignedApplications;
  final int convertedLeads;
  final List<Holiday> holidays;

  DashboardData({
    required this.announcements,
    required this.meetings,
    required this.events,
    this.attendance,
    required this.officeTime,
    required this.assignedLeads,
    required this.assignedApplications,
    required this.convertedLeads,
    required this.holidays,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      announcements: json['announcements'] ?? [],
      meetings: json['meetings'] ?? [],
      events: json['events'] ?? [],
      attendance: json['attendance'] != null
          ? AttendanceData.fromJson(json['attendance'])
          : null,
      officeTime: OfficeTime.fromJson(json['office_time'] ?? {}),
      assignedLeads: json['assigned_leads'] ?? 0,
      assignedApplications: json['assigned_applications'] ?? 0,
      convertedLeads: json['converted_leads'] ?? 0,
      holidays: (json['holidays'] as List?)
          ?.map((x) => Holiday.fromJson(x))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'announcements': announcements,
      'meetings': meetings,
      'events': events,
      'attendance': attendance?.toJson(),
      'office_time': officeTime.toJson(),
      'assigned_leads': assignedLeads,
      'assigned_applications': assignedApplications,
      'converted_leads': convertedLeads,
      'holidays': holidays.map((x) => x.toJson()).toList(),
    };
  }
}

class AttendanceData {
  final int id;
  final int employeeId;
  final String date;
  final String status;
  final String clockIn;
  final String clockOut;
  final String late;
  final String earlyLeaving;
  final String overtime;
  final String totalRest;
  final int createdBy;
  final String createdAt;
  final String updatedAt;

  AttendanceData({
    required this.id,
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
    required this.createdAt,
    required this.updatedAt,
  });

  factory AttendanceData.fromJson(Map<String, dynamic> json) {
    return AttendanceData(
      id: json['id'] ?? 0,
      employeeId: json['employee_id'] ?? 0,
      date: json['date'] ?? '',
      status: json['status'] ?? '',
      clockIn: json['clock_in'] ?? '',
      clockOut: json['clock_out'] ?? '',
      late: json['late'] ?? '',
      earlyLeaving: json['early_leaving'] ?? '',
      overtime: json['overtime'] ?? '',
      totalRest: json['total_rest'] ?? '',
      createdBy: json['created_by'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'date': date,
      'status': status,
      'clock_in': clockIn,
      'clock_out': clockOut,
      'late': late,
      'early_leaving': earlyLeaving,
      'overtime': overtime,
      'total_rest': totalRest,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Helper methods for UI logic
  bool get isClockedIn => clockIn != "00:00:00" && clockIn.isNotEmpty;
  bool get isClockedOut => clockOut != "00:00:00" && clockOut.isNotEmpty;
  bool get isReadyToClockIn => !isClockedIn;
  bool get isReadyToClockOut => isClockedIn && !isClockedOut;
}

class OfficeTime {
  final String startTime;
  final String endTime;

  OfficeTime({
    required this.startTime,
    required this.endTime,
  });

  factory OfficeTime.fromJson(Map<String, dynamic> json) {
    return OfficeTime(
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime,
      'endTime': endTime,
    };
  }
}

class Holiday {
  final int id;
  final String startDate;
  final String endDate;
  final String occasion;
  final int createdBy;
  final String createdAt;
  final String updatedAt;

  Holiday({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.occasion,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Holiday.fromJson(Map<String, dynamic> json) {
    return Holiday(
      id: json['id'] ?? 0,
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      occasion: json['occasion'] ?? '',
      createdBy: json['created_by'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start_date': startDate,
      'end_date': endDate,
      'occasion': occasion,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Helper method to format date for display
  String get formattedDate {
    try {
      final date = DateTime.parse(startDate);
      return "${_getMonthName(date.month)} ${date.day}, ${date.year}";
    } catch (e) {
      return startDate;
    }
  }

  String _getMonthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }
}
*/