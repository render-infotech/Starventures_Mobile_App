// lib/core/network/api_client.dart

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as path;
import '../../../Screens/edit_application/model/edit_application_model.dart';
import '../../../Screens/home_screen/model/dashboard_model.dart';
import '../../../Screens/new_application/model/application_status_model.dart';
import '../../../Screens/new_application/model/application_type_model.dart';
import '../../../Screens/new_application/model/create_application_model.dart';
import '../../../auth/sign_in_screen/login_model/login_responce_model.dart';
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
      throw Exception(
        'Failed to login. Server responded: ${response.statusCode}',
      );
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
      throw Exception(
        'Failed to clock in. Server responded: ${response.statusCode}',
      );
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
      throw Exception(
        'Failed to clock out. Server responded: ${response.statusCode}',
      );
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
          'avatar',
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
      throw Exception(
        'Failed to update profile: ${response.statusCode}: ${response.body}',
      );
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
      throw Exception(
        'Failed to fetch application types: ${response.statusCode}',
      );
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
      throw Exception(
        'Failed to fetch application statuses: ${response.statusCode}',
      );
    }
  }

  Future<Map<String, dynamic>> fetchApplicationDetail(
    String applicationId,
  ) async {
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
    throw Exception(
      'Failed to fetch application detail: ${response.statusCode}',
    );
  }

  // Add this method to your existing ApiClient class
  Future<EditApplicationResponse> editApplication(
    String applicationId,
    EditApplicationModel applicationData,
  ) async {
    try {
      final token = await getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('No auth token found');
      }

      final uri = Uri.parse(ApiConstants.editApplication(applicationId));
      final request =
          http.MultipartRequest('POST', uri) // or 'POST' based on your API
            ..headers['Authorization'] = 'Bearer $token'
            ..headers['Accept'] = 'application/json';

      // Add form fields
      request.fields.addAll(applicationData.toFormFields());

      // Add files if they exist
      if (applicationData.aadhaarFile != null) {
        File? compressedAadhaar = await compressImage(
          applicationData.aadhaarFile!,
        );
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
          message:
              'Failed to update application: ${response.statusCode} - ${response.body}',
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
  Future<File?> compressImage(
    File imageFile, {
    int quality = 85,
    int maxWidth = 1920,
    int maxHeight = 1080,
  }) async {
    try {
      final String targetPath = path.join(
        Directory.systemTemp.path,
        'compressed_${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}',
      );

      final XFile? compressedFile =
          await FlutterImageCompress.compressAndGetFile(
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
  Future<CreateApplicationResponse> createApplication(
    CreateApplicationModel applicationData,
  ) async {
    try {
      final token = await getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('No auth token found');
      }

      final uri = Uri.parse(ApiConstants.createApplciations);
      final request =
          http.MultipartRequest('POST', uri)
            ..headers['Authorization'] = 'Bearer $token'
            ..headers['Accept'] = 'application/json';

      // Add form fields matching API payload
      request.fields.addAll(applicationData.toFormFields());

      // Compress and add Aadhaar file
      if (applicationData.aadhaarFile != null) {
        File? compressedAadhaar;

        // Check if it's an image or PDF
        final aadhaarExtension =
            path.extension(applicationData.aadhaarFile!.path).toLowerCase();
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
          final mimeType =
              aadhaarExtension == '.pdf' ? 'application/pdf' : 'image/jpeg';
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
        final panExtension =
            path.extension(applicationData.panCardFile!.path).toLowerCase();
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
          final mimeType =
              panExtension == '.pdf' ? 'application/pdf' : 'image/jpeg';
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
          message:
              'Failed to create application: ${response.statusCode} - ${response.body}',
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
}


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