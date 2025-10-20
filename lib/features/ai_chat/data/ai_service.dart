import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import '../ai_message_models.dart';

class AiService {
  final String? baseUrl; // cuando tengas backend, pon la URL
  final Dio _dio;
  final _uuid = const Uuid();

  AiService({this.baseUrl})
      : _dio = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 25),
            receiveTimeout: const Duration(seconds: 25),
          ),
        );

  Future<Message> sendMessage({
    required String userText,
    required List<AttachmentMeta> attachments,
  }) async {
    if (baseUrl == null) {
      // Demo local: responde después de 1s
      await Future.delayed(const Duration(seconds: 1));
      final info =
          attachments.isEmpty ? '' : ' (recibí ${attachments.length} archivo/s)';
      return Message(
        id: _uuid.v4(),
        text: '👩‍🎓 IA: Entendido. Tu mensaje fue: "$userText"$info',
        isUser: false,
        createdAt: DateTime.now(),
      );
    }

    // Real (multipart/form-data)
    final form = FormData.fromMap({
      'message': userText,
      'files': [
        for (final a in attachments)
          await MultipartFile.fromFile(
            a.path,
            filename: a.name,
            // file_picker v8 no da mimeType; el backend debería inferirla
          ),
      ],
    });

    final r = await _dio.post('$baseUrl/chat', data: form);
    final reply = (r.data?['reply'] ?? '').toString();

    return Message(
      id: _uuid.v4(),
      text: reply.isEmpty ? '(sin respuesta del servidor)' : reply,
      isUser: false,
      createdAt: DateTime.now(),
    );
    }
}
