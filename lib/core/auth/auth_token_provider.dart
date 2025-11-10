import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final _storageProvider = Provider((ref) => const FlutterSecureStorage());

final authTokenProvider = StateNotifierProvider<_AuthToken, String?>(
  (ref) => _AuthToken(ref),
);

class _AuthToken extends StateNotifier<String?> {
  _AuthToken(this._ref) : super(null) {
    _load();
  }

  final Ref _ref;

  Future<void> _load() async {
    final s = _ref.read(_storageProvider);
    state = await s.read(key: 'accessToken');
  }

  Future<void> set(String? token) async {
    final s = _ref.read(_storageProvider);
    state = token;
    if (token == null || token.isEmpty) {
      await s.delete(key: 'accessToken');
    } else {
      await s.write(key: 'accessToken', value: token);
    }
  }

  Future<void> clear() => set(null);
}
