import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../models/subject.dart';

// Backend NestJS
const String _baseUrl = 'http://10.0.2.2:4000';
const String _subjectsPath = '/api/courses';

class SubjectsNotifier extends StateNotifier<Map<String, Subject>> {
  SubjectsNotifier(this._client, this._getToken) : super({}) {
    loadSubjects();
  }

  final http.Client _client;
  // Función que devuelve el token actual (o null si no hay sesión)
  final String? Function() _getToken;

  Map<String, String> _buildHeaders({bool jsonBody = true}) {
    final token = _getToken();
    return {
      if (jsonBody) 'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> loadSubjects() async {
    try {
      final uri = Uri.parse('$_baseUrl$_subjectsPath');
      final res = await _client.get(
        uri,
        headers: _buildHeaders(jsonBody: false),
      );

      if (res.statusCode != 200) {
        // ignore: avoid_print
        print('❌ loadSubjects error: ${res.statusCode} ${res.body}');
        return;
      }

      final decoded = jsonDecode(res.body);

      // Soportar dos formatos:
      // 1) Lista directa: [ {...}, {...} ]
      // 2) Objeto paginado: { items: [ {...}, {...} ], total, page, ... }
      List<dynamic> items;
      if (decoded is List) {
        items = decoded;
      } else if (decoded is Map<String, dynamic>) {
        final inner = decoded['items'] ?? decoded['data'] ?? decoded['results'];
        if (inner is List) {
          items = inner;
        } else {
          // ignore: avoid_print
          print('❌ loadSubjects: formato inesperado: $decoded');
          return;
        }
      } else {
        // ignore: avoid_print
        print('❌ loadSubjects: tipo inesperado: $decoded');
        return;
      }

      final map = <String, Subject>{};
      for (final raw in items) {
        if (raw is Map<String, dynamic>) {
          final subject = Subject.fromJson(raw);
          map[subject.id] = subject;
        }
      }

      state = map;
      // ignore: avoid_print
      print('✅ loadSubjects ok: ${state.length} materias');
    } catch (e) {
      // ignore: avoid_print
      print('❌ loadSubjects exception: $e');
    }
  }

  Future<Subject> createSubject(Subject draft) async {
    final uri = Uri.parse('$_baseUrl$_subjectsPath');

    // ignore: avoid_print
    print('➡️ POST $uri body=${draft.toJsonForBackend()}');

    final res = await _client.post(
      uri,
      headers: _buildHeaders(),
      body: jsonEncode(draft.toJsonForBackend()),
    );

    if (res.statusCode != 201 && res.statusCode != 200) {
      // ignore: avoid_print
      print('❌ createSubject error: ${res.statusCode} ${res.body}');
      throw Exception('Error al crear materia: ${res.body}');
    }

    final decoded = jsonDecode(res.body);

    Map<String, dynamic> subjectJson;
    if (decoded is Map<String, dynamic>) {
      // Caso típico: el backend devuelve directamente el curso
      if (decoded.containsKey('id') || decoded.containsKey('title')) {
        subjectJson = decoded;
      } else if (decoded['item'] is Map<String, dynamic>) {
        subjectJson = decoded['item'] as Map<String, dynamic>;
      } else if (decoded['data'] is Map<String, dynamic>) {
        subjectJson = decoded['data'] as Map<String, dynamic>;
      } else {
        subjectJson = decoded;
      }
    } else {
      throw Exception('Formato inesperado al crear materia: $decoded');
    }

    final subject = Subject.fromJson(subjectJson);

    state = {...state, subject.id: subject};

    // ignore: avoid_print
    print('✅ Materia creada: ${subject.id} - ${subject.name}');

    return subject;
  }

  Future<Subject> updateSubject(Subject subject) async {
    final uri = Uri.parse('$_baseUrl$_subjectsPath/${subject.id}');

    final res = await _client.patch(
      uri,
      headers: _buildHeaders(),
      body: jsonEncode(subject.toJsonForBackend()),
    );

    if (res.statusCode != 200) {
      // ignore: avoid_print
      print('❌ updateSubject error: ${res.statusCode} ${res.body}');
      throw Exception('Error al actualizar materia: ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final updated = Subject.fromJson(data);

    final newState = Map<String, Subject>.from(state);
    newState[updated.id] = updated;
    state = newState;

    return updated;
  }

  Future<void> deleteSubject(String id) async {
    final uri = Uri.parse('$_baseUrl$_subjectsPath/$id');

    final res = await _client.delete(
      uri,
      headers: _buildHeaders(jsonBody: false),
    );

    if (res.statusCode != 200 && res.statusCode != 204) {
      // ignore: avoid_print
      print('❌ deleteSubject error: ${res.statusCode} ${res.body}');
      throw Exception('Error al eliminar materia: ${res.body}');
    }

    final newState = Map<String, Subject>.from(state);
    newState.remove(id);
    state = newState;
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final subjectsProvider =
    StateNotifierProvider<SubjectsNotifier, Map<String, Subject>>((ref) {
      // Cuando tengas auth global:
      // final auth = ref.watch(authStateProvider);
      // String? getToken() => auth.token;

      String? getToken() {
        return null; // por ahora sin JWT
      }

      return SubjectsNotifier(http.Client(), getToken);
    });
