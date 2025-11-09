// lib/features/auth/data/auth_service.dart
import 'package:dio/dio.dart';
import 'package:mi_app/core/api/api_client.dart';

class AuthUser {
  final String id;
  final String name;
  final String email;

  AuthUser({
    required this.id,
    required this.name,
    required this.email,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class AuthResult {
  final String accessToken;
  final AuthUser user;

  AuthResult({
    required this.accessToken,
    required this.user,
  });
}

class AuthService {
  final ApiClient _apiClient = ApiClient();

  /// Llama al endpoint de login del backend NestJS.
  ///
  /// Si tu ruta real es distinta (por ejemplo /auth/sign-in),
  /// solo cambia '/auth/login' por la correcta.
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final Response response = await _apiClient.client.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final accessToken = data['accessToken'] as String;
      final user = AuthUser.fromJson(data['user'] as Map<String, dynamic>);

      return AuthResult(accessToken: accessToken, user: user);
    } on DioException catch (e) {
      // Aquí puedes afinar mensajes según statusCode, etc.
      final backendMessage = e.response?.data ?? e.message;
      throw Exception('Error de autenticación: $backendMessage');
    }
  }
}
