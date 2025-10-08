class ApiConstants {
  static String get baseurl => 'https://starcapitalventures.co.in';
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
