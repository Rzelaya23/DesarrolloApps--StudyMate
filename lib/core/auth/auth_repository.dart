import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

const _backendBaseUrl = 'http://10.0.2.2:4000';
const _globalPrefix = '/api';

const _storage = FlutterSecureStorage();
const _kAccessTokenKey = 'accessToken';
const _kRefreshTokenKey = 'refreshToken';

class AuthUser {
  final String id;
  final String name;
  final String email;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
  });
}

class AuthRepository {
  final http.Client _client;

  AuthRepository({http.Client? client}) : _client = client ?? http.Client();

  Future<AuthUser> login(String email, String password) async {
    final uri = Uri.parse('$_backendBaseUrl$_globalPrefix/auth/login');

    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Login fallido: ${response.statusCode} ${response.body}',
      );
    }

    final data = json.decode(response.body) as Map<String, dynamic>;

    final accessToken = data['accessToken'] as String?;
    final refreshToken = data['refreshToken'] as String?;

    if (accessToken == null || refreshToken == null) {
      throw Exception('Respuesta de login sin tokens');
    }

    // Guardamos tokens en almacenamiento seguro
    await _storage.write(key: _kAccessTokenKey, value: accessToken);
    await _storage.write(key: _kRefreshTokenKey, value: refreshToken);

    return AuthUser(
      id: data['id']?.toString() ?? '',
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? email,
    );
  }

  Future<void> logout() async {
    // Puedes también llamar a /auth/logout si quieres
    await _storage.delete(key: _kAccessTokenKey);
    await _storage.delete(key: _kRefreshTokenKey);
  }

  Future<String?> getAccessToken() async {
    return _storage.read(key: _kAccessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return _storage.read(key: _kRefreshTokenKey);
  }

  /// Intenta refrescar el accessToken cuando expira
  Future<String?> refreshAccessToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) return null;

    final uri = Uri.parse('$_backendBaseUrl$_globalPrefix/auth/refresh');

    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'refreshToken': refreshToken}),
    );

    if (response.statusCode != 200) {
      // Refresh falló, limpiamos sesión
      await logout();
      return null;
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final newAccessToken = data['accessToken'] as String?;
    final newRefreshToken = data['refreshToken'] as String?;

    if (newAccessToken == null || newRefreshToken == null) {
      await logout();
      return null;
    }

    await _storage.write(key: _kAccessTokenKey, value: newAccessToken);
    await _storage.write(key: _kRefreshTokenKey, value: newRefreshToken);

    return newAccessToken;
  }
}

/// Provider global del repositorio de auth
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});
