import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth/auth_token_provider.dart';
import '../../../core/config/api_config.dart';
import 'models/planner_activity.dart';
import 'models/planner_schedule.dart';

final plannerRepositoryProvider = Provider<PlannerRepository>((ref) {
  return PlannerRepository(ref);
});

class PlannerRepository {
  final Ref ref;
  PlannerRepository(this.ref);

  Dio _dioWithAuth() {
    final baseUrl = ref.read(apiBaseUrlProvider);
    final token = ref.read(authTokenProvider);

    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      contentType: 'application/json',
    ));

    if (token != null && token.isNotEmpty) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        debugPrint('REQ ${options.method} ${options.baseUrl}${options.path}');
        debugPrint('AUTH ${options.headers['Authorization']}');
        debugPrint('BODY ${options.data}');
        handler.next(options);
      },
      onResponse: (res, handler) {
        debugPrint('RES ${res.statusCode} ${res.requestOptions.path}');
        handler.next(res);
      },
      onError: (e, handler) {
        debugPrint('ERR ${e.response?.statusCode} ${e.requestOptions.path}');
        debugPrint('ERRB ${e.response?.data}');
        handler.next(e);
      },
    ));

    return dio;
  }

  Future<PlannerActivity> createActivity({
    required String title,
    required int durationMin,
    required String priority,
    required String difficulty,
    required DateTime date,
  }) async {
    final dio = _dioWithAuth();
    final payload = {
      'title': title,
      'durationMin': durationMin,
      'priority': priority,
      'difficulty': difficulty,
      'date': date.toIso8601String().split('T').first,
    };
    final res = await dio.post('/planner/activities', data: payload);
    return PlannerActivity.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<PlannerSlot>> generateSchedule({
    required DateTime date,
    required String start,
    required String end,
    required int focusMin,
    required int breakMin,
  }) async {
    final dio = _dioWithAuth();
    final payload = {
      'date': date.toIso8601String().split('T').first,
      'start': start,
      'end': end,
      'focusMin': focusMin,
      'breakMin': breakMin,
    };
    final res = await dio.post('/planner/generate', data: payload);
    final parsed = PlannerScheduleResponse.fromJson(res.data as Map<String, dynamic>);
    return parsed.items;
  }
}
