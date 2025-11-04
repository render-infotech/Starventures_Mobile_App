class ApiConstants {
  static String get baseurl => 'https://starcapitalventures.co.in';
  // In api_constant.dart - Add this line
  static String getLeadDetails(String leadId) => '$baseurl/api/v1/leads/$leadId';
  // Customer registration endpoint
  static String get registerCustomer => '$baseurl/api/v1/customer/send-otp';  // Relationship Manager endpoint
  static String get relationshipManager => '$baseurl/api/v1/relationship-manager';
  static String updateLead(String leadId) {
    return '$baseurl/api/v1/leads/$leadId';
  }
  // OTP endpoints
  static String get sendOtp => '$baseurl/api/v1/send-otp';
  static String get resendOtp => '$baseurl/api/v1/customer/resend-otp';
  static String get verifyOtp => '$baseurl/api/v1/verify-otp';
  static String get banks => '$baseurl/api/v1/application-banks'; //
  static String get employeesByBranch => '$baseurl/api/v1/employees/branch';
  static String get leads => '$baseurl/api/v1/leads';
  // lib/core/data/api_constant/api_constant.dart
  static String deleteApplication(String applicationId) =>
      '$baseurl/api/v1/applications/$applicationId';
  static String get customerFeedback => '$baseurl/api/v1/customer-feedback';
  // Replace the placeholder with actual endpoint pattern
  static String payslip(String employeeId, String yearMonth) =>
      '$baseurl/api/v1/payslip/html/$employeeId-$yearMonth';
  static String get joiningLetter=>'$baseurl/api/v1/employee/joining-letter';
  static String get noc=>'$baseurl/api/v1/employee/noc';
  static String get postDocuments =>'$baseurl/api/v1/employee/documents';
  static String get getDocuments =>'$baseurl/api/v1/employee/documents';
  static String get getotherDocuments =>'$baseurl/api/v1/applications/{{application_id}}/documents';
  static String get postotherDocuments =>'$baseurl/api/v1/applications/{{application_id}}/documents';
  static String get deleteotherDocuments =>'$baseurl/api/v1/documents/{{document_id}}';
  static String get attendanceDetails => '$baseurl/api/v1/attendance/details'; // ?date=YYYY-MM-DD
  static String get attendanceMonthly => '$baseurl/api/v1/attendance/monthly'; // ?month=MM&year=YYYY
  static String get attendanceLeaveRequest => '$baseurl/api/v1/attendance/leave-request';
  static String get attendanceLeaveTypes => '$baseurl/api/v1/attendance/leave-types'; // GET [web:1]
  static String get attendanceMonthlyLeaves => '$baseurl/api/v1/attendance/monthly-leaves'; // ?month=MM&year=YYYY [memory:1]
// Add this line to ApiConstants class
  static String get updatePassword => '$baseurl/api/v1/profile/password';
// Delete lead endpoint
  static String deleteLead(String leadId) => '$baseurl/api/v1/leads/$leadId';

  static String get getAgents =>'$baseurl/api/v1/agents/branch';
  // Get application history
  static String getApplicationHistory(String applicationId) =>
      '$baseurl/api/v1/applications/$applicationId/histories';  // Add this method to get dynamic URL with application ID
  static String postApplicationHistory(String applicationId) =>
      '$baseurl/api/v1/applications/$applicationId/histories';  static String get getDashboard => '$baseurl/api/v1/dashboard';
  static String get getApplciations => '$baseurl/api/v1/applications';
  static String getApplicationDetails(String id) => '$baseurl/api/v1/applications/$id';
  static String editApplication(String id) => '$baseurl/api/v1/applications/$id';

  static String get login => '$baseurl/api/v1/login';
  static String get logout => '$baseurl/api/v1/logout';
  static String get profile => '$baseurl/api/v1/profile';
  static String get profileUpdate => '$baseurl/api/v1/profile';
  static String get createApplciations => '$baseurl/api/v1/applications';
  static String get applicationType => '$baseurl/api/v1/application-types';
  static String get applicationStatus => '$baseurl/api/v1/application-statuses';

  static String get clockIn => '$baseurl/api/v1/attendance/clockin';
  static String get clockout => '$baseurl/api/v1/attendance/clockout';
}
