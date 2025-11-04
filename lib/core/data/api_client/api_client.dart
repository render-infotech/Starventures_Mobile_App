// lib/core/network/api_client.dart

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as path;
import '../../../Screens/Leads/lead_model.dart';
import '../../../Screens/Leads/model/delete_lead_model.dart' show DeleteLeadResponse;
import '../../../Screens/application_detail/model/action_history_model.dart';
import '../../../Screens/application_detail/model/application_history_model.dart';
import '../../../Screens/application_detail/model/other_document_model.dart';
import '../../../Screens/documents/models/document_model.dart';
import '../../../Screens/edit_application/model/edit_application_model.dart';
import '../../../Screens/forgot_password_screen/update_password_model.dart';
import '../../../Screens/home_screen/model/dashboard_model.dart';
import '../../../Screens/lead_detail/lead_detail_model.dart';
import '../../../Screens/new_application/model/agents_model.dart';
import '../../../Screens/new_application/model/application_status_model.dart';
import '../../../Screens/new_application/model/application_type_model.dart';
import '../../../Screens/new_application/model/bank_model.dart';
import '../../../Screens/new_application/model/create_application_model.dart';
import '../../../Screens/new_application/model/employee_model.dart';
import '../../../Screens/sign_in_screen/login_model/login_responce_model.dart';
import '../../../app_export/app_export.dart';
import '../../../core/data/api_constant/api_constant.dart';

import 'dart:io';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:get/get.dart'; // ✅ Add this import
import 'package:flutter_image_compress/flutter_image_compress.dart'; // ✅ Add this import
import 'package:path/path.dart' as path; // ✅ Add this import

import '../../../Screens/sign_in_screen/login_model/login_responce_model.dart';
import '../api_constant/api_constant.dart';
import '../../services/session_service.dart';

// ✅ Add all your other necessary imports for models
// (Make sure to import all the response/request models you're using)

class ApiClient {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  Future<String?> getAuthToken() async {
    return await secureStorage.read(key: 'auth_token');
  }

  Future<bool> hasValidToken() async {
    try {
      final token = await getAuthToken();
      return token != null && token.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> clearToken() async {
    await secureStorage.delete(key: 'auth_token');
  }

  /// ✅ Check for token expiration and handle globally
  /// ✅ Check for token expiration and handle globally
  void _checkTokenExpiration(int statusCode, dynamic responseBody) {
    if (Get.isRegistered<SessionService>()) {
      final sessionService = Get.find<SessionService>();
      if (sessionService.isTokenExpired(statusCode, responseBody)) {
        print('🚫 Token expired detected in API response');
        print('Status: $statusCode, Body: $responseBody');
        sessionService.handleTokenExpiration();
      }
    }
  }

  Future<bool> logout() async {
    try {
      final token = await getAuthToken();
      if (token != null && token.isNotEmpty) {
        final response = await http.post(
          Uri.parse(ApiConstants.logout),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        // ✅ Check for token expiration
        _checkTokenExpiration(response.statusCode, response.body);

        await clearToken();
        return response.statusCode == 200 || response.statusCode == 201;
      } else {
        await clearToken();
        return true;
      }
    } catch (_) {
      await clearToken();
      return false;
    }
  }
  Future<Map<String, dynamic>> getAttendanceDetailsByDate(String yyyyMmDd) async {
    final token = await getAuthToken();
    final uri = Uri.parse('${ApiConstants.attendanceDetails}?date=$yyyyMmDd');
    final resp = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    _checkTokenExpiration(resp.statusCode, resp.body);

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return json.decode(resp.body) as Map<String, dynamic>;
    }
    throw Exception('Attendance fetch failed (${resp.statusCode})');
  }
  Future<List<Map<String, dynamic>>> getLeaveTypes() async {
    final token = await getAuthToken();
    final resp = await http.get(
      Uri.parse(ApiConstants.attendanceLeaveTypes),
      headers: {
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );
    _checkTokenExpiration(resp.statusCode, resp.body);
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final decoded = json.decode(resp.body) as Map<String, dynamic>;
      final List data = (decoded['data'] ?? []) as List;
      return data.cast<Map<String, dynamic>>();
    }
    throw Exception('Failed to load leave types (${resp.statusCode})');
  }
  // Fetch HTML content for payslip
  Future<String> fetchPayslipHtml(String employeeId, String yearMonth) async {
    final token = await getAuthToken();
    if (token == null || token.isEmpty) {
      throw Exception('No auth token found');
    }

    final url = '${ApiConstants.baseurl}/api/v1/payslip/html/$employeeId-$yearMonth';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'text/html',
        'Authorization': 'Bearer $token',
      },
    );

    _checkTokenExpiration(response.statusCode, response.body);

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to fetch payslip HTML: ${response.statusCode}');
    }
  }

// Fetch Joining Letter HTML
  Future<String> fetchJoiningLetterHtml() async {
    final token = await getAuthToken();
    if (token == null || token.isEmpty) {
      throw Exception('No auth token found');
    }

    final response = await http.get(
      Uri.parse(ApiConstants.joiningLetter),
      headers: {
        'Content-Type': 'text/html',
        'Authorization': 'Bearer $token',
      },
    );

    _checkTokenExpiration(response.statusCode, response.body);

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to fetch joining letter HTML: ${response.statusCode}');
    }
  }

