// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_app/core/router/app_router.dart';
import 'package:mi_app/core/providers/theme_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'features/ai_chat/data/ai_service.dart';
import 'features/ai_chat/ui/ai_chat_screen.dart';

final _secure = const FlutterSecureStorage();

final aiService = AiService(
  tokenProvider: () async => await _secure.read(key: 'jwt'),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES');
  runApp(const ProviderScope(child: StudyMateApp()));
}

class StudyMateApp extends ConsumerWidget {
  const StudyMateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = ref.watch(themeNotifierProvider);

    return MaterialApp.router(
      title: 'StudyMate',
      debugShowCheckedModeBanner: false,
      theme: appTheme.toThemeData(),
      routerConfig: AppRouter.router,   // 👈 volvemos a tu router normal

      supportedLocales: const [
        Locale('es', 'ES'),
        Locale('en', 'US'),
      ],
      locale: const Locale('es', 'ES'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
