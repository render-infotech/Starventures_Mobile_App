  class LoginResponse {
    final bool status;
    final String message;
    final LoginData data;

    LoginResponse({required this.status, required this.message, required this.data});

    factory LoginResponse.fromJson(Map<String, dynamic> json) {
      bool statusValue;
      if (json['status'] is bool) {
        statusValue = json['status'];
      } else if (json['status'] is String) {
        statusValue = json['status'].toLowerCase() == 'true';
      } else {
        statusValue = false;
      }
      return LoginResponse(
        status: statusValue,
        message: json['message'] ?? '',
        data: json['data'] != null ? LoginData.fromJson(json['data']) : throw Exception('Missing data'),
      );
    }

  }

  class LoginData {
    final User user;
    final String token;

    LoginData({required this.user, required this.token});

    factory LoginData.fromJson(Map<String, dynamic> json) {
      return LoginData(
        user: User.fromJson(json['user']),
        token: json['token'],
      );
    }
  }

  class User {
    final int id;
    final String name;
    final String email;
    final String type;

    User({
      required this.id,
      required this.name,
      required this.email,
      required this.type,
    });

    factory User.fromJson(Map<String, dynamic> json) {
      return User(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        type: json['type'],
      );
    }
  }
