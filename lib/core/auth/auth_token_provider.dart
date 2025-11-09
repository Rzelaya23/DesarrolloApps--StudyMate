// lib/core/auth/auth_token_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Guarda el access token del usuario autenticado.
/// Si es null → usuario no autenticado.
final authTokenProvider = StateProvider<String?>((ref) => null);
