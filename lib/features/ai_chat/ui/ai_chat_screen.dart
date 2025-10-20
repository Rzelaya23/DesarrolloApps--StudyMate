import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';

import '../ai_message_models.dart';
import '../data/ai_service.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _uuid = const Uuid();
  late AiService _service;

  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  AiChatState _state = const AiChatState(messages: []);

  @override
  void initState() {
    super.initState();
    _service = AiService(baseUrl: null); // ← pon tu URL cuando tengas backend
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    // Abrimos un bottom sheet con botón de cancelar
    final FilePickerResult? result =
        await showModalBottomSheet<FilePickerResult?>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
  builder: (ctx) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.attach_file, color: Colors.purple),
              const SizedBox(width: 10),
              const Text(
                'Seleccionar archivos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(ctx).pop(null), // cancelar
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 10),

          // ====== BOTÓN MORADO ======
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              minimumSize: const Size(double.infinity, 50),
            ),
            icon: const Icon(Icons.folder_open, color: Colors.white),
            label: const Text(
              'Abrir explorador de archivos',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              final picked = await FilePicker.platform.pickFiles(
                allowMultiple: true,
              );
              Navigator.of(ctx).pop(picked);
            },
          ),
          const SizedBox(height: 10),

          // ====== BOTÓN CANCELAR ======
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('Cancelar'),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  },
    );

    if (!mounted) return;
    // Si el usuario cancela o no elige nada, salimos
    if (result == null || result.files.isEmpty) return;

    // Construimos una lista TIPADA de AttachmentMeta usando 'extension' (no mimeType)
    final List<AttachmentMeta> added = result.files
        .where((f) => f.path != null)
        .map((f) => AttachmentMeta(
              name: f.name,
              path: f.path!,           // seguro por el where
              sizeBytes: f.size,
              extension: f.extension,  // <- campo correcto del modelo
            ))
        .toList();

    if (added.isEmpty) return;

    // Agregamos a los pendientes manteniendo los existentes
    setState(() {
      _state = _state.copyWith(
        pendingAttachments: [..._state.pendingAttachments, ...added],
      );
    });
  }

  void _removeAttachment(String path) {
    setState(() {
      _state = _state.copyWith(
        pendingAttachments:
            _state.pendingAttachments.where((a) => a.path != path).toList(),
      );
    });
  }

  Future<void> _send() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty || _state.sending) return;

    final userMsg = Message(
      id: _uuid.v4(),
      text: text,
      isUser: true,
      createdAt: DateTime.now(),
    );

    setState(() {
      _state = _state.copyWith(
        messages: [..._state.messages, userMsg],
        sending: true,
      );
      _inputCtrl.clear();
    });

    try {
      final reply = await _service.sendMessage(
        userText: userMsg.text,
        attachments: _state.pendingAttachments,
      );

      setState(() {
        _state = _state.copyWith(
          messages: [..._state.messages, reply],
          pendingAttachments: [],
        );
      });

      _scrollToBottom();
    } catch (e) {
      final err = Message(
        id: _uuid.v4(),
        text: '⚠️ Error: $e',
        isUser: false,
        createdAt: DateTime.now(),
      );
      setState(() {
        _state = _state.copyWith(messages: [..._state.messages, err]);
      });
    } finally {
      setState(() => _state = _state.copyWith(sending: false));
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) return;
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent + 80,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 250),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistente IA'),
        actions: [
          IconButton(
            tooltip: 'Adjuntar archivos',
            onPressed: _state.sending ? null : _pickFiles,
            icon: const Icon(Icons.attach_file),
          ),
        ],
      ),
      body: Column(
        children: [
          // Chips de adjuntos pendientes
          if (_state.pendingAttachments.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: _state.pendingAttachments.map((a) {
                  final sizeKb = a.sizeBytes != null
                      ? '${(a.sizeBytes! / 1024).toStringAsFixed(0)} KB'
                      : '';
                  return Chip(
                    label: Text('${a.name} $sizeKb'),
                    onDeleted: () => _removeAttachment(a.path),
                  );
                }).toList(),
              ),
            ),

          // Mensajes
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _state.messages.length,
              itemBuilder: (context, index) {
                final m = _state.messages[index];
                final isUser = m.isUser;
                final bg = isUser
                    ? theme.colorScheme.primary.withOpacity(0.12)
                    : theme.colorScheme.surfaceVariant;
                final align =
                    isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;

                return Column(
                  crossAxisAlignment: align,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        m.text,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Input
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12).copyWith(bottom: 10),
              child: Row(
                children: [
                  // BOTÓN DE ADJUNTAR
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton.filledTonal(
                        tooltip: 'Adjuntar archivos',
                        onPressed: _state.sending ? null : _pickFiles,
                        icon: const Icon(Icons.attach_file),
                      ),
                      if (_state.pendingAttachments.isNotEmpty)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${_state.pendingAttachments.length}',
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(width: 8),

                  // INPUT
                  Expanded(
                    child: TextField(
                      controller: _inputCtrl,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Escribe tu mensaje...',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      onSubmitted: (_) => _send(),
                      enabled: !_state.sending,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // ENVIAR
                  IconButton.filled(
                    onPressed: _state.sending ? null : _send,
                    icon: _state.sending
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}