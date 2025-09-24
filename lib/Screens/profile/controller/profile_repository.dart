// // lib/Screens/profile/controller/profile_repository.dart
//
// import 'dart:io';
// import '../../../core/data/api_client/api_client.dart';
// import '../model/profile_models.dart';
//
// class ProfileRepository {
//   final ApiClient apiClient;
//   ProfileRepository({required this.apiClient});
//
//   Future<ProfileResponse> getProfile() async {
//     final map = await apiClient.fetchProfile();
//     return ProfileResponse.fromJson(map);
//   }
//
//   Future<bool> logout() => apiClient.logout();
//
//   Future<ProfileResponse> updateProfile({
//     required String name,
//     required String email,
//     File? profileImage,
//   }) async {
//     final map = await apiClient.updateProfileMultipart(
//       name: name,
//       email: email,
//       profileImage: profileImage,
//     );
//     // Assuming server responds with same structure {status, data:{user, employee}}
//     return ProfileResponse.fromJson(map);
//   }
// }
