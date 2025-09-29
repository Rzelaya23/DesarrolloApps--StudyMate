// lib/core/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_app/core/theme/app_theme.dart';

/// Paleta completa (la exponemos por si quieres mostrar un selector de color)
final colorListProvider = Provider<List<Color>>((ref) => colorList);

/// Boolean simple (opcional) para leer el modo oscuro/claro
final isDarkmodeProvider = NotifierProvider<IsDarkmodeNotifier, bool>(
  IsDarkmodeNotifier.new,
);

/// Índice de color seleccionado (opcional)
final selectedColorProvider = NotifierProvider<SelectedColorNotifier, int>(
  SelectedColorNotifier.new,
);

/// Provider PRINCIPAL que usa la app (router/materialApp leen de aquí)
final themeNotifierProvider = NotifierProvider<ThemeNotifier, AppTheme>(
  ThemeNotifier.new,
);

class IsDarkmodeNotifier extends Notifier<bool> {
  @override
  bool build() => false; // claro por defecto
  void toggle() => state = !state;
}

class SelectedColorNotifier extends Notifier<int> {
  @override
  int build() => 0; // primer color por defecto (tu morado)
  void changeColorIndex(int colorIndex) => state = colorIndex;
}

/// Controlador principal del tema
class ThemeNotifier extends Notifier<AppTheme> {
  @override
  AppTheme build() => AppTheme(); // <- usa Opción 1 (sin const)

  void toggleDarkmode() {
    final next = !state.isDarkmode;
    state = state.copyWith(isDarkmode: next);

    // Mantener sincronizado el auxiliar (opcional)
    final cur = ref.read(isDarkmodeProvider);
    if (cur != next) {
      ref.read(isDarkmodeProvider.notifier).toggle();
    }
  }

  void changeColorIndex(int colorIndex) {
    state = state.copyWith(selectedColor: colorIndex);

    // Mantener sincronizado el auxiliar (opcional)
    ref.read(selectedColorProvider.notifier).changeColorIndex(colorIndex);
  }
} // <- asegúrate de que ESTA sea la última llave del archivo
