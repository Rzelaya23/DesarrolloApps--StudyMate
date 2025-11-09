// lib/core/api/api_config.dart

class ApiConfig {
  static const String host = 'http://10.0.2.2:4000';

  // Prefijo global del backend (main.ts → 'api')
  static const String apiPrefix = '/api';

  static String get baseUrl => '$host$apiPrefix';

  // Para IA más adelante, probablemente sea /api/ai/...
  static String get aiBaseUrl => '$baseUrl/ai';
}
