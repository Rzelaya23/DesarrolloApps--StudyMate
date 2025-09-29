// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_app/core/router/app_router.dart';
import 'package:mi_app/core/providers/theme_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES');
  runApp(const ProviderScope(child: StudyMateApp()));
}

class StudyMateApp extends ConsumerWidget {
  const StudyMateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = ref.watch(themeNotifierProvider); // 👈 estado unificado

    return MaterialApp.router(
      title: 'StudyMate',
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,

      // 👇 Un SOLO ThemeData dinámico (se actualiza y el router se repinta)
      theme: appTheme.toThemeData(),

      // Localización (tu calendario en ES)
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
