import 'package:dio/dio.dart';
import '../ai_message_models.dart';
import '../../config/api_config.dart';

typedef TokenProvider = Future<String?> Function();

class AiService {
  final Dio _dio;
  final String baseUrl;
  final TokenProvider? tokenProvider;

  AiService({
    String? baseUrl,
    this.tokenProvider,
  })  : baseUrl = baseUrl ?? getBaseUrl(),
        _dio = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 25),
            receiveTimeout: const Duration(seconds: 25),
          ),
        );

  Future<Message> sendMessage(String text, List<AttachmentMeta> attachments) async {
    final form = FormData();
    form.fields.add(MapEntry('message', text));

    for (final a in attachments) {
      final file = await MultipartFile.fromFile(a.path, filename: a.name);
      form.files.add(MapEntry('attachments[]', file));
    }

    final headers = <String, dynamic>{'Content-Type': 'multipart/form-data'};

    final token = tokenProvider != null ? await tokenProvider!() : null;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final resp = await _dio.post('$baseUrl/chat', data: form, options: Options(headers: headers));
    final reply =
        (resp.data is Map && resp.data['reply'] is String) ? resp.data['reply'] as String : '(sin respuesta del servidor)';

    return Message(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      text: reply,
      isUser: false,
      createdAt: DateTime.now(),
    );
  }
}
