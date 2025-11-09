import 'dart:io';
import 'package:flutter/foundation.dart';

String getBaseUrl() {
  if (kIsWeb) return const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:4000');
  if (Platform.isAndroid) return const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:4000');
  return const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:4000');
}
