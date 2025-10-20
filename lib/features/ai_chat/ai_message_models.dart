import 'package:flutter/foundation.dart';

class AttachmentMeta {
  final String name;
  final String path; // local path del archivo
  final int? sizeBytes;
  final String? extension; // file_picker no trae mimeType en v8

  const AttachmentMeta({
    required this.name,
    required this.path,
    this.sizeBytes,
    this.extension,
  });
}

@immutable
class Message {
  final String id;
  final String text;
  final bool isUser; // true = usuario, false = IA
  final DateTime createdAt;

  const Message({
    required this.id,
    required this.text,
    required this.isUser,
    required this.createdAt,
  });
}

@immutable
class AiChatState {
  final List<Message> messages;
  final bool sending;
  final List<AttachmentMeta> pendingAttachments;

  const AiChatState({
    required this.messages,
    this.sending = false,
    this.pendingAttachments = const [],
  });

  AiChatState copyWith({
    List<Message>? messages,
    bool? sending,
    List<AttachmentMeta>? pendingAttachments,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      sending: sending ?? this.sending,
      pendingAttachments: pendingAttachments ?? this.pendingAttachments,
    );
  }
}
