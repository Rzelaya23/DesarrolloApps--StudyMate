// lib/core/api/test_connection_service.dart
import 'package:dio/dio.dart';
import 'api_client.dart';

/// Servicio sencillo para probar la conexión con el backend.
class TestConnectionService {
  final ApiClient _apiClient = ApiClient();

  /// Intenta hacer un GET a /events.
  ///
  /// Importante:
  /// - El baseUrl ya incluye: http://10.0.2.2:3000/api/api/v1
  /// - Así que aquí solo ponemos '/events'.
  Future<String> pingEvents() async {
    try {
      final Response response = await _apiClient.client.get('/events');

      return 'OK: status ${response.statusCode}, body: ${response.data.toString()}';
    } on DioException catch (e) {
      if (e.response != null) {
        // Llegamos al backend pero hubo error HTTP (404, 500, etc.)
        return 'HTTP error: status ${e.response?.statusCode}, body: ${e.response?.data}';
      }
      // Error de red (no conecta al host/puerto)
      return 'Network error: ${e.message}';
    } catch (e) {
      // Cualquier otra cosa rara
      return 'Unexpected error: $e';
    }
  }
}