// Fetch NOC HTML
  Future<String> fetchNocHtml() async {
    final token = await getAuthToken();
    if (token == null || token.isEmpty) {
      throw Exception('No auth token found');
    }

    final response = await http.get(
      Uri.parse(ApiConstants.noc),
      headers: {
        'Content-Type': 'text/html',
        'Authorization': 'Bearer $token',
      },
    );

    _checkTokenExpiration(response.statusCode, response.body);

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to fetch NOC HTML: ${response.statusCode}');
    }
  }

  Future<BankResponse> fetchBanks() async {
    try {
      final token = await getAuthToken();

      final response = await http.get(
        Uri.parse(ApiConstants.banks),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('🏦 Bank API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return BankResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to fetch banks. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in fetchBanks: $e');
      return BankResponse(
        success: false,
        message: 'Failed to fetch banks',
        data: [],
      );
    }
  }
  Future<bool> postLeaveRequest(Map<String, dynamic> payload) async {
    final token = await getAuthToken();
    final resp = await http.post(
      Uri.parse(ApiConstants.attendanceLeaveRequest),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );
    _checkTokenExpiration(resp.statusCode, resp.body);
    return resp.statusCode >= 200 && resp.statusCode < 300;
  }

  Future<Map<String, dynamic>> getAttendanceMonthly({required int month, required int year}) async {
    final token = await getAuthToken();
    final uri = Uri.parse('${ApiConstants.attendanceMonthly}?month=$month&year=$year');
    final resp = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    _checkTokenExpiration(resp.statusCode, resp.body);

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return json.decode(resp.body) as Map<String, dynamic>;
    }
    throw Exception('Monthly attendance fetch failed (${resp.statusCode})');
  }
  Future<List<Map<String, dynamic>>> getMonthlyLeaves({required int month, required int year}) async {
    final token = await getAuthToken();
    final uri = Uri.parse('${ApiConstants.attendanceMonthlyLeaves}?month=$month&year=$year');
    final resp = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );
    _checkTokenExpiration(resp.statusCode, resp.body);
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final decoded = json.decode(resp.body) as Map<String, dynamic>;
      final List data = (decoded['data'] ?? []) as List;
      return data.cast<Map<String, dynamic>>();
    }
    throw Exception('Failed to load monthly leaves (${resp.statusCode})');
  }
  Future<LoginResponse> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(ApiConstants.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    // ✅ Check for token expiration
    _checkTokenExpiration(response.statusCode, response.body);

    if (response.statusCode == 200) {
      return LoginResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to login. Server responded: ${response.statusCode}');
    }
  }
  Future<Map<String, dynamic>> clockIn({
    double? latitude,
    double? longitude,
    File? clockInImage,
  }) async {
    final token = await getAuthToken();

    // If no image, use JSON payload (original behavior)
    if (clockInImage == null) {
      Map<String, dynamic> payload = {
        'timestamp': DateTime.now().toIso8601String(),
      };

      if (latitude != null && longitude != null) {
        payload['latitude'] = latitude;
        payload['longitude'] = longitude;
        print('🌍 Clock in with location: Lat: $latitude, Lng: $longitude');
      } else {
        print('⚠️ Clock in without location coordinates');
      }

      final response = await http.post(
        Uri.parse(ApiConstants.clockIn),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      _checkTokenExpiration(response.statusCode, response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to clock in. Server responded: ${response.statusCode}');
      }
    }

    // If image provided, use multipart/form-data
    var request = http.MultipartRequest('POST', Uri.parse(ApiConstants.clockIn));

    // Add authorization header
    request.headers['Authorization'] = 'Bearer $token';

    // Add text fields to payload
    request.fields['timestamp'] = DateTime.now().toIso8601String();

    if (latitude != null && longitude != null) {
      request.fields['latitude'] = latitude.toString();
      request.fields['longitude'] = longitude.toString();
      print('🌍 Clock in with location: Lat: $latitude, Lng: $longitude');
    } else {
      print('⚠️ Clock in without location coordinates');
    }

    // Add image file to payload
    var multipartFile = await http.MultipartFile.fromPath(
      'clock_in_image',  // Field name expected by your backend
      clockInImage.path,
      filename: clockInImage.path.split('/').last,
    );
    request.files.add(multipartFile);

    print('📤 Sending clock in request with image');

    // Send the request
    var streamedResponse = await request.send();

    // Get response
    var response = await http.Response.fromStream(streamedResponse);

    _checkTokenExpiration(response.statusCode, response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to clock in. Server responded: ${response.statusCode}');
    }
  }

  /// Clock out with location tracking and selfie image
  Future<Map<String, dynamic>> clockOut({
    double? latitude,
    double? longitude,
    File? clockOutImage,
  }) async {
    final token = await getAuthToken();

    // If no image, use JSON payload (original behavior)
    if (clockOutImage == null) {
      Map<String, dynamic> payload = {
        'timestamp': DateTime.now().toIso8601String(),
      };

      if (latitude != null && longitude != null) {
        payload['latitude'] = latitude;
        payload['longitude'] = longitude;
        print('🗺️ Clock out with location: Lat: $latitude, Lng: $longitude');
      } else {
        print('⚠️ Clock out without location coordinates');
      }

      final response = await http.post(
        Uri.parse(ApiConstants.clockout),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      _checkTokenExpiration(response.statusCode, response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        print('✅ Clock Out Response: $responseData');
        return responseData;
      } else {
        throw Exception('Failed to clock out. Server responded: ${response.statusCode}');
      }
    }

    // If image provided, use multipart/form-data
    var request = http.MultipartRequest('POST', Uri.parse(ApiConstants.clockout));

    // Add authorization header
    request.headers['Authorization'] = 'Bearer $token';

    // Add text fields to payload
    request.fields['timestamp'] = DateTime.now().toIso8601String();

    if (latitude != null && longitude != null) {
      request.fields['latitude'] = latitude.toString();
      request.fields['longitude'] = longitude.toString();
      print('🗺️ Clock out with location: Lat: $latitude, Lng: $longitude');
    } else {
      print('⚠️ Clock out without location coordinates');
    }

    // Add image file to payload
    var multipartFile = await http.MultipartFile.fromPath(
      'clock_out_image',  // Field name expected by your backend
      clockOutImage.path,
      filename: clockOutImage.path.split('/').last,
    );
    request.files.add(multipartFile);

    print('📤 Sending clock out request with image');

    // Send the request
    var streamedResponse = await request.send();

    // Get response
    var response = await http.Response.fromStream(streamedResponse);

    _checkTokenExpiration(response.statusCode, response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      print('✅ Clock Out Response: $responseData');
      return responseData;
    } else {
      throw Exception('Failed to clock out. Server responded: ${response.statusCode}');
    }
  }

  /*
  Future<Map<String, dynamic>> clockIn({double? latitude, double? longitude}) async {
    final token = await getAuthToken();

    Map<String, dynamic> payload = {
      'timestamp': DateTime.now().toIso8601String(),
    };

    if (latitude != null && longitude != null) {
      payload['latitude'] = latitude;
      payload['longitude'] = longitude;
      print('🌍 Clock in with location: Lat: $latitude, Lng: $longitude');
    } else {
      print('⚠️ Clock in without location coordinates');
    }

    final response = await http.post(
      Uri.parse(ApiConstants.clockIn),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );

    // ✅ Check for token expiration
    _checkTokenExpiration(response.statusCode, response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to clock in. Server responded: ${response.statusCode}');
    }
  }

  /// Clock out with location tracking
  Future<Map<String, dynamic>> clockOut({
    double? latitude,
    double? longitude,
  }) async {
    final token = await getAuthToken();

    // Prepare the payload
    Map<String, dynamic> payload = {
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Add coordinates if provided
    if (latitude != null && longitude != null) {
      payload['latitude'] = latitude;
      payload['longitude'] = longitude;
      print('🗺️ Clock out with location: Lat: $latitude, Lng: $longitude');
    } else {
      print('⚠️ Clock out without location coordinates');
    }

    final response = await http.post(
      Uri.parse(ApiConstants.clockout),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );

    // Check for token expiration
    _checkTokenExpiration(response.statusCode, response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      print('✅ Clock Out Response: $responseData');
      return responseData;
    } else {
      throw Exception('Failed to clock out. Server responded: ${response.statusCode}');
    }
  }


 */
  Future<DashboardResponse> fetchDashboard() async {
    final token = await getAuthToken();
    if (token == null || token.isEmpty) {
      throw Exception('No auth token found');
    }

    final response = await http.get(
      Uri.parse(ApiConstants.getDashboard),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    // ✅ Check for token expiration
    _checkTokenExpiration(response.statusCode, response.body);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      return DashboardResponse.fromJson(jsonData);
    } else {
      throw Exception('Failed to fetch dashboard: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchProfile() async {
    final token = await getAuthToken();
    if (token == null || token.isEmpty) {
      throw Exception('No auth token found');
    }

    final response = await http.get(
      Uri.parse(ApiConstants.profile),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    // ✅ Check for token expiration
    _checkTokenExpiration(response.statusCode, response.body);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to fetch profile: ${response.statusCode}');
  }


  Future<ActionHistoryResponse> fetchApplicationHistory(String applicationId) async {
    final token = await getAuthToken();
    if (token == null || token.isEmpty) {
      throw Exception('No auth token found');
    }

    try {
      final response = await http.get(
        Uri.parse(ApiConstants.getApplicationHistory(applicationId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Application History Response: ${response.body}');

      // ✅ Check for token expiration
      _checkTokenExpiration(response.statusCode, response.body);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return ActionHistoryResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to fetch application history: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching application history: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateProfileMultipart({
    String? name,
    String? email,
    File? profileImage,
  }) async {
    final token = await getAuthToken();
    if (token == null || token.isEmpty) {
      throw Exception('No auth token found');
    }

    final uri = Uri.parse(ApiConstants.profileUpdate);
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token';

    if (name != null && name.trim().isNotEmpty) {
      request.fields['name'] = name.trim();
    }

    if (email != null && email.trim().isNotEmpty) {
      request.fields['email'] = email.trim();
    }

    if (profileImage != null) {
      final mimeType = 'image/jpeg';
      request.files.add(
        await http.MultipartFile.fromPath(
          'profile',
          profileImage.path,
          contentType: MediaType.parse(mimeType),
        ),
      );
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    // ✅ Check for token expiration
    _checkTokenExpiration(response.statusCode, response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to update profile: ${response.statusCode}: ${response.body}');
    }
  }

  Future<ApplicationTypeResponse> fetchApplicationTypes() async {
    final token = await getAuthToken();
    if (token == null || token.isEmpty) {
      throw Exception('No auth token found');
    }

    final response = await http.get(
      Uri.parse(ApiConstants.applicationType),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    // ✅ Check for token expiration
    _checkTokenExpiration(response.statusCode, response.body);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      return ApplicationTypeResponse.fromJson(jsonData);
    } else {
      throw Exception('Failed to fetch application types: ${response.statusCode}');
    }
  }

  Future<ApplicationStatusResponse> fetchApplicationStatuses() async {
    final token = await getAuthToken();
    if (token == null || token.isEmpty) {
      throw Exception('No auth token found');
    }

    final response = await http.get(
      Uri.parse(ApiConstants.applicationStatus),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    // ✅ Check for token expiration
    _checkTokenExpiration(response.statusCode, response.body);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      return ApplicationStatusResponse.fromJson(jsonData);
    } else {
      throw Exception('Failed to fetch application statuses: ${response.statusCode}');
    }
  }
  Future<ApplicationHistoryResponse> postApplicationHistory(
      String applicationId,
      ApplicationHistoryRequest request) async {
    final token = await getAuthToken();
    if (token == null || token.isEmpty) {
      throw Exception('No auth token found');
    }

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.postApplicationHistory(applicationId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      );

      print('Post Application History Response: ${response.body}');

      // ✅ Check for token expiration
      _checkTokenExpiration(response.statusCode, response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return ApplicationHistoryResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to post application history: ${response.statusCode}');
      }
    } catch (e) {
      print('Error posting application history: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchApplicationDetail(String applicationId) async {
    final token = await getAuthToken();
    if (token == null || token.isEmpty) {
      throw Exception('No auth token found');
    }

    final response = await http.get(
      Uri.parse(ApiConstants.getApplicationDetails(applicationId)),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    // ✅ Check for token expiration
    _checkTokenExpiration(response.statusCode, response.body);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to fetch application detail: ${response.statusCode}');
  }

  Future<EditApplicationResponse> editApplication(String applicationId, EditApplicationModel applicationData) async {
    try {
      final token = await getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('No auth token found');
      }

      final uri = Uri.parse(ApiConstants.editApplication(applicationId));
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..headers['Accept'] = 'application/json';

      request.fields.addAll(applicationData.toFormFields());

      if (applicationData.aadhaarFile != null) {
        File? compressedAadhaar = await compressImage(applicationData.aadhaarFile!);
        if (compressedAadhaar != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'aadhaar_file',
              compressedAadhaar.path,
              contentType: MediaType.parse('image/jpeg'),
            ),
          );
        }
      }

      if (applicationData.panCardFile != null) {
        File? compressedPan = await compressImage(applicationData.panCardFile!);
        if (compressedPan != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'pan_card_file',
              compressedPan.path,
              contentType: MediaType.parse('image/jpeg'),
            ),
          );
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // ✅ Check for token expiration
      _checkTokenExpiration(response.statusCode, response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return EditApplicationResponse.fromJson(jsonData);
      } else {
        return EditApplicationResponse(
          success: false,
          message: 'Failed to update application: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      return EditApplicationResponse(
        success: false,
        message: 'Network error: $e',
      );
    }
  }

  Future<File?> compressImage(File imageFile, {int quality = 85, int maxWidth = 1920, int maxHeight = 1080}) async {
    try {
      final String targetPath = path.join(
          Directory.systemTemp.path,
          'compressed_${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}'
      );

      final XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: quality,
        minWidth: maxWidth,
        minHeight: maxHeight,
        format: CompressFormat.jpeg,
      );

      if (compressedFile != null) {
        final compressedImageFile = File(compressedFile.path);
        print('Original size: ${imageFile.lengthSync()} bytes');
        print('Compressed size: ${compressedImageFile.lengthSync()} bytes');
        return compressedImageFile;
      }
      return null;
    } catch (e) {
      print('Error compressing image: $e');
      return imageFile;
    }
  }

  Future<CreateApplicationResponse> createApplication(CreateApplicationModel applicationData) async {
    try {
      final token = await getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('No auth token found');
      }

      final uri = Uri.parse(ApiConstants.createApplciations);
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..headers['Accept'] = 'application/json';

      request.fields.addAll(applicationData.toFormFields());

      if (applicationData.aadhaarFile != null) {
        File? compressedAadhaar;
        final aadhaarExtension = path.extension(applicationData.aadhaarFile!.path).toLowerCase();

        if (['.jpg', '.jpeg', '.png'].contains(aadhaarExtension)) {
          compressedAadhaar = await compressImage(
            applicationData.aadhaarFile!,
            quality: 85,
            maxWidth: 1920,
            maxHeight: 1080,
          );
        } else {
          compressedAadhaar = applicationData.aadhaarFile;
        }

        if (compressedAadhaar != null) {
          final mimeType = aadhaarExtension == '.pdf' ? 'application/pdf' : 'image/jpeg';
          request.files.add(
            await http.MultipartFile.fromPath(
              'aadhaar_file',
              compressedAadhaar.path,
              contentType: MediaType.parse(mimeType),
            ),
          );
        }
      }

      if (applicationData.panCardFile != null) {
        File? compressedPan;
        final panExtension = path.extension(applicationData.panCardFile!.path).toLowerCase();

        if (['.jpg', '.jpeg', '.png'].contains(panExtension)) {
          compressedPan = await compressImage(
            applicationData.panCardFile!,
            quality: 85,
            maxWidth: 1920,
            maxHeight: 1080,
          );
        } else {
          compressedPan = applicationData.panCardFile;
        }

        if (compressedPan != null) {
          final mimeType = panExtension == '.pdf' ? 'application/pdf' : 'image/jpeg';
          request.files.add(
            await http.MultipartFile.fromPath(
              'pan_card_file',
              compressedPan.path,
              contentType: MediaType.parse(mimeType),
            ),
          );
        }
      }

      print('Sending request to: ${request.url}');
      print('Request fields: ${request.fields}');
      print('Request files: ${request.files.map((f) => f.field).toList()}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      // ✅ Check for token expiration
      _checkTokenExpiration(response.statusCode, response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return CreateApplicationResponse.fromJson(jsonData);
      } else {
        return CreateApplicationResponse(
          success: false,
          message: 'Failed to create application: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error creating application: $e');
      return CreateApplicationResponse(
        success: false,
        message: 'Network error: $e',
      );
    }
  }

  Future<AgentsResponse> fetchAgents() async {
    try {
      final token = await getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('No auth token found');
      }

      final response = await http.get(
        Uri.parse(ApiConstants.getAgents),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('Agents API Response status: ${response.statusCode}');
      print('Agents API Response body: ${response.body}');

      // ✅ Check for token expiration
      _checkTokenExpiration(response.statusCode, response.body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return AgentsResponse.fromJson(jsonData);
      } else {
        return AgentsResponse(
          success: false,
          message: 'Failed to fetch agents. Status: ${response.statusCode}',
          data: [],
        );
      }
    } catch (e) {
      print('Error fetching agents: $e');
      return AgentsResponse(
        success: false,
        message: 'Network error: $e',
        data: [],
      );
    }
  }
// In ApiClient class, add this method:

  Future<EmployeeResponse> fetchEmployeesByBranch() async {
    final token = await getAuthToken();
    if (token == null || token.isEmpty) {
      throw Exception('No auth token found');
    }

    try {
      final response = await http.get(
        Uri.parse(ApiConstants.employeesByBranch),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Employees Response: ${response.body}');

      // ✅ Check for token expiration
      _checkTokenExpiration(response.statusCode, response.body);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return EmployeeResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to fetch employees: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching employees: $e');
      rethrow;
    }
  }
// In ApiClient class, add this method:

  Future<LeadsResponse> fetchLeads() async {
    final token = await getAuthToken();
    if (token == null || token.isEmpty) {
      throw Exception('No auth token found');
    }

    try {
      final response = await http.get(
        Uri.parse(ApiConstants.leads),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Leads Response: ${response.body}');

      // ✅ Check for token expiration
      _checkTokenExpiration(response.statusCode, response.body);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return LeadsResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to fetch leads: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching leads: $e');
      rethrow;
    }
  }

  Future<DocumentResponse> fetchDocuments() async {
    final token = await getAuthToken();
    if (token == null || token.isEmpty) {
      throw Exception('No auth token found');
    }

    final response = await http.get(
      Uri.parse(ApiConstants.getDocuments),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('[Documents] Fetch Response: ${response.statusCode}');
    print('[Documents] Response body: ${response.body}');

    // ✅ Check for token expiration
    _checkTokenExpiration(response.statusCode, response.body);

    if (response.statusCode == 200) {
      return DocumentResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch documents: ${response.statusCode}');
    }
  }

  Future<UploadDocumentResponse> uploadDocument({
    required File file,
    required String title,
    String? description,
  }) async {
    final token = await getAuthToken();
    if (token == null || token.isEmpty) {
      throw Exception('No auth token found');
    }

    final uri = Uri.parse(ApiConstants.postDocuments);
    final request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';
    request.fields['title'] = title;

    if (description != null && description.isNotEmpty) {
      request.fields['description'] = description;
    }

    File fileToUpload = file;
    final extension = path.extension(file.path).toLowerCase();

    if (['.jpg', '.jpeg', '.png'].contains(extension)) {
      final compressed = await compressImage(file);
      if (compressed != null) {
        fileToUpload = compressed;
        print('[Documents] Image compressed: ${file.lengthSync()} -> ${compressed.lengthSync()} bytes');
      }
    }

    String contentType = 'application/octet-stream';
    if (extension == '.pdf') {
      contentType = 'application/pdf';
    } else if (['.jpg', '.jpeg'].contains(extension)) {
      contentType = 'image/jpeg';
    } else if (extension == '.png') {
      contentType = 'image/png';
    }

    final multipartFile = await http.MultipartFile.fromPath(
      'document_file',
      fileToUpload.path,
      contentType: MediaType.parse(contentType),
    );
    request.files.add(multipartFile);

    print('[Documents] Uploading: ${path.basename(file.path)}');
    print('[Documents] Title: $title');
    print('[Documents] File size: ${fileToUpload.lengthSync()} bytes');
    print('[Documents] Content type: $contentType');

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print('[Documents] Upload Response: ${response.statusCode}');
    print('[Documents] Response body: ${response.body}');

    // ✅ Check for token expiration
    _checkTokenExpiration(response.statusCode, response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return UploadDocumentResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to upload document: ${response.statusCode} - ${response.body}');
    }
  }

  Future<OtherDocumentResponse> fetchOtherDocuments(String applicationId) async {
    final token = await getAuthToken();
    if (token == null || token.isEmpty) {
      throw Exception('No auth token found');
    }

    final url = ApiConstants.getotherDocuments.replaceAll('{{application_id}}', applicationId);

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('[OtherDocuments] Fetch Response: ${response.statusCode}');
    print('[OtherDocuments] Response body: ${response.body}');

    // ✅ Check for token expiration
    _checkTokenExpiration(response.statusCode, response.body);

    if (response.statusCode == 200) {
      return OtherDocumentResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch other documents: ${response.statusCode}');
    }
  }

  Future<UploadOtherDocumentResponse> uploadOtherDocument({
    required String applicationId,
    required File file,
    required String documentName,
  }) async {
    final token = await getAuthToken();
    if (token == null || token.isEmpty) {
      throw Exception('No auth token found');
    }

    final url = ApiConstants.postotherDocuments.replaceAll('{{application_id}}', applicationId);
    final uri = Uri.parse(url);
    final request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';
    request.fields['document_name'] = documentName;

    File fileToUpload = file;
    final extension = path.extension(file.path).toLowerCase();

    if (['.jpg', '.jpeg', '.png'].contains(extension)) {
      final compressed = await compressImage(file);
      if (compressed != null) {
        fileToUpload = compressed;
        print('[OtherDocuments] Image compressed: ${file.lengthSync()} -> ${compressed.lengthSync()} bytes');
      }
    }

    String contentType = 'application/octet-stream';
    if (extension == '.pdf') {
      contentType = 'application/pdf';
    } else if (['.jpg', '.jpeg'].contains(extension)) {
      contentType = 'image/jpeg';
    } else if (extension == '.png') {
      contentType = 'image/png';
    }

    final multipartFile = await http.MultipartFile.fromPath(
      'file',
      fileToUpload.path,
      contentType: MediaType.parse(contentType),
    );
    request.files.add(multipartFile);

    print('[OtherDocuments] Uploading: ${path.basename(file.path)}');
    print('[OtherDocuments] Document Name: $documentName');
    print('[OtherDocuments] File size: ${fileToUpload.lengthSync()} bytes');
    print('[OtherDocuments] Content type: $contentType');

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print('[OtherDocuments] Upload Response: ${response.statusCode}');
    print('[OtherDocuments] Response body: ${response.body}');

    // ✅ Check for token expiration
    _checkTokenExpiration(response.statusCode, response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return UploadOtherDocumentResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to upload other document: ${response.statusCode} - ${response.body}');
    }
  }

  Future<DeleteOtherDocumentResponse> deleteOtherDocument(String documentId) async {
    final token = await getAuthToken();
    if (token == null || token.isEmpty) {
      throw Exception('No auth token found');
    }

    final url = ApiConstants.deleteotherDocuments.replaceAll('{{document_id}}', documentId);

    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('[OtherDocuments] Delete Response: ${response.statusCode}');
    print('[OtherDocuments] Response body: ${response.body}');

    // ✅ Check for token expiration
    _checkTokenExpiration(response.statusCode, response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return DeleteOtherDocumentResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to delete other document: ${response.statusCode}');
    }
  }
  // In api_client.dart - Add this method

// In api_client.dart - Replace the fetchLeadDetail method

  Future<LeadDetailResponse> fetchLeadDetail(String leadId) async {
    final token = await getAuthToken();
    if (token == null || token.isEmpty) {
      throw Exception('No auth token found');
    }

    try {
      final response = await http.get(
        Uri.parse(ApiConstants.getLeadDetails(leadId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Lead Detail Response: ${response.body}');

      _checkTokenExpiration(response.statusCode, response.body);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return LeadDetailResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to fetch lead detail: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching lead detail: $e');
      rethrow;
    }
  }
  Future<UpdatePasswordResponse> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final token = await getAuthToken();
    if (token == null || token.isEmpty) {
      throw Exception('No auth token found');
    }

    final response = await http.post(
      Uri.parse(ApiConstants.updatePassword),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'current_password': currentPassword,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      }),
    );

    _checkTokenExpiration(response.statusCode, response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return UpdatePasswordResponse.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 400) {
      // Handle 400 Bad Request with user-friendly message
      try {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['error'] ?? errorData['message'] ?? 'Invalid request';
        throw Exception(errorMessage);
      } catch (e) {
        throw Exception('Please check your password and try again');
      }
    } else if (response.statusCode == 401) {
      throw Exception('Current password is incorrect');
    } else {
      try {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['error'] ?? errorData['message'];
        throw Exception(errorMessage ?? 'Failed to update password');
      } catch (e) {
        throw Exception('Unable to update password. Please try again');
      }
    }
  }
// Delete lead
  Future<DeleteLeadResponse> deleteLead(String leadId) async {
    final token = await getAuthToken();
    if (token == null || token.isEmpty) {
      throw Exception('No auth token found');
    }

    final response = await http.delete(
      Uri.parse(ApiConstants.deleteLead(leadId)),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('🗑️ Delete Lead Response: ${response.statusCode}');
    print('🗑️ Response Body: ${response.body}');

    _checkTokenExpiration(response.statusCode, response.body);

    if (response.statusCode == 200 || response.statusCode == 204) {
      try {
        final jsonResponse = jsonDecode(response.body);
        return DeleteLeadResponse.fromJson(jsonResponse);
      } catch (e) {
        // If response is empty (204 No Content), return success
        return DeleteLeadResponse(
          success: true,
          message: 'Lead deleted successfully',
        );
      }
    } else if (response.statusCode == 404) {
      throw Exception('Lead not found');
    } else if (response.statusCode == 403) {
      throw Exception('You do not have permission to delete this lead');
    } else {
      try {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['error'] ?? errorData['message'] ?? 'Failed to delete lead';
        throw Exception(errorMessage);
      } catch (e) {
        throw Exception('Unable to delete lead. Please try again');
      }
    }
  }
// Send OTP to phone number
  Future<Map<String, dynamic>> sendOtp(String phone) async {
    final response = await http.post(
      Uri.parse(ApiConstants.sendOtp),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone}),
    );

    print('📤 Send OTP Response: ${response.statusCode}');
    print('📄 Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 422) {
      // Unprocessable Entity - invalid phone
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Invalid phone number');
    } else {
      throw Exception('Failed to send OTP. Server responded: ${response.statusCode}');
    }
  }

// Verify OTP and login
  Future<LoginResponse> verifyOtp(String phone, String otp) async {
    final response = await http.post(
      Uri.parse(ApiConstants.verifyOtp),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'otp': otp}),
    );

    print('✅ Verify OTP Response: ${response.statusCode}');
    print('📄 Response Body: ${response.body}');

    _checkTokenExpiration(response.statusCode, response.body);

    if (response.statusCode == 200) {
      return LoginResponse.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 400) {
      // Bad Request - invalid or expired OTP
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Invalid or expired OTP');
    } else {
      throw Exception('Failed to verify OTP. Server responded: ${response.statusCode}');
    }
  }
// Register new customer
  Future<Map<String, dynamic>> registerCustomer({
    required String name,
    required String phone,
    required String email,
    required String dob,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.registerCustomer),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'phone': phone,
        'email': email,
        'dob': dob,
      }),
    );

    print('📤 Register Customer Response: ${response.statusCode}');
    print('📄 Response Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 422 || response.statusCode == 400) {
      // Validation error - email/phone already taken
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Registration failed');
    } else {
      throw Exception('Failed to register. Server responded: ${response.statusCode}');
    }
  }
// Fetch Relationship Manager
  Future<Map<String, dynamic>> fetchRelationshipManager() async {
    final token = await getAuthToken();
    if (token == null || token.isEmpty) {
      throw Exception('No authentication token found');
    }

    final response = await http.get(
      Uri.parse(ApiConstants.relationshipManager),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('📤 Fetch RM Response: ${response.statusCode}');
    print('📄 Response Body: ${response.body}');

    _checkTokenExpiration(response.statusCode, response.body);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch relationship manager. Status: ${response.statusCode}');
    }
  }
// lib/core/data/api_client/api_client.dart

// ✅ Add this method to ApiClient class
  Future<Map<String, dynamic>> submitCustomerFeedback({
    required String rmName,
    required String rmNumber,
    required String issueType,
    String? remarks,
  }) async {
    print('[API] submitCustomerFeedback() -> start');
    print('[API] Payload: rmName=$rmName, rmNumber=$rmNumber, issueType=$issueType, remarks=$remarks');

    try {
      final token = await getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse(ApiConstants.customerFeedback),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'rmname': rmName,
          'rmnumber': rmNumber,
          'issue_type': issueType,
          if (remarks != null && remarks.isNotEmpty) 'remarks': remarks,
        }),
      );

      print('[API] submitCustomerFeedback() -> status: ${response.statusCode}');
      print('[API] submitCustomerFeedback() -> body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return jsonData;
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e, st) {
      print('[API] submitCustomerFeedback() -> ERROR: $e');
      print('[API] Stack trace: $st');
      rethrow;
    }
  }

}

/*
mport 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as path;
import '../../../Screens/application_detail/model/action_history_model.dart';
import '../../../Screens/application_detail/model/application_history_model.dart';
import '../../../Screens/documents/models/document_model.dart';
import '../../../Screens/edit_application/model/edit_application_model.dart';
import '../../../Screens/home_screen/model/dashboard_model.dart';
import '../../../Screens/new_application/model/agents_model.dart';
import '../../../Screens/new_application/model/application_status_model.dart';
import '../../../Screens/new_application/model/application_type_model.dart';
import '../../../Screens/new_application/model/create_application_model.dart';
import '../../../Screens/sign_in_screen/login_model/login_responce_model.dart';
import '../../../core/data/api_constant/api_constant.dart';

import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiClient {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  Future<String?> getAuthToken() async {
    return await secureStorage.read(key: 'auth_token');
  }

  Future<bool> hasValidToken() async {
    try {
      final token = await getAuthToken();
      return token != null && token.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
  Future<void> clearToken() async {
    await secureStorage.delete(key: 'auth_token');
  }

  Future<bool> logout() async {
    try {
      final token = await getAuthToken();
      if (token != null && token.isNotEmpty) {
        final response = await http.post(
          Uri.parse(ApiConstants.logout),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        await clearToken();
        return response.statusCode == 200 || response.statusCode == 201;
      } else {
        await clearToken();
        return true;
      }
    } catch (_) {
      await clearToken();
      return false;
    }
  }

  Future<LoginResponse> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(ApiConstants.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return LoginResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to login. Server responded: ${response.statusCode}');
    }
  }

// Updated clockIn method in ApiClient
  Future<Map<String, dynamic>> clockIn({double? latitude, double? longitude}) async {
    final token = await getAuthToken();

    // Prepare the payload
    Map<String, dynamic> payload = {
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Add coordinates if provided
    if (latitude != null && longitude != null) {
      payload['latitude'] = latitude;
      payload['longitude'] = longitude;
      print('🌍 Clock in with location: Lat: $latitude, Lng: $longitude');
    } else {
      print('⚠️ Clock in without location coordinates');
    }

    final response = await http.post(
      Uri.parse(ApiConstants.clockIn),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to clock in. Server responded: ${response.statusCode}');
    }
  }

// Also update clockOut method if needed

  Future<Map<String, dynamic>> clockOut() async {
    final token = await getAuthToken();
    final response = await http.post(
      Uri.parse(ApiConstants.clockout),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'timestamp': DateTime.now().toIso8601String()}),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to clock out. Server responded: ${response.statusCode}');
    }
  }
  Future<DashboardResponse> fetchDashboard() async {
    final token = await getAuthToken();
    if (token == null || token.isEmpty) {
      throw Exception('No auth token found');
    }

    final response = await http.get(
      Uri.parse(ApiConstants.getDashboard),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      return DashboardResponse.fromJson(jsonData);
    } else {
      throw Exception('Failed to fetch dashboard: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchProfile() async {
    final token = await getAuthToken();
    if (token == null || token.isEmpty) {
      throw Exception('No auth token found');
    }

    final response = await http.get(
      Uri.parse(ApiConstants.profile),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to fetch profile: ${response.statusCode}');
  }
// Add this method to your existing ApiClient class
  Future<ApplicationHistoryResponse> postApplicationHistory(
      String applicationId,
      ApplicationHistoryRequest request
      ) async {
    final token = await getAuthToken();
    if (token == null || token.isEmpty) {
      throw Exception('No auth token found');
    }

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.postApplicationHistory(applicationId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      );

      print('Application History Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return ApplicationHistoryResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to update application history: ${response.statusCode}');
      }
    } catch (e) {
      print('Error posting application history: $e');
      rethrow;
    }
  }
// Add this method to your existing ApiClient class
  Future<ActionHistoryResponse> fetchApplicationHistory(String applicationId) async {
    final token = await getAuthToken();
    if (token == null || token.isEmpty) {
      throw Exception('No auth token found');
    }

    try {
      final response = await http.get(
        Uri.parse(ApiConstants.getApplicationHistory(applicationId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Application History Response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return ActionHistoryResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to fetch application history: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching application history: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateProfileMultipart({
    String? name,
    String? email,
    File? profileImage,
  }) async {
    final token = await getAuthToken();
    if (token == null || token.isEmpty) {
      throw Exception('No auth token found');
    }

    final uri = Uri.parse(ApiConstants.profileUpdate);
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token';

    if (name != null && name.trim().isNotEmpty) {
      request.fields['name'] = name.trim();
    }

    if (email != null && email.trim().isNotEmpty) {
      request.fields['email'] = email.trim();
    }

    if (profileImage != null) {
      final mimeType = 'image/jpeg';
      request.files.add(
        await http.MultipartFile.fromPath(
          'profile',
          profileImage.path,
          contentType: MediaType.parse(mimeType),
        ),
      );
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to update profile: ${response.statusCode}: ${response.body}');
    }
  }

  Future<ApplicationTypeResponse> fetchApplicationTypes() async {
    final token = await getAuthToken();
    if (token == null || token.isEmpty) {
      throw Exception('No auth token found');
    }

    final response = await http.get(
      Uri.parse(ApiConstants.applicationType),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      return ApplicationTypeResponse.fromJson(jsonData);
    } else {
      throw Exception('Failed to fetch application types: ${response.statusCode}');
    }
  }

  Future<ApplicationStatusResponse> fetchApplicationStatuses() async {
    final token = await getAuthToken();
    if (token == null || token.isEmpty) {
      throw Exception('No auth token found');
    }

    final response = await http.get(
      Uri.parse(ApiConstants.applicationStatus),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      return ApplicationStatusResponse.fromJson(jsonData);
    } else {
      throw Exception('Failed to fetch application statuses: ${response.statusCode}');
    }
  }
  Future<Map<String, dynamic>> fetchApplicationDetail(String applicationId) async {
    final token = await getAuthToken();
    if (token == null || token.isEmpty) {
      throw Exception('No auth token found');
    }

    final response = await http.get(
      Uri.parse(ApiConstants.getApplicationDetails(applicationId)),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to fetch application detail: ${response.statusCode}');
  }
// Add this method to your existing ApiClient class
  Future<EditApplicationResponse> editApplication(String applicationId, EditApplicationModel applicationData) async {
    try {
      final token = await getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('No auth token found');
      }

      final uri = Uri.parse(ApiConstants.editApplication(applicationId));
      final request = http.MultipartRequest('POST', uri) // or 'POST' based on your API
        ..headers['Authorization'] = 'Bearer $token'
        ..headers['Accept'] = 'application/json';

      // Add form fields
      request.fields.addAll(applicationData.toFormFields());

      // Add files if they exist
      if (applicationData.aadhaarFile != null) {
        File? compressedAadhaar = await compressImage(applicationData.aadhaarFile!);
        if (compressedAadhaar != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'aadhaar_file',
              compressedAadhaar.path,
              contentType: MediaType.parse('image/jpeg'),
            ),
          );
        }
      }

      if (applicationData.panCardFile != null) {
        File? compressedPan = await compressImage(applicationData.panCardFile!);
        if (compressedPan != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'pan_card_file',
              compressedPan.path,
              contentType: MediaType.parse('image/jpeg'),
            ),
          );
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return EditApplicationResponse.fromJson(jsonData);
      } else {
        return EditApplicationResponse(
          success: false,
          message: 'Failed to update application: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      return EditApplicationResponse(
        success: false,
        message: 'Network error: $e',
      );
    }
  }

  // NEW: Image compression method
  Future<File?> compressImage(File imageFile, {int quality = 85, int maxWidth = 1920, int maxHeight = 1080}) async {
    try {
      final String targetPath = path.join(
          Directory.systemTemp.path,
          'compressed_${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}'
      );

      final XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: quality,
        minWidth: maxWidth,
        minHeight: maxHeight,
        format: CompressFormat.jpeg,
      );

      if (compressedFile != null) {
        final compressedImageFile = File(compressedFile.path);
        print('Original size: ${imageFile.lengthSync()} bytes');
        print('Compressed size: ${compressedImageFile.lengthSync()} bytes');
        return compressedImageFile;
      }
      return null;
    } catch (e) {
      print('Error compressing image: $e');
      return imageFile; // Return original if compression fails
    }
  }

  // NEW: Create application method with compression
  Future<CreateApplicationResponse> createApplication(CreateApplicationModel applicationData) async {
    try {
      final token = await getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('No auth token found');
      }

      final uri = Uri.parse(ApiConstants.createApplciations);
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..headers['Accept'] = 'application/json';

      // Add form fields matching API payload
      request.fields.addAll(applicationData.toFormFields());

      // Compress and add Aadhaar file
      if (applicationData.aadhaarFile != null) {
        File? compressedAadhaar;

        // Check if it's an image or PDF
        final aadhaarExtension = path.extension(applicationData.aadhaarFile!.path).toLowerCase();
        if (['.jpg', '.jpeg', '.png'].contains(aadhaarExtension)) {
          // Compress image files
          compressedAadhaar = await compressImage(
            applicationData.aadhaarFile!,
            quality: 85,
            maxWidth: 1920,
            maxHeight: 1080,
          );
        } else {
          // Use original file for PDFs
          compressedAadhaar = applicationData.aadhaarFile;
        }

        if (compressedAadhaar != null) {
          final mimeType = aadhaarExtension == '.pdf' ? 'application/pdf' : 'image/jpeg';
          request.files.add(
            await http.MultipartFile.fromPath(
              'aadhaar_file', // Match API payload
              compressedAadhaar.path,
              contentType: MediaType.parse(mimeType),
            ),
          );
        }
      }

      // Compress and add PAN file
      if (applicationData.panCardFile != null) {
        File? compressedPan;

        // Check if it's an image or PDF
        final panExtension = path.extension(applicationData.panCardFile!.path).toLowerCase();
        if (['.jpg', '.jpeg', '.png'].contains(panExtension)) {
          // Compress image files
          compressedPan = await compressImage(
            applicationData.panCardFile!,
            quality: 85,
            maxWidth: 1920,
            maxHeight: 1080,
          );
        } else {
          // Use original file for PDFs
          compressedPan = applicationData.panCardFile;
        }

        if (compressedPan != null) {
          final mimeType = panExtension == '.pdf' ? 'application/pdf' : 'image/jpeg';
          request.files.add(
            await http.MultipartFile.fromPath(
              'pan_card_file', // Match API payload
              compressedPan.path,
              contentType: MediaType.parse(mimeType),
            ),
          );
        }
      }

      print('Sending request to: ${request.url}');
      print('Request fields: ${request.fields}');
      print('Request files: ${request.files.map((f) => f.field).toList()}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return CreateApplicationResponse.fromJson(jsonData);
      } else {
        return CreateApplicationResponse(
          success: false,
          message: 'Failed to create application: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error creating application: $e');
      return CreateApplicationResponse(
        success: false,
        message: 'Network error: $e',
      );
    }
  }
  Future<AgentsResponse> fetchAgents() async {
    try {
      final token = await getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('No auth token found');
      }

      final response = await http.get(
        Uri.parse(ApiConstants.getAgents),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('Agents API Response status: ${response.statusCode}');
      print('Agents API Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return AgentsResponse.fromJson(jsonData);
      } else {
        return AgentsResponse(
          success: false,
          message: 'Failed to fetch agents. Status: ${response.statusCode}',
          data: [],
        );
      }
    } catch (e) {
      print('Error fetching agents: $e');
      return AgentsResponse(
        success: false,
        message: 'Network error: $e',
        data: [],
      );
    }
  }
// Add to your existing ApiClient class

  Future<DocumentResponse> fetchDocuments() async {
    final token = await getAuthToken();
    if (token == null || token.isEmpty) {
      throw Exception('No auth token found');
    }

    final response = await http.get(
      Uri.parse(ApiConstants.getDocuments),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('[Documents] Fetch Response: ${response.statusCode}');
    print('[Documents] Response body: ${response.body}');

    if (response.statusCode == 200) {
      return DocumentResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch documents: ${response.statusCode}');
    }
  }

  Future<UploadDocumentResponse> uploadDocument({
    required File file,
    required String title,
  }) async {
    final token = await getAuthToken();
    if (token == null || token.isEmpty) {
      throw Exception('No auth token found');
    }

    final uri = Uri.parse(ApiConstants.postDocuments);
    final request = http.MultipartRequest('POST', uri);

    // Add auth header
    request.headers['Authorization'] = 'Bearer $token';

    // Add title field
    request.fields['title'] = title;

    // Compress image if it's an image file
    File fileToUpload = file;
    final extension = path.extension(file.path).toLowerCase();
    if (['.jpg', '.jpeg', '.png'].contains(extension)) {
      final compressed = await compressImage(file);
      if (compressed != null) {
        fileToUpload = compressed;
      }
    }

    // Determine content type
    String contentType = 'application/octet-stream';
    if (extension == '.pdf') {
      contentType = 'application/pdf';
    } else if (['.jpg', '.jpeg'].contains(extension)) {
      contentType = 'image/jpeg';
    } else if (extension == '.png') {
      contentType = 'image/png';
    }

    // Add file
    final multipartFile = await http.MultipartFile.fromPath(
      'file',
      fileToUpload.path,
      contentType: MediaType.parse(contentType),
    );
    request.files.add(multipartFile);

    print('[Documents] Uploading: ${path.basename(file.path)}');
    print('[Documents] File size: ${fileToUpload.lengthSync()} bytes');
    print('[Documents] Content type: $contentType');

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print('[Documents] Upload Response: ${response.statusCode}');
    print('[Documents] Response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return UploadDocumentResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to upload document: ${response.statusCode}');
    }
  }

}
* */

/*
  Future<String?> getAuthToken() async {
    return await secureStorage.read(key: 'auth_token');
  }



  Future<bool> hasValidToken() async {
    try {
      final token = await getAuthToken();
      return token != null && token.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> clearToken() async {
    await secureStorage.delete(key: 'auth_token');
  }

  Future<bool> logout() async {
    try {
      final token = await getAuthToken();
      if (token != null && token.isNotEmpty) {
        final response = await http.post(
          Uri.parse(ApiConstants.logout),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        await clearToken();
        return response.statusCode == 200 || response.statusCode == 201;
      } else {
        await clearToken();
        return true;
      }
    } catch (_) {
      await clearToken();
      return false;
    }
  }

  Future<LoginResponse> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(ApiConstants.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return LoginResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to login. Server responded: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> clockIn() async {
    final token = await getAuthToken();
    final response = await http.post(
      Uri.parse(ApiConstants.clockIn),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'timestamp': DateTime.now().toIso8601String()}),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to clock in. Server responded: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> clockOut() async {
    final token = await getAuthToken();
    final response = await http.post(
      Uri.parse(ApiConstants.clockout),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'timestamp': DateTime.now().toIso8601String()}),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to clock out. Server responded: ${response.statusCode}');
    }
  }

  // NEW: fetch profile
  Future<Map<String, dynamic>> fetchProfile() async {
    final token = await getAuthToken();
    if (token == null || token.isEmpty) {
      throw Exception('No auth token found');
    }

    final response = await http.get(
      Uri.parse(ApiConstants.profile),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to fetch profile: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> updateProfileMultipart({
    String? name,        // Made optional
    String? email,       // Made optional
    File? profileImage,  // Already optional
  }) async {
    final token = await getAuthToken();
    if (token == null || token.isEmpty) {
      throw Exception('No auth token found');
    }

    final uri = Uri.parse(ApiConstants.profileUpdate);
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token';

    // Only add fields if they have values
    if (name != null && name.trim().isNotEmpty) {
      request.fields['name'] = name.trim();
    }

    if (email != null && email.trim().isNotEmpty) {
      request.fields['email'] = email.trim();
    }

    if (profileImage != null) {
      final mimeType = 'image/jpeg';
      request.files.add(
        await http.MultipartFile.fromPath(
          'avatar', // Changed from 'profile' to 'avatar' to match your API
          profileImage.path,
          contentType: MediaType.parse(mimeType),
        ),
      );
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to update profile: ${response.statusCode}: ${response.body}');
    }
  }
  Future<ApplicationTypeResponse> fetchApplicationTypes() async {
    final token = await getAuthToken();
    if (token == null || token.isEmpty) {
      throw Exception('No auth token found');
    }

    final response = await http.get(
      Uri.parse(ApiConstants.applicationType),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      return ApplicationTypeResponse.fromJson(jsonData);
    } else {
      throw Exception('Failed to fetch application types: ${response.statusCode}');
    }
  }



  // NEW: Fetch Application Statuses
  Future<ApplicationStatusResponse> fetchApplicationStatuses() async {
    final token = await getAuthToken();
    if (token == null || token.isEmpty) {
      throw Exception('No auth token found');
    }

    final response = await http.get(
      Uri.parse(ApiConstants.applicationStatus),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      return ApplicationStatusResponse.fromJson(jsonData);
    } else {
      throw Exception('Failed to fetch application statuses: ${response.statusCode}');
    }
  }
\

 */