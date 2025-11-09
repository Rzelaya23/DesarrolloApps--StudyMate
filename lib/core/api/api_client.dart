// lib/core/api/api_client.dart
import 'package:dio/dio.dart';
import 'package:mi_app/core/api/api_config.dart';

class ApiClient {
  late final Dio _dio;

  /// Si [accessToken] no es null, se enviará como
  /// Authorization: Bearer <token> en cada petición.
  ApiClient({String? accessToken}) {
    final headers = <String, dynamic>{
      'Content-Type': 'application/json',
    };

    if (accessToken != null && accessToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: headers,
      ),
    );
  }

  Dio get client => _dio;
}
