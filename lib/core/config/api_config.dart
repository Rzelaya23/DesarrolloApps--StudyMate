import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiBaseUrlProvider = Provider<String>((ref) {
  // Emulador Android -> host de tu Mac
  return 'http://10.0.2.2:4000/api';
});
