import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mi_app/core/api/api_client.dart';
import 'package:mi_app/core/auth/auth_token_provider.dart';

/// =======================
/// DTOs de Perfil
/// =======================

class ProfileDto {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? timezone;

  final String? locale;
  final int? weeklyGoalMinutes;
  final int? dailyGoalMinutes;
  final int? points;

  const ProfileDto({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.timezone,
    this.locale,
    this.weeklyGoalMinutes,
    this.dailyGoalMinutes,
    this.points,
  });

  ProfileDto copyWith({
    String? name,
    String? avatarUrl,
    String? timezone,
    String? locale,
    int? weeklyGoalMinutes,
    int? dailyGoalMinutes,
    int? points,
  }) {
    return ProfileDto(
      id: id,
      name: name ?? this.name,
      email: email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      timezone: timezone ?? this.timezone,
      locale: locale ?? this.locale,
      weeklyGoalMinutes: weeklyGoalMinutes ?? this.weeklyGoalMinutes,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      points: points ?? this.points,
    );
  }

  factory ProfileDto.fromJson(Map<String, dynamic> json) {
    return ProfileDto(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      timezone: json['timezone'] as String?,
      locale: json['locale'] as String?,
      weeklyGoalMinutes: json['weeklyGoalMinutes'] as int?,
      dailyGoalMinutes: json['dailyGoalMinutes'] as int?,
      points: json['points'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'timezone': timezone,
      'locale': locale,
      'weeklyGoalMinutes': weeklyGoalMinutes,
      'dailyGoalMinutes': dailyGoalMinutes,
      'points': points,
    };
  }
}

/// Mapea directo a tu UpdateStudentDto (name, avatarUrl, timezone)
class UpdateProfilePayload {
  final String? name;
  final String? avatarUrl;
  final String? timezone;

  const UpdateProfilePayload({
    this.name,
    this.avatarUrl,
    this.timezone,
  });

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (timezone != null) 'timezone': timezone,
    };
  }
}

/// =======================
/// Servicio de Perfil con Dio + ApiClient
/// =======================

class ProfileService {
  final ApiClient _apiClient;
  final Ref _ref;

  ProfileService(this._ref) : _apiClient = ApiClient();

  String? _getAccessToken() {
    // Lee el token de tu StateProvider<String?>
    return _ref.read(authTokenProvider);
  }

  /// GET /api/api/v1/students/me
  Future<ProfileDto> getProfile() async {
    final token = _getAccessToken();
    if (token == null) {
      throw Exception('No hay sesión activa');
    }

    try {
      final Response response = await _apiClient.client.get(
        '/api/v1/students/me',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final data = response.data as Map<String, dynamic>;
      return ProfileDto.fromJson(data);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final body = e.response?.data;
      throw Exception('Error obteniendo perfil: $status $body');
    }
  }

  /// PATCH /api/api/v1/students/me
  Future<ProfileDto> updateProfile(UpdateProfilePayload payload) async {
    final token = _getAccessToken();
    if (token == null) {
      throw Exception('No hay sesión activa');
    }

    try {
      final Response response = await _apiClient.client.patch(
        '/api/v1/students/me',
        data: json.encode(payload.toJson()),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      final data = response.data as Map<String, dynamic>;
      return ProfileDto.fromJson(data);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final body = e.response?.data;
      throw Exception('Error actualizando perfil: $status $body');
    }
  }
}

/// Provider para usar en ProfileScreen
final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService(ref);
});
